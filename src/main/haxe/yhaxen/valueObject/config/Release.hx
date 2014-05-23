package yhaxen.valueObject.config;

import yhaxen.enums.ReleaseType;

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