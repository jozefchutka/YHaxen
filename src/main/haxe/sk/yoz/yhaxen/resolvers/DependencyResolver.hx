package sk.yoz.yhaxen.resolvers;

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

		for(item in list)
			installSubdependencies(item);
	}

	public function reportFromFile(file:String, scope:String=null):Void
	{
		var list:Array<Dependency> = [];
		var tree = treeFromFile(file, scope);
		var flatten = flattenTree(tree);
/*
		if(DependencyTreeItem.listHasCurrentDependencies(tree))
		{
			//reportDevDependencies(tree);
			throw new Error(
				Dependency.decorateVersion(Dependency.VERSION_CURRENT) + " dependencies found.",
				Dependency.decorateVersion(Dependency.VERSION_CURRENT) + " dependencies are not recommended for projects.",
				"Provide exact version number for necessary libraries.");
		}
*/
		SysHelper.print("");
		SysHelper.print("Legend:");
		SysHelper.printKeyVal("  " + WORD_OK, 20, "Dependency exists.");
		SysHelper.printKeyVal("  " + WORD_MISSING, 20, "Dependency needs to be installed.");
		SysHelper.printKeyVal("  " + WORD_CONFLICT, 20, "Different versions of dependencies used across project.");
		SysHelper.printKeyVal("  " + WORD_ROOT, 20, "Project level.");

		SysHelper.print("");
		SysHelper.print("Tree:");
		reportTree(tree);

		if(DependencyTreeItem.listHasDevDependencies(tree))
		{
			throw new Error(
				"Dev dependencies found.",
				"Dev dependencies are not recommended for projects.",
				"Turn off dev dependencies for libraries using \"haxelib dev <lib>\".");
		}

		SysHelper.print("");
		SysHelper.print("Flatten:");
		reportFlatten(flatten);

		SysHelper.print("");
		SysHelper.print("Compilation:");
		reportCompile(flatten);
	}

	function treeFromFile(file:String, scope:String=null):Array<DependencyTreeItem>
	{
		var details = getDependenciesFromFile(file, scope);
		var result:Array<DependencyTreeItem> = [];
		for(detail in details)
		{
			var item = new DependencyTreeItem(detail.name, detail.version);
			validateDependency(item);
			item.dependencies = getDependencyTree(item, details);
			result.push(item);
		}
		return result;
	}

	function reportTree(list:Array<DependencyTreeItem>, level:Int=0):Void
	{
		for(item in list)
		{
			var result:String;
			if(item.isDev)
				result = WORD_INVALID;
			else if(item.version == null)
				result = (item.currentVersionExists ? WORD_OK : WORD_MISSING) + " (" + item.currentVersion + ")";
			else
				result = (item.versionExists ? WORD_OK : WORD_MISSING) + " (" + item.version + ")";

			var pad:String = StringTools.lpad("", " ", level * 2 + 2);
			SysHelper.printKeyVal(pad + item.toString(), 40, result);
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
			var version = item.version == null ? item.currentVersion : item.version;
			if(!targetName.exists(version))
				targetName.set(version, []);
			var targetNameVersion = targetName.get(version);
			if(!Lambda.has(targetNameVersion, parent))
				targetNameVersion.push(parent);
			flattenTree(item.dependencies, item, target);
		}

		return target;
	}

	function reportFlatten(data:FlattenDependencies):Void
	{
		for(name in data.keys())
		{
			var dataName = data.get(name);
			var count:Int = 0;
			var version:String;
			for(versionKey in dataName.keys())
			{
				version = versionKey;
				count++;
			}

			SysHelper.printKeyVal("  " + name, 40, count == 1 ? (WORD_OK + " (" + version + ")") : WORD_CONFLICT);
			if(count == 1)
				continue;

			for(version in dataName.keys())
			{
				var sources = dataName.get(version);
				for(source in sources)
					SysHelper.printKeyVal("    in " + (source == null ? WORD_ROOT : source.toString()), 40, " ! (" + version + ")");
			}
		}
	}

	function reportCompile(data:FlattenDependencies):Void
	{
		var items:Array<String> = [];
		for(name in data.keys())
			for(version in data.get(name).keys())
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
					installDependencyFromGit(dependency);
			}
		}
	}

	function installDependencyFromGit(dependency:DependencyDetail):Void
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

	function installSubdependencies(dependency:DependencyDetail):Void
	{
		SysHelper.print("");

		if(!dependency.installDependencies)
		{
			SysHelper.print("Skipped sub-dependecies for " + dependency.name);
			return;
		}

		SysHelper.print("Resolving sub-dependencies for " + dependency.name);
		var haxelibJson:String = haxelib.getVersionDirectory(dependency.name, dependency.version, dependency.isDev, dependency.currentVersion) + "/" + HaxelibHelper.FILE_HAXELIB;
		if(FileSystem.exists(haxelibJson))
			return haxelib.resolveHaxelibJson(haxelibJson);
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
			var detail = DependencyDetail.getFromList(details, name);
			if(detail != null && detail.forceVersion)
				version = detail.version;

			var item = new DependencyTreeItem(name, version);
			validateDependency(item);
			item.dependencies = getDependencyTree(item, details);
			result.push(item);
		}
		return result;
	}

	function validateDependency(item:Dependency):Void
	{
		item.isDev = haxelib.isDev(item.name);
		item.currentVersion = haxelib.getCurrentVersion(item.name);
		item.versionExists = item.version == null ? false : haxelib.versionExists(item.name, item.version);
		item.currentVersionExists = haxelib.versionExists(item.name, item.currentVersion);
	}
}