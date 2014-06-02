package yhaxen.util;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;

import tools.haxelib.Data;

class Haxelib extends tools.haxelib.Main
{
	inline public static var FILE_CURRENT:String = ".current";
	inline public static var FILE_HAXELIB:String = "haxelib.json";

	private var repositoryPath(get, never):String;

	public function new()
	{
		super();
	}

	private function get_repositoryPath():String
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

	public function updateHaxelibFile(file:String, version:String, releasenote:String):Bool
	{
		if(!FileSystem.exists(file) || FileSystem.isDirectory(file))
			return false;

		var content = File.getContent(file);
		var json = Json.parse(content);
		json.version = version;
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