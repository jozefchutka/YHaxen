package yhaxen.parser;

import yhaxen.valueObject.config.Test;
import yhaxen.valueObject.Error;

class TestParser extends GenericParser<Test>
{
	public var configFile:String;

	override function parse(source:Dynamic):Test
	{
		checkUnexpectedFields(source, Test);

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
		var dir:String = Reflect.field(source, "dir");

		var result:Test = new Test(name, command);
		result.arguments = Reflect.field(source, "arguments");
		result.dir = dir;
		return result;
	}

	override function parseList(source:Array<Dynamic>):Array<Test>
	{
		var result = super.parseList(source);

		var names:Array<String> = [];
		for(test in result)
		{
			if(Lambda.has(names, test.name))
				throw new Error(
					"Misconfigured test " + test.name + "!",
					"Test " + test.name + " is defined multiple times.",
					"Provide only one definition for " + test.name + " in " + configFile + ".");

			names.push(test.name);
		}

		return result;
	}
}