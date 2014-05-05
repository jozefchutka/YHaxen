package sk.yoz.yhaxen.parsers;

import sk.yoz.yhaxen.valueObjects.config.Root;

class YHaxenParser extends GenericParser<Root>
{
	override function parse(source:Dynamic):Root
	{
		var result:Root = new Root();
		if(!Reflect.hasField(source, "version"))
			throw "Missing version.";
		result.version = Reflect.field(source, "version");
		
		if(Reflect.hasField(source, "dependencies"))
			result.dependencies = new DependencyParser().parseList(Reflect.field(source, "dependencies"));
		return result;
	}
}