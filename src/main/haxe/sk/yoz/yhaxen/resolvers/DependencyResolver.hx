package sk.yoz.yhaxen.resolvers;

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

	public function new(){}

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

		SysHelper.print("");
		SysHelper.print("Legend:");
		SysHelper.printKeyVal("  " + WORD_OK, 20, "Dependency exists.");
		SysHelper.printKeyVal("  " + WORD_MISSING, 20, "Dependency needs to be installed.");
		SysHelper.printKeyVal("  " + WORD_CONFLICT, 20, "Different versions of dependencies used across project.");
		SysHelper.printKeyVal("  dep:" + Dependency.decorateVersion(Dependency.CURRENT_VERSION), 20, "Current version of dependency will be used.");
		SysHelper.printKeyVal("  " + WORD_ROOT, 20, "Project level.");

		SysHelper.print("");
		SysHelper.print("Tree:");
		reportTree(tree);

		var flatten = flattenTree(tree);
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
			item.dependencies = getDependencyTree(item.name, item.version);
			result.push(item);
		}
		return result;
	}

	function reportTree(list:Array<DependencyTreeItem>, level:Int=0):Void
	{
		for(item in list)
		{
			var pad:String = StringTools.lpad("", " ", level * 2 + 2);
			var result:String = dependencyExists(item) ? WORD_OK : WORD_MISSING;
			if(item.version == null)
			{
				var currentVersion = HaxelibHelper.getCurrentVersion(item.name);
				if(currentVersion != null)
					result += " (" + currentVersion + ")";
			}
			else
			{
				result += " (" + item.version + ")";
			}

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
			var version = item.decoratedVersion;
			if(!dependencyExists(item))
				version = Dependency.decorateVersion(Dependency.CURRENT_VERSION);
			else if(item.versionIsCurrent())
				version = HaxelibHelper.getCurrentVersion(item.name);
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
			var decoratedVersion:String;
			for(versionKey in dataName.keys())
			{
				decoratedVersion = versionKey;
				count++;
			}

			var version = Dependency.undecorateVersion(decoratedVersion);
			var exists:Bool = dependencyNameVersionExists(name, version);
			var status:String = exists ? WORD_OK : WORD_MISSING;
			if(exists || version != Dependency.CURRENT_VERSION)
				status += " (" + decoratedVersion + ")";

			SysHelper.printKeyVal("  " + name, 40, count == 1 ? status : WORD_CONFLICT);
			if(count == 1)
				continue;

			for(decoratedVersion in dataName.keys())
			{
				var version = Dependency.undecorateVersion(decoratedVersion);
				var sources = dataName.get(version);
				SysHelper.printKeyVal("    in " + DependencyTreeItem.joinList(sources, ", ", WORD_ROOT), 40, " ! (" + decoratedVersion + ")");
			}
		}
	}

	function reportCompile(data:FlattenDependencies):Void
	{
		var items:Array<String> = [];
		for(name in data.keys())
		{
			for(decoratedVersion in data.get(name).keys())
			{
				var version = Dependency.undecorateVersion(decoratedVersion);
				if(dependencyNameVersionExists(name, version))
					items.push("-lib " + name + ":" + version);
			}
		}
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

		if(dependencyExists(dependency))
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
		var tmp:String = "tmp";
		if(FileSystem.exists(tmp))
			HaxelibHelper.deleteDirectory(tmp);
		FileSystem.createDirectory(tmp);
		try
		{
			GitHelper.checkout(dependency.source, dependency.version, tmp);
		}
		catch(error:Dynamic)
		{
			HaxelibHelper.deleteDirectory(tmp);
			throw error;
		}
		HaxelibHelper.deleteDirectory(tmp + "/.git");

		var projectDirectory:String = HaxelibHelper.getProjectDirectory(dependency.name);
		HaxelibHelper.ensureDirectoryExists(projectDirectory);

		var target:String = dependecyDirectory(dependency);
		var source:String = tmp;
		if(dependency.classPath != null)
		{
			FileSystem.rename(source + "/" + dependency.classPath, target);
			HaxelibHelper.deleteDirectory(tmp);
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
		var haxelib:String = dependecyDirectory(dependency) + "/" + HaxelibHelper.FILE_HAXELIB;
		if(FileSystem.exists(haxelib))
			return HaxelibHelper.resolveHaxelibJson(haxelib);
	}

	function dependecyDirectory(dependency:Dependency):String
	{
		return HaxelibHelper.getProjectVersionDirectory(dependency.name, dependency.version);
	}
	
	function dependencyExists(dependency:Dependency):Bool
	{
		return dependencyNameVersionExists(dependency.name, dependency.version);
	}

	function dependencyNameVersionExists(name:String, version:String):Bool
	{
		return HaxelibHelper.projectExists(name, version);
	}

	function getDependencyTree(name:String, version:String):Array<DependencyTreeItem>
	{
		var directory:String = HaxelibHelper.getProjectVersionDirectory(name, version);
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
			var item = new DependencyTreeItem(info.project, info.version);
			item.dependencies = getDependencyTree(item.name, item.version);
			result.push(item);
		}
		return result;
	}
}