package sk.yoz.yhaxen.valueObject.dependency;

class Version
{
	public var key:String;
	public var exists:Bool;

	public function new(key:String, exists:Bool=false)
	{
		this.key = key;
		this.exists = exists;
	}

	public function clone()
	{
		return new Version(key, exists);
	}
}