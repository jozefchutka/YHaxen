package sk.yoz.yhaxen.valueObjects;

class Command
{
	inline public static var KEY_DEPENDENCY_INSTALL:String = "dependency:install";
	inline public static var KEY_DEPENDENCY_REPORT:String = "dependency:report";
	inline public static var KEY_HELP:String = "help";

	public var key:String;
	public var info:String;
	public var usage:String;

	public function new(key:String, info:String, usage:String)
	{
		this.key = key;
		this.info = info;
		this.usage = usage;
	}
}