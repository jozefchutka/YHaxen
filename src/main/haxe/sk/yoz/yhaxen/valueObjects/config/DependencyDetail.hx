package sk.yoz.yhaxen.valueObjects.config;

import sk.yoz.yhaxen.enums.SourceType;

class DependencyDetail extends Dependency
{
	/**
	 * Required
	 **/
	public var source:String;

	/**
	 * Optional, defaults to GIT
	 **/
	public var sourceType:SourceType;

	/**
	 * Optional
	 **/
	public var classPath:String;

	/**
	 * Optional
	 **/
	public var scope:Array<String>;

	public function new(name:String, version:String, source:String)
	{
		super(name, version);
		this.source = source;
	}
}