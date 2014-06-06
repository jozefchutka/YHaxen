package yhaxen.parser;

import yhaxen.valueObject.config.Variable;
import yhaxen.valueObject.Error;

class VariableParser extends GenericParser<Variable>
{
	public var configFile:String;

	override function parse(source:Dynamic):Variable
	{
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
		return new Variable(name, value);
	}
}