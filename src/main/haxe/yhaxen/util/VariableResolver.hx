package yhaxen.util;

import yhaxen.enums.DependencyVersionType;
import yhaxen.util.Haxelib;
import yhaxen.valueObject.Error;
import yhaxen.valueObject.config.Dependency;
import yhaxen.valueObject.config.Variable;

class VariableResolver
{
	public var haxelib:Haxelib;
	public var configFile:String;
	public var log:Bool;
	public var variables:Array<Variable>;
	public var dependencies:Array<Dependency>;
	public var systemArguments:Array<String>;

	public function new(haxelib:Haxelib, configFile:String, log:Bool)
	{
		this.haxelib = haxelib;
		this.configFile = configFile;
		this.log = log;
	}

	public function variablesInArray(input:Array<String>):Array<String>
	{
		var result:Array<String> = [];
		for(item in input)
		{
			var resolvedResults = variablesInString(item);
			if(resolvedResults == null)
				result.push(item);
			else
				for(resolvedResult in resolvedResults)
					result.push(resolvedResult);
		}
		return result;
	}

	public function variablesInString(input:String):Array<String>
	{
		if(input == null)
			return null;

		if(input.indexOf("$" + "{") == -1)
			return [input];

		print("resolving variable in \"" + input + "\"");

		var variableEReg:EReg = ~/\$\{([^}]+?)\}/;
		variableEReg.match(input);
		var pos = variableEReg.matchedPos();
		var matched:String = variableEReg.matched(1);
		if(matched == null)
			throw new Error(
				"Invalid variable used!",
				"Parser is not able to match variable in \"" + input + "\".",
				"Make sure the variable is defined properly.");

		var result:Array<String> = [];
		var resolvedResults = variable(matched);
		if(resolvedResults == null)
		{
			print("  -> emtpy value");
		}
		else
		{
			var prefix:String = input.substr(0, pos.pos);
			var postfix:String = input.substr(pos.pos + pos.len);
			for(resolvedResult in resolvedResults)
			{
				var fixedResult = prefix + resolvedResult + postfix;
				result.push(fixedResult);
				print("  -> " + fixedResult);
			}
		}
		print("");
		return result;
	}

	public function variable(input:String):Array<String>
	{
		var flag:String;
		var chunks = input.split("|");
		var name = chunks.shift();
		var fallback = chunks.join("|");

		try
		{
			flag = "system:cwd";
			if(name == flag)
				return [Sys.getCwd()];

			flag = "arg:";
			if(StringTools.startsWith(name, flag))
				return variableArg(name.substr(flag.length));

			flag = "dependency:";
			if(StringTools.startsWith(name, flag))
				return variableDependency(name.substr(flag.length));

			flag = "variable:";
			if(StringTools.startsWith(name, flag))
				return variableVariable(name.substr(flag.length));

			throw new Error(
				"Invalid variable $" + "{" + name + "}",
				"Variable definition is unknown.",
				"Make sure the variable is defined properly.");
		}
		catch(error:Dynamic)
		{
			if(fallback != "")
				return variable(fallback);
			throw error;
		}
	}

	public function variableArg(input:String):Array<String>
	{
		var name = input;
		var result:Array<String> = [];
		var length = systemArguments == null ? 0 : systemArguments.length;
		for(i in 0...length)
			if(systemArguments[i] == name && i < length)
				result.push(systemArguments[i + 1]);

		if(result.length == 0)
			throw new Error(
				"Invalid argument " + name + "!",
				"Argument " + name + " is not available in command.",
				"Provide command argument via command line (e.g. for ${arg.version} use \"version 123\").");

		return result;
	}

	public function variableDependency(input:String):Array<String>
	{
		var chunks = input.split(":");
		var name = chunks.shift();
		var dependencies:Array<Dependency> = (name == "*") ? this.dependencies : [getDependencyByName(name)];
		if(dependencies == null)
			return null;

		var type = chunks.shift();
		var data = chunks.join(":");
		var result:Array<String> = [];
		for(dependency in dependencies)
		{
			if(dependency == null)
				throw new Error(
					"Invalid dependency " + name + "!",
					"Dependency " + name + " is not defined in " + configFile + ".",
					"Provide existing dependency name.");

			if(data != "")
				result.push(data);

			switch(type)
			{
				case "dir":
					result.push(variableDependencyDir(dependency));
				case "name":
					result.push(dependency.name);
				case "version":
					result.push(dependency.version);
				case "nameVersion":
					result.push(dependency.name + ":" + dependency.version);
				case "classPath":
					result.push(variableDependencyClassPath(dependency));
				default:
					throw new Error(
						"Invalid variable $" + "{dependency:" + input + "}!",
						"Variable definition type \"" + type + "\" is unknown.",
						"Make sure the variable is defined properly.");
			}
		}

		return result.length == 0 ? null : result;
	}

	public function variableDependencyDir(dependency:Dependency):String
	{
		var dir:String;
		try
		{
			var type = dependency.useCurrent ? DependencyVersionType.CURRENT : null;
			dir = haxelib.getDependencyVersionDirectory(dependency.name, dependency.version, type);
		}
		catch(error:Dynamic)
		{
			dir = haxelib.getDependencyVersionDirectory(dependency.name, dependency.version, null);
		}
		return dir;
	}

	public function variableDependencyClassPath(dependency:Dependency):String
	{
		var dir:String;
		try
		{
			var type = dependency.useCurrent ? DependencyVersionType.CURRENT : null;
			dir = haxelib.getDependencyClassPath(dependency.name, dependency.version, type);
		}
		catch(error:Dynamic)
		{
			dir = haxelib.getDependencyClassPath(dependency.name, dependency.version, null);
		}
		return dir;
	}

	public function variableVariable(input:String):Array<String>
	{
		var name = input;
		if(name == "")
			throw new Error(
				"Invalid variable $" + "{variable:" + input + "}!",
				"Variable has empty name defined.",
				"Provide proper variable name.");

		if(variables != null)
			for(variable in variables)
				if(variable.name == name)
					return [variable.value];

		throw new Error(
			"Invalid variable $" + "{variable:" + input + "}!",
			"Variable " + name + " is not defined in " + configFile + ".",
			"Define variable " + name + ".");
	}

	function getDependencyByName(name:String):Dependency
	{
		for(dependency in dependencies)
			if(dependency.name == name)
				return dependency;
		return null;
	}

	function print(message:String)
	{
		if(log)
			System.print(message);
	}
}
