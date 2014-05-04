package sk.yoz.yhaxen.resolvers;

import Lambda;
import haxe.ds.ObjectMap;
import sk.yoz.yhaxen.valueObjects.config.Dependency;
import sk.yoz.yhaxen.valueObjects.ProjectDependency;
import haxe.Json;

import sk.yoz.yhaxen.enums.SourceType;
import sk.yoz.yhaxen.helpers.HaxelibHelper;
import sk.yoz.yhaxen.helpers.SysHelper;
import sk.yoz.yhaxen.parsers.YHaxenParser;
import sk.yoz.yhaxen.valueObjects.config.YHaxen;
import sk.yoz.yhaxen.valueObjects.config.Dependency;

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
		var list:Array<ProjectDependency> = [];
		var map:Map<String,Map<String,Array<String>>> = new Map<String,Map<String,Array<String>>>();
		flattenFromFile(null, file, list);
		for(item in list)
		{
			if(!map.exists(item.name))
				map.set(item.name, new Map<String,Array<String>>());
			if(!map.get(item.name).exists(item.version))
				map.get(item.name).set(item.version, []);
			var versionArray = map.get(item.name).get(item.version);
			if(!Lambda.has(versionArray, item.parent))
				versionArray.push(item.parent);
		}

		for(key in map.keys())
		{
			SysHelper.print(key);
			var count:Int = 0;
			for(key2 in map.get(key).keys())
			{
				SysHelper.print("  " + key2 + " in " + map.get(key).get(key2).join(","));
				count++;
			}
			if(count > 1)
				SysHelper.print("  conflict");
		}
	}

	private function flattenFromFile(parent:Dependency, file:String, result:Array<ProjectDependency>):Void
	{
		var list = getDependenciesFromFile(file);
		for(item in list)
		{
			result.push({parent:(parent == null ? "ROOT" : parent.name), name:item.name, version:item.version});
			flattenDependencies(item, result);
		}
	}
	
	function checkFile(file:String):Void
	{
		if(!FileSystem.exists(file))
			throw "File " + file + " does not exist!";

		if(FileSystem.isDirectory(file))
			throw file + " is not a file!";
	}
	
	function getDependenciesFromFile(file:String):Array<Dependency>
	{
		checkFile(file);
		var data = File.getContent(file);
		var json = Json.parse(data);
		var yhaxen = new YHaxenParser().parse(json);
		return yhaxen.dependencies;
	}

	function installDependency(dependency:Dependency)
	{
		SysHelper.print("");
		SysHelper.print("Resolving " + dependency.toString());

		if(!dependencyExists(dependency))
		{
			switch(dependency.sourceType)
			{
				case SourceType.GIT:
					installDependencyFromGit(dependency);
			}
		}

		installSubdependencies(dependency);
	}

	function installDependencyFromGit(dependency:Dependency):Void
	{
		var tmp:String = "tmp";
		FileSystem.createDirectory(tmp);
		SysHelper.command("git", ["clone", dependency.source, tmp, "-b", dependency.version, "--single-branch"]);
		HaxelibHelper.deleteDirectory(tmp + "/.git");
		HaxelibHelper.ensureDirectoryExists(HaxelibHelper.getProjectDirectory(dependency.name));

		var target:String = dependecyDirectory(dependency);
		var source:String = tmp;
		if(dependency.classPath != null)
		{
			FileSystem.rename(source + "/" + dependency.classPath, target);
			if(FileSystem.exists(tmp + "/" + YHaxen.FILENAME))
				File.copy(tmp + "/" + YHaxen.FILENAME, target);
			HaxelibHelper.deleteDirectory(tmp);
		}
		else
		{
			FileSystem.rename(source, target);
		}
	}

	function installSubdependencies(dependency:Dependency):Void
	{
		var directory:String = dependecyDirectory(dependency);
		
		var yhaxen:String = directory + "/" + YHaxen.FILENAME;
		if(FileSystem.exists(yhaxen))
			return installFromFile(yhaxen);
		
		var haxelib:String = directory + "/haxelib.json";
		if(FileSystem.exists(haxelib))
			return HaxelibHelper.resolveHaxelibJson(haxelib);
	}

	function dependecyDirectory(dependency:Dependency):String
	{
		return HaxelibHelper.getProjectVersionDirectory(dependency.name, dependency.version);
	}
	
	function dependencyExists(dependency:Dependency):Bool
	{
		return HaxelibHelper.projectExists(dependency.name, dependency.version);
	}

	function flattenDependencies(dependency:Dependency, result:Array<ProjectDependency>):Void
	{
		var directory:String = dependecyDirectory(dependency);
		var yhaxen:String = directory + "/" + YHaxen.FILENAME;
		if(FileSystem.exists(yhaxen))
			flattenFromFile(dependency, yhaxen, result);
		else
			HaxelibHelper.flattenDependencies(dependency.name, dependency.version, result);
	}
}