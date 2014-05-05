package sk.yoz.yhaxen.valueObjects;

class Dependency
{
	/**
	 * Required
	 **/
	public var name(default, null):String;

	/**
	 * Required
	 **/
	public var version(default, null):String;

	public var decoratedVersion(get, never):String;

	public function new(name:String, version:String)
	{
		this.name = name;
		this.version = version == "" ? null : version;
	}

	private function get_decoratedVersion():String
	{
		return version == null ? "<NULL>" : version;
	}

	public function toString():String
	{
		return name + ":" + decoratedVersion;
	}
}