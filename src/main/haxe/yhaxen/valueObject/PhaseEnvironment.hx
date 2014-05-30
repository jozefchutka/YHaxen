package yhaxen.valueObject;

import yhaxen.valueObject.config.Build;
import yhaxen.valueObject.config.DependencyDetail;
import yhaxen.valueObject.config.Release;
import yhaxen.valueObject.config.Test;

class PhaseEnvironment
{
	public var dependency:DependencyDetail;
	public var build:Build;
	public var test:Test;
	public var release:Release;

	public var scope(get, never):String;

	public function new(){}

	function get_scope():String
	{
		if(build != null)
			return build.name;
		if(test != null)
			return test.name;
		return null;
	}
}