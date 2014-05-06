package sk.yoz.yhaxen.valueObjects;

import StringTools;

class Dependency
{
	inline public static var CURRENT_VERSION:String = null;
	inline static var DECORATED_CURRENT_VERSION:String = "<CURRENT>";

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
		if(version == null)
			this.version = CURRENT_VERSION;
		else
			this.version = StringTools.trim(version) == "" ? CURRENT_VERSION : version;
	}

	private function get_decoratedVersion():String
	{
		return decorateVersion(version);
	}

	public static function decorateVersion(version:String):String
	{
		return version == CURRENT_VERSION ? DECORATED_CURRENT_VERSION : version;
	}

	public static function undecorateVersion(version:String):String
	{
		return version == DECORATED_CURRENT_VERSION ? CURRENT_VERSION : version;
	}

	public function versionIsCurrent():Bool
	{
		return version == CURRENT_VERSION;
	}

	public function toString():String
	{
		return name + ":" + decoratedVersion;
	}


}