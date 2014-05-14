package sk.yoz.yhaxen.resolvers;

import Lambda;
import sk.yoz.yhaxen.valueObjects.Command;
import sk.yoz.yhaxen.valueObjects.Dependency;
import haxe.Json;

import sk.yoz.yhaxen.enums.SourceType;
import sk.yoz.yhaxen.helpers.GitHelper;
import sk.yoz.yhaxen.helpers.HaxelibHelper;
import sk.yoz.yhaxen.helpers.SysHelper;
import sk.yoz.yhaxen.parsers.YHaxenParser;
import sk.yoz.yhaxen.valueObjects.config.Root;
import sk.yoz.yhaxen.valueObjects.config.DependencyDetail;
import sk.yoz.yhaxen.valueObjects.Dependency;
import sk.yoz.yhaxen.valueObjects.DependencyTreeItem;
import sk.yoz.yhaxen.valueObjects.Error;
import sk.yoz.yhaxen.valueObjects.FlattenDependencies;

import tools.haxelib.Data;

import sys.io.File;
import sys.FileSystem;

class DependencyResolver
{
	inline static var WORD_OK:String = "OK";
	inline static var WORD_MISSING:String = "MISSING";
	inline static var WORD_CONFLICT:String = "CONFLICT";
	inline static var WORD_ROOT:String = "<ROOT>";
	inline static var WORD_INVALID:String = "INVALID";
	inline static var WORD_UNDEFINED:String = "UNDEFINED";

	private var haxelib:HaxelibHelper;

	public function new()
	{
		haxelib = new HaxelibHelper();
	}

	public function installFromFile(file:String, scope:String=null):Void
	{
		var list = getDependenciesFromFile(file, scope);
		for(item in list)
			installDependency(item);
	}

	public function reportFromFile(file:String, scope:String=null):Void
	{
		var details = getDependenciesFromFile(file, scope);
		var list:Array<Dependency> = [];
		var tree = treeFromDependencyDetails(details);
		var flatten = flattenTree(tree);

		SysHelper.print("");
		SysHelper.print("Legend:");
		SysHelper.printKeyVal("  " + WORD_OK, 20, "Dependency exists.");
		SysHelper.printKeyVal("  " + WORD_MISSING, 20, "Dependency needs to be installed.");
		SysHelper.printKeyVal("  " + WORD_CONFLICT, 20, "Different versions of dependencies used across project.");
		SysHelper.printKeyVal("  " + WORD_ROOT, 20, "Project level.");

		SysHelper.print("");
		SysHelper.print("Tree:");
		reportTree(tree);

		SysHelper.print("");
		SysHelper.print("Flatten:");
		reportFlatten(flatten, details);

		SysHelper.print("");
		SysHelper.print("Compilation:");
		reportCompile(flatten);
	}

	function treeFromDependencyDetails(details:Array<DependencyDetail>):Array<DependencyTreeItem>
	{
		var result:Array<DependencyTreeItem> = [];
		for(detail in details)
		{
			var item = new DependencyTreeItem(detail.name, detail.version);
			validateDependency(item, details);
			item.dependencies = getDependencyTree(item, details);
			result.push(item);
		}
		return result;
	}

	function reportTree(list:Array<DependencyTreeItem>, level:Int=0):Void
	{
		for(item in list)
		{
			var result:String = WORD_INVALID;
			if(item.resolvedVersion != null)
				result = (item.resolvedVersionExists ? WORD_OK : WORD_MISSING) + " (" + item.resolvedVersion + ")";

			var pad:String = StringTools.lpad("", " ", level * 2 + 2);
			SysHelper.printKeyVal(pad + item.toString(), 40, result);

			if(item.isDev)
				throw new Error(
					"Invalid dependency " + item.name + "!",
					"Dependency " + item.name + " is dev dependency, not recommended for projects.",
					"Execute \"haxelib dev " + item.name + "\" to turn of dev dependency.");

			if(item.resolvedVersion == null)
				throw new Error(
					"Invalid dependency " + item.name + "!",
					"Dependency " + item.name + " is defined without version information.",
					"Provide forcedVersion in " + Root.FILENAME + " for this dependency.");

			if(!item.resolvedVersionExists && item.forcedVersion != item.resolvedVersion)
				throw new Error(
					"Missing dependency " + item.name + "!",
					"Dependency " + item.name + " with resolved version " + item.resolvedVersion + " is missing.",
					"Install dependency using " + Command.KEY_DEPENDENCY_INSTALL + " command or provide forcedVersion in " + Root.FILENAME + ".");

			if(!item.resolvedVersionExists)
				throw new Error(
					"Missing dependency " + item.name + "!",
					"Dependency " + item.name + " with resolved version " + item.resolvedVersion + " is missing.",
					"Install dependenciy using " + Command.KEY_DEPENDENCY_INSTALL + " command.");

			if(item.dependencies != null)
				reportTree(item.dependencies, level + 1);
		}
	}

	function flattenTree(list:Array<DependencyTreeItem>, parent:DependencyTreeItem=null,
		target:FlattenDependencies=null):FlattenDependencies
	{
		if(list == null || list.length == 0)
			return null;

		if(target == null)
			target = new FlattenDependencies();

		for(item in list)
		{
			if(!target.exists(item.name))
				target.set(item.name, new Map<String,Array<DependencyTreeItem>>());
			var targetName = target.get(item.name);
			var version = item.version == null ? WORD_UNDEFINED : item.version;
			if(!targetName.exists(version))
				targetName.set(version, []);
			var targetNameVersion = targetName.get(version);
			if(!DependencyTreeItem.listContainsByNameAndVersion(targetNameVersion, parent))
				targetNameVersion.push(parent);
			flattenTree(item.dependencies, item, target);

		}

		return target;
	}

	function reportFlatten(data:FlattenDependencies, details:Array<DependencyDetail>):Void
	{
		for(name in data.keys())
		{
			var dataName = data.get(name);
			var versions:Array<String> = [];
			for(version in dataName.keys())
				if(version != WORD_UNDEFINED && Lambda.indexOf(versions, version) == -1)
					versions.push(version);

			if(versions.length == 1)
			{
				SysHelper.printKeyVal("  " + name, 40, WORD_OK + " (" + versions[0] + ")");
				continue;
			}

			SysHelper.printKeyVal("  " + name, 40, WORD_CONFLICT);
			for(version in dataName.keys())
			{
				if(version == WORD_UNDEFINED)
					continue;
				var sources = dataName.get(version);
				for(source in sources)
					SysHelper.printKeyVal("    in " + (source == null ? WORD_ROOT : source.toString()), 40, " ! (" + version + ")");
			}

			var detail = DependencyDetail.getFromList(details, name);
			if(detail == null || detail.forcedVersion == null)
				throw new Error(
					"Invalid dependency version for " + name + "!",
					"Dependency " + name + " has multiple versions used.",
					"Provide forcedVersion in " + Root.FILENAME + ".");
		}
	}

	function reportCompile(data:FlattenDependencies):Void
	{
		var items:Array<String> = [];
		for(name in data.keys())
			for(version in data.get(name).keys())
				if(version != WORD_UNDEFINED)
					items.push("-lib " + name + ":" + version);
		SysHelper.print(items.join(" "));
	}

	function checkFile(file:String):Void
	{
		if(!FileSystem.exists(file))
			throw "File " + file + " does not exist!";

		if(FileSystem.isDirectory(file))
			throw file + " is not a file!";
	}
	
	function getDependenciesFromFile(file:String, scope:String=null):Array<DependencyDetail>
	{
		checkFile(file);
		var data = File.getContent(file);
		var json:Dynamic;
		try
		{
			json = Json.parse(data);
		}
		catch(error:String)
		{
			throw "Unable to parse " + file + ". " + error;
		}
		var yhaxen = new YHaxenParser().parse(json);
		var result:Array<DependencyDetail> = [];
		for(item in yhaxen.dependencies)
			if(item.matchesScope(scope))
				result.push(item);
		return result;
	}

	function installDependency(dependency:DependencyDetail)
	{
		SysHelper.print("");
		SysHelper.print("Resolving " + dependency.toString());

		if(haxelib.versionExists(dependency.name, dependency.version))
		{
			SysHelper.print("  Dependency already installed.");
		}
		else
		{
			switch(dependency.sourceType)
			{
				case SourceType.GIT:
					installDependencyGit(dependency);
				case SourceType.HAXELIB:
					installDependencyHaxelib(dependency);
			}
		}
	}

	function installDependencyGit(dependency:DependencyDetail):Void
	{
		var tmp:String = ".temp";
		if(FileSystem.exists(tmp))
			haxelib.deleteDirectory(tmp);
		FileSystem.createDirectory(tmp);
		try
		{
			GitHelper.checkout(dependency.source, dependency.version, tmp);
		}
		catch(error:Dynamic)
		{
			haxelib.deleteDirectory(tmp);
			throw error;
		}

		haxelib.deleteDirectory(tmp + "/.git");
		var projectDirectory:String = haxelib.getProjectDirectory(dependency.name);
		haxelib.ensureDirectoryExists(projectDirectory);

		var target:String = haxelib.getVersionDirectory(dependency.name, dependency.version, false, null);
		var source:String = tmp;
		if(dependency.classPath != null)
		{
			FileSystem.rename(source + "/" + dependency.classPath, target);
			haxelib.deleteDirectory(tmp);
		}
		else
		{
			FileSystem.rename(source, target);
		}

		var currentFile:String = projectDirectory + "/" + HaxelibHelper.FILE_CURRENT;
		if(!FileSystem.exists(currentFile))
			File.saveContent(currentFile, dependency.version);
	}

	function installDependencyHaxelib(dependency:DependencyDetail):Void
	{
		SysHelper.command("haxelib", ["install", dependency.name, dependency.version]);
	}

	function getDependencyTree(dependency:Dependency, details:Array<DependencyDetail>):Array<DependencyTreeItem>
	{
		var directory:String = haxelib.getVersionDirectory(dependency.name, dependency.version, dependency.isDev, dependency.currentVersion);

		if(directory == null)
			return null;

		var path:String = directory + "/" + HaxelibHelper.FILE_HAXELIB;
		if(!FileSystem.exists(path))
			return null;

		var haxelibJson = File.getContent(path);
		var list = Data.readData(haxelibJson, false);
		var result:Array<DependencyTreeItem> = [];
		for(info in list.dependencies)
		{
			var name = info.project;
			var version = info.version;
			var item = new DependencyTreeItem(name, version);
			validateDependency(item, details);
			item.dependencies = item.exists ? getDependencyTree(item, details) : null;
			result.push(item);
		}
		return result;
	}

	function validateDependency(item:Dependency, details:Array<DependencyDetail>):Void
	{
		var detail = DependencyDetail.getFromList(details, item.name);
		item.exists = haxelib.dependencyExists(item.name);
		item.forcedVersion = (detail != null && detail.forceVersion) ? detail.version : null;
		item.resolvedVersion = item.forcedVersion == null ? item.version : item.forcedVersion;
		if(item.exists)
		{
			item.isDev = haxelib.isDev(item.name);
			item.currentVersion = haxelib.getCurrentVersion(item.name);
			item.versionExists = item.version == null ? false : haxelib.versionExists(item.name, item.version);
			item.currentVersionExists = haxelib.versionExists(item.name, item.currentVersion);
			item.forcedVersionExists = item.forcedVersion == null ? false : haxelib.versionExists(item.name, item.forcedVersion);
			item.resolvedVersionExists = item.resolvedVersion == null ? false : haxelib.versionExists(item.name, item.resolvedVersion);
		}
		else
		{
			item.isDev = false;
			item.currentVersion = null;
			item.versionExists = false;
			item.currentVersionExists = false;
			item.forcedVersionExists = false;
			item.resolvedVersionExists = false;
		}
	}
}