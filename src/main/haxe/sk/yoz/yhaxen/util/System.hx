package sk.yoz.yhaxen.util;

import sys.FileSystem;
import haxe.io.Path;

import sys.io.Process;

class System
{
	public static function printRow(fill:String, message:String=null):Void
	{
		print(StringTools.rpad(message == null ? "" : message, fill, 79));
	}

	public static function print(message:String):Void
	{
		Sys.println(message);
	}

	public static function printKeyVal(key:String, pad:Int, value:String):Void
	{
		Sys.println(StringTools.rpad(key, " ", pad) + value);
	}

	public static function command(cmd:String, args:Array<String>):Int
	{
		print("  $ " + cmd + " " + args.join(" "));
		return Sys.command(cmd, args);
	}

	public static function process(cmd:String, args:Array<String>):Process
	{
		print("  $ " + cmd + " " + args.join(" "));
		return new Process(cmd, args);
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
}