package yhaxen.valueObject.config;

class Build
{
	inline public static var ARGUMENT_ARTIFACT:String = "${artifact}";
	inline public static var ARGUMENT_DEPENDENCIES:String = "${dependencies}";

	/**
	 * Required
	 **/
	public var name:String;

	/**
	 * Required
	 **/
	public var artifact:String;

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

	public function new(name:String, artifact:String, command:String)
	{
		this.name = name;
		this.artifact = artifact;
		this.command = command;
	}

	public function matchesScope(scope:String):Bool
	{
		return (scope == null || scopes == null) ? true : Lambda.has(scopes, scope);
	}
}