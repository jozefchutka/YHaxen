package sk.yoz.yhaxen.parsers;

import sk.yoz.yhaxen.enums.SourceType;
import sk.yoz.yhaxen.parsers.GenericParser;
import sk.yoz.yhaxen.valueObjects.config.Dependency;

class DependencyParser extends GenericParser<Dependency>
{
	override function parse(source:Dynamic):Dependency
	{
		var result:Dependency = new Dependency();
		
		if(!Reflect.hasField(source, "name"))
			throw "Missing dependency name!";
		result.name = Reflect.field(source, "name");

		if(!Reflect.hasField(source, "version"))
			throw "Missing dependency version!";
		result.version = Reflect.field(source, "version");
		
		result.scope = Reflect.field(source, "scope");

		if(!Reflect.hasField(source, "source"))
			throw "Missing dependency source!";
		result.source = Reflect.field(source, "source");
		
		result.classPath = Reflect.field(source, "classPath");
		if(result.classPath == "")
			result.classPath = null;

		result.sourceType = Reflect.hasField(source, "sourceType")
			? GenericParser.parseEnum(SourceType, Reflect.field(source, "sourceType"))
			: SourceType.GIT;
		return result;
	}
}