package yhaxen.util;

class ScopeUtil
{
	public static function matches(scopes:Array<String>, scope:String):Bool
	{
		return (scope == null || scopes == null) ? true : Lambda.has(scopes, scope);
	}
}