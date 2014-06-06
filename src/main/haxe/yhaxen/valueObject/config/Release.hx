package yhaxen.valueObject.config;

import yhaxen.enums.ReleaseType;

class Release extends AbstractStep
{
	/**
	 * Required
	 **/
	public var type:ReleaseType;

	/**
	 * Optional
	 **/
	public var files:Array<String>;

	public function new(type:ReleaseType)
	{
		this.type = type;
	}
}