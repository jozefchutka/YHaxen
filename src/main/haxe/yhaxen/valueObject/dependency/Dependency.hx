package yhaxen.valueObject.dependency;

import yhaxen.enums.DependencyVersionType;

class Dependency
{
	public var name(default, null):String;
	public var version(default, null):String;

	public var exists:Bool;
	public var versionType:DependencyVersionType;
	public var versionResolved:String;
	public var versionResolvedExists:Bool;

	public var decoratedVersion(get, never):String;

	public function new(name:String, version:String)
	{
		this.name = name;
		this.version = version == "" ? null : version;
		this.versionType = DependencyVersionType.REGULAR;
	}

	private function get_decoratedVersion():String
	{
		switch(versionType)
		{
			case DependencyVersionType.DEV:
				return "DEV";
			case DependencyVersionType.ANY:
				return "ANY";
			default:
				return version;
		}
	}

	public function toString():String
	{
		return name + ":" + decoratedVersion;
	}
}