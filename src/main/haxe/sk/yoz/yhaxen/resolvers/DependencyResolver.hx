package sk.yoz.yhaxen.resolvers;

import sk.yoz.yhaxen.valueObjects.DependencyTreeItem;
import sk.yoz.yhaxen.valueObjects.FlattenDependencies;
import sk.yoz.yhaxen.valueObjects.DependencyTreeItem;
import tools.haxelib.Data;
import sk.yoz.yhaxen.helpers.HaxelibHelper;
import StringTools;
import sk.yoz.yhaxen.valueObjects.DependencyTreeItem;
import sk.yoz.yhaxen.helpers.HaxelibHelper;
import Lambda;
import haxe.ds.ObjectMap;
import sk.yoz.yhaxen.valueObjects.config.DependencyDetail;
import sk.yoz.yhaxen.valueObjects.Dependency;
import haxe.Json;

import sk.yoz.yhaxen.enums.SourceType;
import sk.yoz.yhaxen.helpers.HaxelibHelper;
import sk.yoz.yhaxen.helpers.SysHelper;
import sk.yoz.yhaxen.parsers.YHaxenParser;
import sk.yoz.yhaxen.valueObjects.config.Root;
import sk.yoz.yhaxen.valueObjects.config.DependencyDetail;

import sys.io.File;
import sys.FileSystem;

class DependencyResolver
{
	public function new(){}

	public function installFromFile(file:String):Void
	{
		var list = getDependenciesFromFile(file);
		for(item in list)
			installDependency(item);
	}

	public function reportFromFile(file:String):Void
	{
		var list:Array<Dependency> = [];
		var tree = treeFromFile(file);
		SysHelper.print("");
		SysHelper.print("Tree:");
		reportTree(tree);

		var flatten = flattenTree(tree);
		SysHelper.print("");
		SysHelper.print("Flatten:");
		reportFlatten(flatten);
	}

	function treeFromFile(file:String):Array<DependencyTreeItem>
	{
		var details = getDependenciesFromFile(file);
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
			var result:String = dependencyExists(item) ? "OK" : "MISSING";
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
			var version = item.version == null
				? HaxelibHelper.getCurrentVersion(item.name)
				: item.decoratedVersion;
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

			var status:String = dependencyNameVersionExists(name, version) ? "OK" : "MISSING";

			SysHelper.printKeyVal("  " + name, 40, count == 1 ? status + " (" + version + ")" : "CONFLICT");
			if(count == 1)
				continue;

			for(version in dataName.keys())
			{
				var sources = dataName.get(version);
				SysHelper.printKeyVal("    in " + DependencyTreeItem.joinList(sources, ", ", "(ROOT)"), 40, " ! (" + version + ")");
			}
		}
	}

	function checkFile(file:String):Void
	{
		if(!FileSystem.exists(file))
			throw "File " + file + " does not exist!";

		if(FileSystem.isDirectory(file))
			throw file + " is not a file!";
	}
	
	function getDependenciesFromFile(file:String):Array<DependencyDetail>
	{
		checkFile(file);
		var data = File.getContent(file);
		var json = Json.parse(data);
		var yhaxen = new YHaxenParser().parse(json);
		return yhaxen.dependencies;
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

		installSubdependencies(dependency);
	}

	function installDependencyFromGit(dependency:DependencyDetail):Void
	{
		var tmp:String = "tmp";
		var projectDirectory:String = HaxelibHelper.getProjectDirectory(dependency.name);
		FileSystem.createDirectory(tmp);
		SysHelper.command("git", ["clone", dependency.source, tmp, "-b", dependency.version, "--single-branch"]);
		HaxelibHelper.deleteDirectory(tmp + "/.git");
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

		var currentFile:String = projectDirectory + "/.current";
		if(!FileSystem.exists(currentFile))
			File.saveContent(currentFile, dependency.version);
	}

	function installSubdependencies(dependency:Dependency):Void
	{
		var haxelib:String = dependecyDirectory(dependency) + "/haxelib.json";
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

		var path:String = directory + "/haxelib.json";
		if(!FileSystem.exists(path))
			return null;

		var haxelibJson = File.getContent(path);
		var list = Data.readData(haxelibJson, false);
		var result:Array<DependencyTreeItem> = [];
		for(info in list.dependencies)
		{
			var item = new DependencyTreeItem(info.project, info.version);
			getDependencyTree(item.name, item.version);
			result.push(item);
		}
		return result;
	}
}