package yhaxen.valueObject.config;

class Variable
{
	/**
	 * Required
	 **/
	public var name:String;

	/**
	 * Required
	 **/
	public var value:String;

	public function new(name:String, value:String)
	{
		this.name = name;
		this.value = value;
	}
}