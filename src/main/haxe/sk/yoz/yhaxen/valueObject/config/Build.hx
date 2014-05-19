package sk.yoz.yhaxen.valueObject.config;

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

	public function new(name:String, artifact:String, command:String)
	{
		this.name = name;
		this.artifact = artifact;
		this.command = command;
	}
}