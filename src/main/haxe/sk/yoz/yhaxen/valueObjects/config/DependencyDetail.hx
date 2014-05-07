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

	/**
	 * Optional
	 **/
	public var installDependencies:Bool = true;

	public function new(name:String, version:String, source:String)
	{
		super(name, version);
		this.source = source;
	}

	public function matchesScope(scope:String):Bool
	{
		if(scope == null)
			return true;
		if(this.scope == null || this.scope.length == 0)
			return false;
		return Lambda.has(this.scope, scope);
	}
}