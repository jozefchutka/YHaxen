package yhaxen.parser;

import yhaxen.valueObject.config.Build;
import yhaxen.valueObject.Error;

class BuildParser extends GenericParser<Build>
{
	public var configFile:String;

	override function parse(source:Dynamic):Build
	{
		if(!Reflect.hasField(source, "name"))
			throw new Error(
				"Missing build name!",
				"Build definition is missing required name field.",
				"Provide build name in " + configFile + ".");

		var name:String = Reflect.field(source, "name");
		if(!Reflect.hasField(source, "command"))
			throw new Error(
				"Missing build command!",
				"Build " + name + " is missing required command field.",
				"Provide build command in " + configFile + ".");

		var command:String = Reflect.field(source, "command");
		var dir:String = Reflect.field(source, "dir");

		var result:Build = new Build(name, command);
		result.arguments = Reflect.field(source, "arguments");
		result.dir = dir;
		return result;
	}
}