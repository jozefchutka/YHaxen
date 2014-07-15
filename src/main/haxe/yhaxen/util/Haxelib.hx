package yhaxen.util;

import haxe.Json;

import sys.io.File;
import sys.FileSystem;

import tools.haxelib.Data;

class Haxelib extends tools.haxelib.Main
{
	inline public static var FILE_CURRENT:String = ".current";
	inline public static var FILE_HAXELIB:String = "haxelib.json";

	public static var instance(get, null):Haxelib;

	private var repositoryPath(get, never):String;

	static function get_instance():Haxelib
	{
		if(instance == null)
			instance = new Haxelib();
		return instance;
	}

	function get_repositoryPath():String
	{
		return StringTools.replace(getRepository(), "\\", "/");
	}

	public function getDependencyDirectory(name:String):String
	{
		return repositoryPath + Data.safe(name);
	}

	public function getDependencyCurrentVersion(name:String):String
	{
		return StringTools.trim(File.getContent(getDependencyDirectory(name) + "/.current"));
	}

	public function getDependencyIsDev(name:String):Bool
	{
		return FileSystem.exists(getDependencyDirectory(name) + "/.dev");
	}

	public function getDependencyVersionDirectory(name:String, version:String, isDev:Bool):String
	{
		var directory = getDependencyDirectory(name);
		if(isDev)
			return getDev(directory);
		if(version == null)
			return null;
		return directory + "/" + Data.safe(version);
	}

	public function getDependencyClassPath(name:String, version:String, isDev:Bool):String
	{
		var directory = getDependencyVersionDirectory(name, version, isDev);
		var data = getDependencyData(directory);
		return (data == null || data.classPath == null) ? directory : (directory + "/" + data.classPath);
	}

	public function getDependencyData(directory:String):Infos
	{
		var haxelibFile:String = directory + "/" + Haxelib.FILE_HAXELIB;
		return FileSystem.exists(haxelibFile) ? Data.readData(File.getContent(haxelibFile), false) : null;
	}

	public function dependencyExists(name:String):Bool
	{
		var dir = getDependencyDirectory(name);
		return FileSystem.exists(dir) && FileSystem.isDirectory(dir) && FileSystem.exists(dir + "/.current");
	}

	public function dependencyVersionExists(name:String, version:String):Bool
	{
		var dir = getDependencyVersionDirectory(name, version, false);
		return FileSystem.exists(dir) && FileSystem.isDirectory(dir);
	}

	public function removeDependencyVersion(name:String, version:String):Void
	{
		var directory = getDependencyVersionDirectory(name, version, false);
		System.deleteDirectory(directory);
	}

	public function updateHaxelibFile(file:String, version:String, dependencies:Dynamic, releasenote:String):Bool
	{
		if(!FileSystem.exists(file) || FileSystem.isDirectory(file))
			return false;

		var content = File.getContent(file);
		var json = Json.parse(content);

		json.version = version;
		json.dependencies = dependencies;
		if(releasenote != null || releasenote != "")
			json.releasenote = releasenote;

		var result = JsonPrinter.print(json, null, "\t");

		File.saveContent(file, result);
		return true;
	}

	public function getGitDependencyDirectory(name:String):String
	{
		return getDependencyDirectory(name) + "/git";
	}
}