package sk.yoz.yhaxen.valueObjects.config;

class Root
{
	public static inline var FILENAME:String = "yhaxen.json";

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