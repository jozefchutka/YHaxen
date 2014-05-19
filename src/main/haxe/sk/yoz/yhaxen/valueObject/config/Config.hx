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

	/**
	 * Optional
	 **/
	public var builds:Array<Build>;

	public function new(version:Int)
	{
		this.version = version;
	}
}