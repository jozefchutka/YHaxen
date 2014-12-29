package yhaxen.valueObject.config;

import yhaxen.util.ModeUtil;

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

	/**
	 * Optional
	 **/
	public var modes:Array<String>;

	public function new(name:String, value:String)
	{
		this.name = name;
		this.value = value;
	}

	public function matchesMode(mode:String):Bool
	{
		return ModeUtil.matches(modes, mode);
	}
}