package yhaxen.phase;

import yhaxen.valueObject.config.DependencyDetail;
import yhaxen.util.Haxelib;
import yhaxen.util.System;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.Error;

import sys.FileSystem;

class AbstractPhase
{
	inline static var TEMP_DIRECTORY:String = ".yhaxen";

	public var config(default, null):Config;
	public var configFile(default, null):String;
	public var scope(default, null):String;
	public var verbose(default, null):Bool;
	@:isVar public var haxelib(get, set):Haxelib;

	private function new(config:Config, configFile:String, scope:String, verbose:Bool)
	{
		this.config = config;
		this.configFile = configFile;
		this.scope = scope;
		this.verbose = verbose;
	}

	function get_haxelib():Haxelib
	{
		if(haxelib == null)
			haxelib = new Haxelib();
		return haxelib;
	}

	function set_haxelib(value:Haxelib):Haxelib
	{
		return haxelib = value;
	}

	public function execute():Void
	{
		executePreviousPhase();
	}

	function executePreviousPhase():Void
	{
	}

	function logPhase(name:String, scope:String, details:String):Void
	{
		log("");
		System.printRow("-");
		log("PHASE: " + name + (scope != null ? " " + scope : ""));
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
			haxelib.deleteDirectory(TEMP_DIRECTORY);
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
		return result;
	}

	function resolveVariablesInArray(input:Array<String>, ?env:Dynamic):Array<String>
	{
		var result:Array<String> = [];
		for(item in input)
		{
			var resolvedResults = resolveVariablesInString(item, env);
			if(resolvedResults == null)
				result.push(item);
			else
				for(resolvedResult in resolvedResults)
					result.push(resolvedResult);
		}
		return result;
	}

	function resolveVariablesInString(input:String, ?env:Dynamic):Array<String>
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
		var resolvedResults = resolveVariable(matched, env);
		if(resolvedResults == null)
			return null;

		var prefix:String = input.substr(0, pos.pos);
		var postfix:String = input.substr(pos.pos + pos.len);
		var result:Array<String> = [];
		for(resolvedResult in resolvedResults)
		{
			var fixedResult = prefix + resolvedResult + postfix;
			result.push(fixedResult);
			log("  -> " + fixedResult);
		}

		return result.length == 0 ? null : result;
	}

	function resolveVariable(input:String, ?env:Dynamic):Array<String>
	{
		var flag:String;

		flag = "dependency:";
		if(StringTools.startsWith(input, flag))
			return resolveVariableDependency(input.substr(flag.length));

		flag = "dependencies:";
		if(StringTools.startsWith(input, flag))
			return resolveVariableDependencies(input.substr(flag.length));

		throw new Error(
			"Invalid variable $" + "{" + input + "}",
			"Variable definition is unknown.",
			"Make sure the variable is defined properly.");
	}

	function resolveVariableDependency(input:String):Array<String>
	{
		var chunks = input.split(":");
		var name = chunks.shift();
		var data = chunks.join(":");
		var dependency = getDependencyByName(name);
		if(dependency == null)
			throw new Error(
				"Invalid dependency " + name + "!",
				"Dependency " + name + " is not defined in " + configFile + ".",
				"Provide existing dependency name.");
		switch(data)
		{
			case "dir":
				return [haxelib.getDependencyVersionDirectory(dependency.name, dependency.version, false)];
			default:
				throw new Error(
					"Invalid variable $" + "{" + input + "}",
					"Variable definition \"" + data + "\" is unknown.",
					"Make sure the variable is defined properly.");
		}
	}

	function resolveVariableDependencies(input:String):Array<String>
	{
		var chunks = input.split(":");
		var type = chunks.shift();
		var data = chunks.join(":");
		var dependencies = getDependencies(scope);
		var result:Array<String> = [];
		for(dependency in dependencies)
		{
			switch(type)
			{
				case "classPath":
					result.push(data);
					result.push(haxelib.getDependencyVersionDirectory(dependency.name, dependency.version, false));
				case "lib":
					result.push(data);
					result.push(dependency.name);
				default:
					throw new Error(
						"Invalid variable $" + "{" + input + "}",
						"Variable definition \"" + data + "\" is unknown.",
						"Make sure the variable is defined properly.");
			}
		}
		return result.length == 0 ? null : result;
	}
}