package yhaxen.phase;

import yhaxen.util.Haxelib;
import yhaxen.util.System;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.config.DependencyDetail;
import yhaxen.valueObject.Error;
import yhaxen.valueObject.PhaseEnvironment;

import sys.FileSystem;

class AbstractPhase
{
	inline static var TEMP_DIRECTORY:String = ".yhaxen";

	public var config(default, null):Config;
	public var configFile(default, null):String;
	public var followPhaseFlow(default, null):Bool;
	@:isVar public var haxelib(get, set):Haxelib;

	private function new(config:Config, configFile:String, followPhaseFlow:Bool)
	{
		this.config = config;
		this.configFile = configFile;
		this.followPhaseFlow = followPhaseFlow;
	}

	function get_haxelib():Haxelib
	{
		return Haxelib.instance;
	}

	function set_haxelib(value:Haxelib):Haxelib
	{
		return haxelib = value;
	}

	public function execute():Void
	{
		if(followPhaseFlow)
			executePreviousPhase();
	}

	function executePreviousPhase():Void
	{
	}

	function logPhase(name:String, details:String):Void
	{
		log("");
		System.printRow("-");
		log("PHASE: " + name);
		log(details);
		System.printRow("-");
	}

	function log(message:String):Void
	{
		System.print(message);
	}

	function logKeyVal(key:String, pad:Int, value:String):Void
	{
		System.printKeyVal(key, pad, value);
	}

	function createTempDirectory():Void
	{
		deleteTempDirectory();
		FileSystem.createDirectory(TEMP_DIRECTORY);
	}

	function deleteTempDirectory():Void
	{
		if(FileSystem.exists(TEMP_DIRECTORY))
			System.deleteDirectory(TEMP_DIRECTORY);
	}

	function getDependencyByName(name:String):DependencyDetail
	{
		for(dependency in config.dependencies)
			if(dependency.name == name)
				return dependency;
		return null;
	}

	function getDependencies(scope:String):Array<DependencyDetail>
	{
		var result:Array<DependencyDetail> = [];
		for(dependency in config.dependencies)
			if(dependency.matchesScope(scope))
				result.push(dependency);
		return result.length == 0 ? null : result;
	}

	function resolveVariablesInArray(input:Array<String>, phaseEnvironment:PhaseEnvironment):Array<String>
	{
		var result:Array<String> = [];
		for(item in input)
		{
			var resolvedResults = resolveVariablesInString(item, phaseEnvironment);
			if(resolvedResults == null)
				result.push(item);
			else
				for(resolvedResult in resolvedResults)
					result.push(resolvedResult);
		}
		return result;
	}

	function resolveVariablesInString(input:String, phaseEnvironment:PhaseEnvironment):Array<String>
	{
		if(input == null)
			return null;

		if(input.indexOf("$" + "{") == -1)
			return [input];

		log("Resolving variable in \"" + input + "\"");

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
		var resolvedResults = resolveVariable(matched, phaseEnvironment);
		if(resolvedResults == null)
		{
			log("  -> emtpy value");
		}
		else
		{
			var prefix:String = input.substr(0, pos.pos);
			var postfix:String = input.substr(pos.pos + pos.len);
			for(resolvedResult in resolvedResults)
			{
				var fixedResult = prefix + resolvedResult + postfix;
				result.push(fixedResult);
				log("  -> " + fixedResult);
			}
		}
		log("");
		return result;
	}

	function resolveVariable(input:String, phaseEnvironment:PhaseEnvironment):Array<String>
	{
		var flag:String;

		flag = "arg:";
		if(StringTools.startsWith(input, flag))
			return resolveVariableArg(input.substr(flag.length), phaseEnvironment);

		flag = "dependency:";
		if(StringTools.startsWith(input, flag))
			return resolveVariableDependency(input.substr(flag.length), phaseEnvironment);

		throw new Error(
			"Invalid variable $" + "{" + input + "}",
			"Variable definition is unknown.",
			"Make sure the variable is defined properly.");
	}

	function resolveVariableArg(input:String, phaseEnvironment:PhaseEnvironment):Array<String>
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

	function resolveVariableDependency(input:String, phaseEnvironment:PhaseEnvironment):Array<String>
	{
		var chunks = input.split(":");
		var name = chunks.shift();
		var scope:String = phaseEnvironment.scope;
		var dependencies:Array<DependencyDetail> = (name == "*") ? getDependencies(scope) : [getDependencyByName(name)];
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
				case "$dir":
					result.push(haxelib.getDependencyVersionDirectory(dependency.name, dependency.version, false));
				case "$name":
					result.push(dependency.name);
				case "$nameVersion":
					result.push(dependency.name + ":" + dependency.version);
				default:
					throw new Error(
						"Invalid variable $" + "{" + input + "}",
						"Variable definition type \"" + type + "\" is unknown.",
						"Make sure the variable is defined properly.");
			}
		}

		return result.length == 0 ? null : result;
	}
}