package sk.yoz.yhaxen.helpers;

import sys.io.File;
import sys.FileSystem;
import tools.haxelib.Data;

class HaxelibHelper extends tools.haxelib.Main
{
	public static function getProjectDirectory(name:String):String
	{
		return new tools.haxelib.Main().getRepository() + Data.safe(name);
	}

	public static function getProjectVersionDirectory(name:String, version:String):String
	{
		return getProjectDirectory(name) + "/" + Data.safe(version);
	}

	public static function projectExists(name:String, version:String):Bool
	{
		var dir = getProjectVersionDirectory(name, version);
		return FileSystem.exists(dir) && FileSystem.isDirectory(dir);
	}

	public static function ensureDirectoryExists(dir:String):Bool
	{
		return new tools.haxelib.Main().safeDir(dir);
	}

	public static function deleteDirectory(dir:String):Void
	{
		return new tools.haxelib.Main().deleteRec(dir);
	}

	public static function resolveHaxelibJson(path:String):Void
	{
		if(!FileSystem.exists(path))
			return;

		var haxelibJson = File.getContent(path);
		var infos = Data.readData(haxelibJson, true);
		new tools.haxelib.Main().doInstallDependencies(infos.dependencies);
	}
}