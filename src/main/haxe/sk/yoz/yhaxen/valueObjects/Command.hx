package sk.yoz.yhaxen.valueObjects;

class Command
{
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