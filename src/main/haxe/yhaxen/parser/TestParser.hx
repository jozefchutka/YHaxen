package yhaxen.parser;

import yhaxen.valueObject.config.Test;
import yhaxen.valueObject.Error;

class TestParser extends GenericParser<Test>
{
	public var configFile:String;

	override function parse(source:Dynamic):Test
	{
		if(!Reflect.hasField(source, "name"))
			throw new Error(
				"Missing test name!",
				"Test definition is missing required name field.",
				"Provide test name in " + configFile + ".");

		var name:String = Reflect.field(source, "name");
		if(!Reflect.hasField(source, "command"))
			throw new Error(
				"Missing test command!",
				"Test " + name + " is missing required command field.",
				"Provide test command in " + configFile + ".");

		var command:String = Reflect.field(source, "command");

		var result:Test = new Test(name, command);
		result.arguments = Reflect.field(source, "arguments");
		return result;
	}
}