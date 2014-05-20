package sk.yoz.yhaxen.valueObject.config;

class Config
{
	inline public static var DEFAULT_FILENAME:String = "yhaxen.json";

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

	/**
	 * Optional
	 **/
	public var releases:Array<Release>;

	public function new(version:Int)
	{
		this.version = version;
	}
}