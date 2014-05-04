package sk.yoz.yhaxen.valueObjects.config;

class YHaxen
{
	public static inline var FILENAME:String = "yhaxen.json";

	/**
	 * Required
	 **/
	public var version:Int;

	/**
	 * Optional
	 **/
	public var dependencies:Array<Dependency>;

	public function new(){}
}