package sk.yoz.yhaxen.helpers;

import sk.yoz.yhaxen.valueObjects.DependencyTreeItem;
import sys.io.File;
import sys.FileSystem;
import tools.haxelib.Data;

class HaxelibHelper extends tools.haxelib.Main
{
	private static var haxelib(get, null):tools.haxelib.Main;

	private static function get_haxelib():tools.haxelib.Main
	{
		if(haxelib == null)
			haxelib = new tools.haxelib.Main();
		return haxelib;
	}

	public static function getProjectDirectory(name:String):String
	{
		return haxelib.getRepository() + Data.safe(name);
	}

	public static function getCurrentVersion(name:String):String
	{
		try
		{
			return haxelib.getCurrent(haxelib.getRepository() + Data.safe(name));
		}
		catch(error:Dynamic)
		{
			return null;
		}
	}

	public static function getProjectVersionDirectory(name:String, version:String):String
	{
		if(version == null)
			version = getCurrentVersion(name);
		if(version == null)
			return null;
		return getProjectDirectory(name) + "/" + Data.safe(version);
	}

	public static function projectExists(name:String, version:String):Bool
	{
		var dir = getProjectVersionDirectory(name, version);
		if(dir == null)
			return false;

		return FileSystem.exists(dir) && FileSystem.isDirectory(dir);
	}

	public static function ensureDirectoryExists(dir:String):Bool
	{
		return haxelib.safeDir(dir);
	}

	public static function deleteDirectory(dir:String):Void
	{
		return haxelib.deleteRec(dir);
	}

	public static function resolveHaxelibJson(path:String):Void
	{
		if(!FileSystem.exists(path))
			return;

		var haxelibJson = File.getContent(path);
		var infos = Data.readData(haxelibJson, true);
		haxelib.doInstallDependencies(infos.dependencies);
	}
}