package sk.yoz.yhaxen.resolvers;

import sk.yoz.yhaxen.helpers.HaxelibHelper;
import sk.yoz.yhaxen.helpers.HaxelibHelper;
import sk.yoz.yhaxen.valueObjects.Dependency;

import sys.FileSystem;

class DependencyResolver
{
	public function new(){}

	public function resolve(data:Dependency)
	{
		print("----------------------------------------------------------");
		
		if(HaxelibHelper.projectExists(data.name, data.version))
		{
			print("# " + data.name + ":" + data.version + " - OK");
			return;
		}
		print("# RESOLVING " + data.name + ":" + data.version);

		var tmp:String = "tmp";
		FileSystem.createDirectory(tmp);
		Sys.command("git", ["clone", data.source, tmp, "-b", data.version, "--single-branch"]);
		HaxelibHelper.deleteDirectory(tmp + "/.git");
		HaxelibHelper.ensureDirectoryExists(HaxelibHelper.getProjectDirectory(data.name));
		
		var target:String = HaxelibHelper.getProjectVersionDirectory(data.name, data.version);
		var source:String = tmp;
		if(data.classPath != "" && data.classPath != null)
		{
			FileSystem.rename(source + "/" + data.classPath, target);
			HaxelibHelper.deleteDirectory(tmp);
		}
		else
		{
			FileSystem.rename(source, target);
		}
		
		
		// haxelib git creates git repository inside haxelib and keep only one version
		//Sys.command("haxelib", ["git", data.name, data.source, data.version, data.classPath]);

		HaxelibHelper.resolveHaxelibJson(target + "/haxelib.json");
	}

	private function print(message:String):Void
	{
		Sys.print(message + "\n");
	}
}