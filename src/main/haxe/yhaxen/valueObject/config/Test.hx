package yhaxen.valueObject.config;

class Test
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

	public function new(name:String, command:String)
	{
		this.name = name;
		this.command = command;
	}
}