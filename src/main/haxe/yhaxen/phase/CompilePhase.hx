package yhaxen.phase;

import yhaxen.util.System;
import yhaxen.parser.ConfigParser;
import yhaxen.valueObject.command.CompileCommand;
import yhaxen.valueObject.config.Build;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.Error;

class CompilePhase extends AbstractPhase
{
	var validatePhase:ValidatePhase;

	public function new(config:Config, configFile:String, scope:String, verbose:Bool)
	{
		super(config, configFile, scope, verbose);
	}

	public static function fromCommand(command:CompileCommand):CompilePhase
	{
		var config = ConfigParser.fromFile(command.configFile, command.scope);
		return new CompilePhase(config, command.configFile, command.scope, command.verbose);
	}

	override function execute():Void
	{
		super.execute();

		if(config.builds == null || config.builds.length == 0)
			return logPhase("compile", scope, "No builds found.");

		logPhase("compile", scope, "Found " + config.builds.length + " builds.");

		validateConfig();

		for(build in config.builds)
			compileBuild(build);
	}

	override function executePreviousPhase():Void
	{
		validatePhase = new ValidatePhase(config, configFile, scope, verbose);
		validatePhase.haxelib = haxelib;
		validatePhase.execute();
	}

	function validateConfig():Void
	{
		var names:Array<String> = [];
		for(build in config.builds)
		{
			if(Lambda.has(names, build.name))
				throw new Error(
					"Misconfigured build " + build.name + "!",
					"Build " + build.name + " is defined multiple times.",
					"Provide only one definition for " + build.name + " in " + configFile + ".");

			names.push(build.name);
		}
	}

	function compileBuild(build:Build):Void
	{
		var arguments = null;
		if(build.arguments != null && build.arguments.length > 0)
		{
			arguments = build.arguments.copy();
			replaceArtifact(arguments, build.artifact);
			replaceDependencies(arguments, validatePhase.dependencyPaths);
		}

		if(System.command(build.command, arguments) != 0)
			throw new Error(
				"Build " + build.name + " failed!",
				"System command failed to execute.",
				"Make sure system command can be executed.");
	}

	static function replaceArtifact(args:Array<String>, artifact:String):Void
	{
		for(i in 0...args.length)
			if(args[i].indexOf(Build.ARGUMENT_ARTIFACT) != -1)
				args[i] = StringTools.replace(args[i], Build.ARGUMENT_ARTIFACT, artifact);
	}

	static function replaceDependencies(args:Array<String>, dependencies:Array<String>):Void
	{
		var index = Lambda.indexOf(args, Build.ARGUMENT_DEPENDENCIES);
		if(index == -1)
			return;

		args.splice(index, 1);
		if(dependencies == null)
			return;

		for(i in 0...dependencies.length)
		{
			args.insert(index + i * 2, "-cp");
			args.insert(index + i * 2 + 1, dependencies[i]);
		}
	}
}