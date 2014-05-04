package sk.yoz.yhaxen.helpers;

import sk.yoz.yhaxen.valueObjects.ProjectDependency;
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

	public static function flattenDependencies(name:String, version:String, result:Array<ProjectDependency>):Void
	{
		var path:String = getProjectVersionDirectory(name, version) + "/haxelib.json";
		if(!FileSystem.exists(path))
			return null;

		var haxelibJson = File.getContent(path);
		var list = Data.readData(haxelibJson, false);
		for(item in list.dependencies)
		{
			if(item.version == "")
				item.version = "0.0.1";
			result.push({parent:name, name:item.project, version:item.version});
			flattenDependencies(item.project, item.version, result);
		}
	}
}