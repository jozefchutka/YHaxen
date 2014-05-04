package sk.yoz.yhaxen.helpers;

class SysHelper
{
	public static function printCommand(title:String):Void
	{
		print(StringTools.rpad("- " + title + " ", "-", 79));
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
		print("$ " + cmd + " " + args.join(" "));
		return Sys.command(cmd, args);
	}
}