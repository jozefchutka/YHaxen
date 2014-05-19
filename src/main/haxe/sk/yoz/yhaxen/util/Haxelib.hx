package sk.yoz.yhaxen.util;

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
		return getRepository();
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

	public function makeDirectory(dir:String):Bool
	{
		return safeDir(dir);
	}

	public function deleteDirectory(dir:String):Void
	{
		return deleteRec(dir);
	}
}