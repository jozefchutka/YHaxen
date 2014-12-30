package yhaxen.phase;

import yhaxen.enums.DependencyVersionType;
import yhaxen.enums.LogLevel;
import yhaxen.util.Haxelib;
import yhaxen.util.System;
import yhaxen.valueObject.command.AbstractLifecycleCommand;
import yhaxen.valueObject.config.AbstractBuild;
import yhaxen.valueObject.config.AbstractStep;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.config.Dependency;
import yhaxen.valueObject.Error;

class AbstractPhase<TCommand:AbstractLifecycleCommand>
{
	public var config(default, null):Config;
	public var command(default, null):TCommand;
	public var haxelib(get, never):Haxelib;
	public var logGit(get, never):Bool;

	private function new(config:Config, command:TCommand)
	{
		this.config = config;
		this.command = command;
	}

	function get_haxelib():Haxelib
	{
		return Haxelib.instance;
	}

	function get_logGit():Bool
	{
		return shouldLog(LogLevel.DEBUG);
	}

	public function execute():Void
	{
		if(command.followPhaseFlow)
			executePreviousPhase();
	}

	function shouldLog(level:Int):Bool
	{
		return command.logLevel <= level;
	}

	function systemCommand(logLevel:Int, cmd:String, args:Array<String>):Int
	{
		log(logLevel, "$ " + cmd + " " + System.formatCommandLineArguments(args));
		return System.command(cmd, args);
	}

	function executePreviousPhase():Void
	{
	}

	function logPhase(name:String, details:String):Void
	{
		log(LogLevel.INFO, "");
		log(LogLevel.INFO, "# phase " + name + " - " + details);
	}

	function log(level:Int, message:String):Void
	{
		if(shouldLog(level))
			System.print(message);
	}

	function logKeyVal(level:Int, key:String, pad:Int, value:String):Void
	{
		log(level, StringTools.rpad(key, " ", pad) + value);
	}

	function getDependencyByName(name:String):Dependency
	{
		for(dependency in config.dependencies)
			if(dependency.name == name)
				return dependency;
		return null;
	}

	function getDependencies(scope:String):Array<Dependency>
	{
		var result:Array<Dependency> = [];
		for(dependency in config.dependencies)
			if(dependency.matchesScope(scope))
				result.push(dependency);
		return result.length == 0 ? null : result;
	}

	function getScopeFromStep(step:AbstractStep):String
	{
		return Std.is(step, AbstractBuild) ? cast(step, AbstractBuild).name : null;
	}

	function resolveVariable(input:String, step:AbstractStep, separator:String=""):String
	{
		return resolveVariablesInArray([input], step).join(separator);
	}

	function resolveVariablesInArray(input:Array<String>, step:AbstractStep):Array<String>
	{
		var result:Array<String> = [];
		for(item in input)
		{
			var resolvedResults = _resolveVariablesInString(item, step);
			if(resolvedResults == null)
				result.push(item);
			else
				for(resolvedResult in resolvedResults)
					result.push(resolvedResult);
		}
		return result;
	}

	function _resolveVariablesInString(input:String, step:AbstractStep):Array<String>
	{
		if(input == null)
			return null;

		if(input.indexOf("$" + "{") == -1)
			return [input];

		log(LogLevel.DEBUG, "resolving variable in \"" + input + "\"");

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
		var resolvedResults = _resolveVariable(matched, step);
		if(resolvedResults == null)
		{
			log(LogLevel.DEBUG, "  -> emtpy value");
		}
		else
		{
			var prefix:String = input.substr(0, pos.pos);
			var postfix:String = input.substr(pos.pos + pos.len);
			for(resolvedResult in resolvedResults)
			{
				var fixedResult = prefix + resolvedResult + postfix;
				result.push(fixedResult);
				log(LogLevel.DEBUG, "  -> " + fixedResult);
			}
		}
		log(LogLevel.DEBUG, "");
		return result;
	}

	function _resolveVariable(input:String, step:AbstractStep):Array<String>
	{
		var flag:String;

		flag = "system:cwd";
		if(input == flag)
			return [Sys.getCwd()];

		flag = "arg:";
		if(StringTools.startsWith(input, flag))
			return _resolveVariableArg(input.substr(flag.length), step);

		flag = "dependency:";
		if(StringTools.startsWith(input, flag))
			return _resolveVariableDependency(input.substr(flag.length), step);

		flag = "variable:";
		if(StringTools.startsWith(input, flag))
			return _resolveVariableVariable(input.substr(flag.length), step);

		throw new Error(
			"Invalid variable $" + "{" + input + "}",
			"Variable definition is unknown.",
			"Make sure the variable is defined properly.");
	}

	function _resolveVariableArg(input:String, step:AbstractStep):Array<String>
	{
		var chunks = input.split(":");
		var name = chunks.shift();
		var result:Array<String> = [];
		var args = Sys.args();
		var length = args.length;
		for(i in 0...length)
			if(args[i] == name && i < length)
				result.push(args[i + 1]);

		if(result.length == 0)
			throw new Error(
				"Invalid argument " + name + "!",
				"Argument " + name + " is not available in command.",
				"Provide command argument via command line (e.g. for ${arg.version} use \"version 123\").");

		return result.length == 0 ? null : result;
	}

	function _resolveVariableDependency(input:String, step:AbstractStep):Array<String>
	{
		var chunks = input.split(":");
		var name = chunks.shift();
		var scope:String = getScopeFromStep(step);
		var dependencies:Array<Dependency> = (name == "*") ? getDependencies(scope) : [getDependencyByName(name)];
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
					"Dependency " + name + " is not defined in " + command.configFile + ".",
					"Provide existing dependency name.");

			if(data != "")
				result.push(data);

			switch(type)
			{
				case "dir":
					result.push(_resolveVariableDependencyDir(dependency));
				case "name":
					result.push(dependency.name);
				case "version":
					result.push(dependency.version);
				case "nameVersion":
					result.push(dependency.name + ":" + dependency.version);
				case "classPath":
					result.push(_resolveVariableDependencyClassPath(dependency));
				default:
					throw new Error(
						"Invalid variable $" + "{dependency:" + input + "}!",
						"Variable definition type \"" + type + "\" is unknown.",
						"Make sure the variable is defined properly.");
			}
		}

		return result.length == 0 ? null : result;
	}

	function _resolveVariableDependencyDir(dependency:Dependency):String
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

	function _resolveVariableDependencyClassPath(dependency:Dependency):String
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

	function _resolveVariableVariable(input:String, step:AbstractStep):Array<String>
	{
		var name = input;
		if(name == "")
			throw new Error(
				"Invalid variable $" + "{variable:" + input + "}!",
				"Variable has empty name defined.",
				"Provide proper variable name.");

		if(config.variables != null)
			for(variable in config.variables)
				if(variable.name == name && variable.matchesMode(command.mode))
					return [variable.value];

		throw new Error(
			"Invalid variable $" + "{variable:" + input + "}!",
			"Variable " + name + " is not defined in " + command.configFile + ".",
			"Define variable " + name + ".");
	}
}