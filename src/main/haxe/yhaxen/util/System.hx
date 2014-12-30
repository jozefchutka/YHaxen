package yhaxen.util;

import haxe.io.Path;
import haxe.macro.Context;

import sys.io.File;
import sys.io.Process;
import sys.FileSystem;

class System
{
	public static function print(message:String):Void
	{
		Sys.println(message);
	}

	public static function command(cmd:String, args:Array<String>):Int
	{
		return Sys.command(cmd, args);
	}

	public static function process(cmd:String, args:Array<String>):Process
	{
		return new Process(cmd, args);
	}

	public static function deleteDirectory(dir:String):Void
	{
		for(item in FileSystem.readDirectory(dir))
		{
			var path = dir + "/" + item;
			if(FileSystem.isDirectory(path))
				deleteDirectory(path);
			else
				deleteFile(path);
		}
		FileSystem.deleteDirectory(dir);
	}

	public static function deleteFile(file:String):Bool
	{
		try
		{
			FileSystem.deleteFile(file);
			return true;
		}
		catch(e:Dynamic)
		{
			if(Sys.systemName() == "Windows")
			{
				try
				{
					Sys.command("attrib -R \"" +file+ "\"");
					FileSystem.deleteFile(file);
					return true;
				}
				catch(e:Dynamic){}
			}
			return false;
		}
	}

	public static function createDirectory(dir:String):Bool
	{
		if(FileSystem.exists(dir) && !FileSystem.isDirectory(dir))
			throw ("A file is preventing " + dir + " to be created!");

		try
		{
			FileSystem.createDirectory(dir);
		}
		catch(error:Dynamic)
		{
			throw "You don't have enough user rights to create the directory " + dir + "!";
		}
		return true;
	}

	public static function copyDirectory(source:String, target:String):Void
	{
		if(!FileSystem.exists(target))
			createDirectory(target);
		else if(!FileSystem.isDirectory(target))
			throw "Target " + target + " is not a directory";

		for(item in FileSystem.readDirectory(source))
		{
			var sourcePath = source + "/" + item;
			var targetPath = target + "/" + item;
			if(FileSystem.isDirectory(sourcePath))
				copyDirectory(sourcePath, targetPath);
			else
				File.copy(sourcePath, targetPath);
		}
	}

	/**
	 * Check if the last argument is a current working directory passed in by haxeLib.
	 * If so update cwd and pass back args without that argument.
	 **/
	public static function fixCwd():Array<String>
	{
		var args = Sys.args();
		if(args.length == 0)
			return args;

		var last:String = (new Path(args[args.length - 1])).toString();
		var slash = last.substr(-1);
		if(slash == "/" || slash == "\\")
			last = last.substr(0, last.length-1);

		if(!FileSystem.exists(last) || !FileSystem.isDirectory(last))
			return args;

		Sys.setCwd(last);
		args.pop();
		return args;
	}

	public static function getVersion():String
	{
		return getCompilerVariable("version");
	}

	public static function formatCommandLineArguments(source:Array<String>):String
	{
		if(source == null)
			return "";

		var result:Array<String> = [];
		for(item in source)
			result.push(formatCommandLineArgument(item));
		return result.join(" ");
	}

	static function formatCommandLineArgument(source:String):String
	{
		if(source.indexOf(" ") != -1)
			source = "\"" + source + "\"";
		return source;
	}

	macro public static function getCompilerVariable(key:String)
	{
		return Context.makeExpr(Context.definedValue(key), Context.currentPos());
	}

	macro public static function getBuildDate()
	{
		return Context.makeExpr(Date.now().toString(), Context.currentPos());
	}
}