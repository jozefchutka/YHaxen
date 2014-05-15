package sk.yoz.yhaxen.parser;

import sk.yoz.yhaxen.valueObject.config.Config;

class ConfigParser extends GenericParser<Config>
{
	override function parse(source:Dynamic):Config
	{
		var result:Config = new Config();
		if(!Reflect.hasField(source, "version"))
			throw "Missing version.";
		result.version = Reflect.field(source, "version");
		
		if(Reflect.hasField(source, "dependencies"))
			result.dependencies = new DependencyParser().parseList(Reflect.field(source, "dependencies"));
		return result;
	}
}