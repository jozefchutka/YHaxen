package yhaxen.parser;

import yhaxen.valueObject.config.Test;
import yhaxen.valueObject.Error;

class TestParser extends GenericParser<Test>
{
	public var configFile:String;

	override function parse(source:Dynamic):Test
	{
		if(!Reflect.hasField(source, "command"))
			throw new Error(
				"Missing test command!",
				"Test is missing required command field.",
				"Provide test command in " + configFile + ".");

		var command:String = Reflect.field(source, "command");

		var result:Test = new Test(command);
		result.arguments = Reflect.field(source, "arguments");
		result.scopes = Reflect.field(source, "scopes");
		return result;
	}
}