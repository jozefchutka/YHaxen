package sk.yoz.yhaxen.parsers;

import sk.yoz.yhaxen.enums.SourceType;
import sk.yoz.yhaxen.parsers.GenericParser;
import sk.yoz.yhaxen.valueObjects.Dependency;

class DependencyParser extends GenericParser<Dependency>
{
	override function parse(source:Dynamic):Dependency
	{
		var result:Dependency = new Dependency();
		result.name = Reflect.field(source, "name");
		result.version = Reflect.field(source, "version");
		result.scope = Reflect.field(source, "scope");
		result.source = Reflect.field(source, "source");
		result.classPath = Reflect.field(source, "classPath");
		result.sourceType = GenericParser.parseEnum(SourceType, Reflect.field(source, "sourceType"));
		return result;
	}
}