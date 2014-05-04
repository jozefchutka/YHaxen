package sk.yoz.yhaxen.parsers;

import sk.yoz.yhaxen.valueObjects.YHaxen;

class YHaxenParser extends GenericParser<YHaxen>
{
	override function parse(source:Dynamic):YHaxen
	{
		var result:YHaxen = new YHaxen();
		result.version = Reflect.field(source, "version");
		result.dependencies = new DependencyParser().parseList(Reflect.field(source, "dependencies"));
		return result;
	}
}