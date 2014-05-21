package sk.yoz.yhaxen.valueObject.config;

import sk.yoz.yhaxen.enums.ReleaseType;

class Release
{
	/**
	 * Required
	 **/
	public var type:ReleaseType;

	/**
	 * Optional
	 **/
	public var files:Array<String>;

	/**
	 * Optional
	 **/
	public var scopes:Array<String>;

	public function new(type:ReleaseType)
	{
		this.type = type;
	}

	public function matchesScope(scope:String):Bool
	{
		return (scope == null || scopes == null) ? true : Lambda.has(scopes, scope);
	}
}