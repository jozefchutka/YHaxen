package sk.yoz.yhaxen.valueObjects;

import StringTools;

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

	/**
	 * Haxelib use dev version
	 **/
	public var isDev:Bool;
	public var currentVersion:String;
	public var versionExists:Bool;
	public var currentVersionExists:Bool;
	public var exists:Bool;
	public var forcedVersion:String;
	public var forcedVersionExists:Bool;
	public var resolvedVersion:String;
	public var resolvedVersionExists:Bool;

	public var decoratedVersion(get, never):String;

	public function new(name:String, version:String)
	{
		this.name = name;
		this.version = version == "" ? null : version;
	}

	private function get_decoratedVersion():String
	{
		if(isDev)
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