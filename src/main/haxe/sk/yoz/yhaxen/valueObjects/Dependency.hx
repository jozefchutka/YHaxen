package sk.yoz.yhaxen.valueObjects;

import sk.yoz.yhaxen.enums.SourceType;

class Dependency
{
	public var name:String;
	public var version:String;
	public var source:String;
	public var sourceType:SourceType;
	public var classPath:String;
	public var scope:Array<String>;

	public function new(){}
}