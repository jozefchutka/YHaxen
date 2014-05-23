package yhaxen.valueObject;

class Command
{
	inline public static var KEY_VALIDATE:String = "validate";
	inline public static var KEY_COMPILE:String = "compile";
	inline public static var KEY_RELEASE:String = "release";
	inline public static var KEY_HELP:String = "help";

	public var key:String;
	public var info:String;

	public function new(key:String, info:String)
	{
		this.key = key;
		this.info = info;
	}
}