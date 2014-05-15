package sk.yoz.yhaxen.valueObject.dependency;

class Dependency
{
	public var name(default, null):String;
	public var version(default, null):String;
	public var metadata(default, null):Metadata;

	public var decoratedVersion(get, never):String;

	public function new(name:String, version:String)
	{
		metadata = new Metadata();

		this.name = name;
		this.version = version == "" ? null : version;
	}

	private function get_decoratedVersion():String
	{
		if(metadata.isDev)
			return "DEV";

		if(version == null)
			return "UNDEFINED";

		return version;
	}

	public function toString():String
	{
		return name + ":" + decoratedVersion;
	}
}