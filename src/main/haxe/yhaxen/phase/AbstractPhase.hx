package yhaxen.phase;

import yhaxen.enums.LogLevel;
import yhaxen.util.Haxelib;
import yhaxen.util.System;
import yhaxen.util.VariableResolver;
import yhaxen.valueObject.command.AbstractLifecycleCommand;
import yhaxen.valueObject.config.AbstractBuild;
import yhaxen.valueObject.config.AbstractStep;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.config.Dependency;
import yhaxen.valueObject.config.Variable;

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
		var message = "$ " + cmd;
		if(args != null && args.length > 0)
			message += " " + System.escapeArguments(args);
		log(logLevel, message);

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

	function resolveVariable(input:String, step:AbstractStep, separator:String=""):String
	{
		return resolveVariablesInArray([input], step).join(separator);
	}

	function resolveVariablesInArray(input:Array<String>, step:AbstractStep):Array<String>
	{
		var log:Bool = shouldLog(LogLevel.DEBUG);
		var resolver = new VariableResolver(haxelib, command.configFile, log);
		resolver.variables = filterVariables(command.mode);
		resolver.dependencies = filterDependencies(step);
		resolver.systemArguments = Sys.args();
		return resolver.variablesInArray(input);
	}

	function filterVariables(mode:String):Array<Variable>
	{
		var result:Array<Variable> = [];
		if(config.variables != null)
			for(variable in config.variables)
				if(variable.matchesMode(mode))
					result.push(variable);
		return result.length == 0 ? null : result;
	}

	function filterDependencies(step:AbstractStep):Array<Dependency>
	{
		var scope:String = Std.is(step, AbstractBuild) ? cast(step, AbstractBuild).name : null;
		var result:Array<Dependency> = [];
		if(config.dependencies != null)
			for(dependency in config.dependencies)
				if(dependency.matchesScope(scope))
					result.push(dependency);
		return result.length == 0 ? null : result;
	}
}