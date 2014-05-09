package sk.yoz.yhaxen.helpers;

import sk.yoz.yhaxen.valueObjects.Dependency;
import sys.io.File;
import sys.FileSystem;

import tools.haxelib.Data;

class HaxelibHelper extends tools.haxelib.Main
{
	inline public static var FILE_CURRENT:String = ".current";
	inline public static var FILE_HAXELIB:String = "haxelib.json";

	private var repositoryPath(get, never):String;
	private var resolveHaxelibJsonPending:Bool = false;

	public function new()
	{
		super();
	}

	private function get_repositoryPath():String
	{
		return getRepository();
	}

	public function getProjectDirectory(name:String):String
	{
		return repositoryPath + Data.safe(name);
	}

	public function getCurrentVersion(name:String):String
	{
		return StringTools.trim(File.getContent(getProjectDirectory(name) + "/.current"));
	}

	public function isDev(name:String):Bool
	{
		return FileSystem.exists(getProjectDirectory(name) + "/.dev");
	}

	public function getVersionDirectory(name:String, version:String, isDev:Bool, currentVersion:String):String
	{
		var projectDirectory = getProjectDirectory(name);
		if(isDev)
			return getDev(projectDirectory);

		if(version == null)
			return projectDirectory + "/" + Data.safe(currentVersion);

		return projectDirectory + "/" + Data.safe(version);
	}

	public function versionExists(name:String, version:String):Bool
	{
		var dir = getVersionDirectory(name, version, false, null);
		return FileSystem.exists(dir) && FileSystem.isDirectory(dir);
	}

	public function ensureDirectoryExists(dir:String):Bool
	{
		return safeDir(dir);
	}

	public function deleteDirectory(dir:String):Void
	{
		return deleteRec(dir);
	}

	public function resolveHaxelibJson(path:String):Void
	{
		if(!FileSystem.exists(path))
			return;

		resolveHaxelibJsonPending = true;
		var haxelibJson = File.getContent(path);
		var infos = Data.readData(haxelibJson, false);
		doInstallDependencies(infos.dependencies);
		resolveHaxelibJsonPending = false;
	}

	/**
	 * Lets ignore "set current" question while resolving subdependencies.
	 **/
	override function setCurrent(prj:String, version:String, doAsk:Bool)
	{
		if(!resolveHaxelibJsonPending)
			setCurrent(prj, version, doAsk);
	}
}