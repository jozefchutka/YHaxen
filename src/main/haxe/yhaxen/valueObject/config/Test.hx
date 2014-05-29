package yhaxen.valueObject.config;

import yhaxen.util.ScopeUtil;

class Test
{
	/**
	 * Required
	 **/
	public var command:String;

	/**
	 * Optional
	 **/
	public var arguments:Array<String>;

	/**
	 * Optional
	 **/
	public var scopes:Array<String>;

	public function new(command:String)
	{
		this.command = command;
	}

	public function matchesScope(scope:String):Bool
	{
		return ScopeUtil.matches(scopes, scope);
	}
}