package yhaxen.valueObject.config;

class AbstractBuild extends AbstractStep
{
	/**
	 * Required
	 **/
	public var name:String;

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
	public var dir:String;

	/**
	 * Optional
	 **/
	public var mergeArguments:Bool;

	public function new(name:String, command:String)
	{
		this.name = name;
		this.command = command;
	}
}