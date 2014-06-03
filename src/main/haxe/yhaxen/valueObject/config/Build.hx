package yhaxen.valueObject.config;

class Build
{
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
	public var dir:String;

	public function new(name:String, artifact:String, command:String)
	{
		this.name = name;
		this.artifact = artifact;
		this.command = command;
	}
}