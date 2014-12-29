package yhaxen.parser;

import yhaxen.valueObject.config.Variable;
import yhaxen.valueObject.Error;

class VariableParser extends GenericParser<Variable>
{
	public var configFile:String;

	override function parse(source:Dynamic):Variable
	{
		checkUnexpectedFields(source, Variable);

		if(!Reflect.hasField(source, "name"))
			throw new Error(
				"Missing variable name!",
				"Variable definition is missing required name field.",
				"Provide variable name in " + configFile + ".");
		var name:String = Reflect.field(source, "name");

		if(!Reflect.hasField(source, "value"))
			throw new Error(
				"Missing variable value!",
				"Variable " + name + " is missing required value field.",
				"Provide variable value in " + configFile + ".");
		var value:String = Reflect.field(source, "value");

		var result = new Variable(name, value);

		if(Reflect.hasField(source, "modes"))
		{
			var modes:Array<String> = Reflect.field(source, "modes");
			if(modes != null && modes.length != 0)
				result.modes = modes;
		}

		return result;
	}
}