package yhaxen.valueObject.config;

import yhaxen.enums.ReleaseType;
import yhaxen.util.ScopeUtil;

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
		return ScopeUtil.matches(scopes, scope);
	}
}