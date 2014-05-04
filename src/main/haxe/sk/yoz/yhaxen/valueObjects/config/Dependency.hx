package sk.yoz.yhaxen.valueObjects.config;

import sk.yoz.yhaxen.enums.SourceType;

class Dependency
{
	/**
	 * Required
	 **/
	public var name:String;

	/**
	 * Required
	 **/
	public var version:String;

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

	public function new(){}

	public function toString():String
	{
		return name + ":" + version;
	}
}