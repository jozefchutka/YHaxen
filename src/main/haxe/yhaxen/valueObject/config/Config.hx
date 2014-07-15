package yhaxen.valueObject.config;

class Config
{
	inline public static var DEFAULT_FILENAME:String = "yhaxen.json";

	/**
	 * Optional
	 **/
	public var variables:Array<Variable>;

	/**
	 * Optional
	 **/
	public var dependencies:Array<Dependency>;

	/**
	 * Optional
	 **/
	public var tests:Array<Test>;

	/**
	 * Optional
	 **/
	public var builds:Array<Build>;

	/**
	 * Optional
	 **/
	public var releases:Array<Release>;

	public function new()
	{
	}

	public function getTest(name:String):Test
	{
		if(tests != null)
			for(test in tests)
				if(test.name == name)
					return test;
		return null;
	}

	public function getBuild(name:String):Build
	{
		if(builds != null)
			for(build in builds)
				if(build.name == name)
					return build;
		return null;
	}

	public function getBuildScopes():Array<String>
	{
		if(builds == null || builds.length == 0)
			return null;

		var result:Array<String> = [];
		for(build in builds)
			result.push(build.name);
		return result;
	}
}