package yhaxen.valueObject.config;

class Config
{
	inline public static var DEFAULT_FILENAME:String = "yhaxen.json";

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
	public var tests:Array<Test>;

	/**
	 * Optional
	 **/
	public var releases:Array<Release>;

	public function new()
	{
	}
}