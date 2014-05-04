package sk.yoz.yhaxen.valueObjects;

class Command
{
	public var key:String;
	public var info:String;

	public function new(key:String, info:String)
	{
		this.key = key;
		this.info = info;
	}
}