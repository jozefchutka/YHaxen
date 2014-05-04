package sk.yoz.yhaxen.parsers;

import sk.yoz.yhaxen.valueObjects.config.YHaxen;

class YHaxenParser extends GenericParser<YHaxen>
{
	override function parse(source:Dynamic):YHaxen
	{
		var result:YHaxen = new YHaxen();
		if(!Reflect.hasField(source, "version"))
			throw "Missing version.";
		result.version = Reflect.field(source, "version");
		
		if(Reflect.hasField(source, "dependencies"))
			result.dependencies = new DependencyParser().parseList(Reflect.field(source, "dependencies"));
		return result;
	}
}