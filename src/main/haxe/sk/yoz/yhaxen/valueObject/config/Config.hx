package sk.yoz.yhaxen.valueObject.config;

class Config
{
	public static inline var DEFAULT_FILENAME:String = "yhaxen.json";

	/**
	 * Required
	 **/
	public var version:Int;

	/**
	 * Optional
	 **/
	public var dependencies:Array<DependencyDetail>;

	public function new(){}
}