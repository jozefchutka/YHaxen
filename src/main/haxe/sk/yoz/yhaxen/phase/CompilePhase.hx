package sk.yoz.yhaxen.phase;

import sk.yoz.yhaxen.util.System;
import sk.yoz.yhaxen.parser.ConfigParser;
import sk.yoz.yhaxen.valueObject.command.CompileCommand;
import sk.yoz.yhaxen.valueObject.config.Build;
import sk.yoz.yhaxen.valueObject.config.Config;
import sk.yoz.yhaxen.valueObject.Error;

class CompilePhase extends AbstractPhase
{
	public var build(default, null):String;

	var validatePhase:ValidatePhase;

	public function new(config:Config, configFile:String, verbose:Bool, build:String)
	{
		super(config, configFile, verbose);

		this.build = build;
	}

	public static function fromCommand(command:CompileCommand):CompilePhase
	{
		var config = ConfigParser.fromFile(command.configFile, command.build);
		return new CompilePhase(config, command.configFile, command.verbose, command.build);
	}

	override function execute():Void
	{
		executeValidatePhase();

		logPhase("compile");

		validateConfig();

		for(build in config.builds)
			compileBuild(build);
	}

	function executeValidatePhase():Void
	{
		validatePhase = new ValidatePhase(config, configFile, verbose, build);
		validatePhase.execute();
	}

	function validateConfig():Void
	{
		var names:Array<String> = [];
		for(build in config.builds)
		{
			if(Lambda.has(names, build.name))
				throw new Error(
					"Misconfigured dependency " + build.name + "!",
					"Dependency " + build.name + " is defined multiple times.",
					"Provide only one definition for " + build.name + " in " + configFile + ".");

			names.push(build.name);
		}
	}

	function compileBuild(build:Build):Void
	{
		var chunks:Array<String> = build.command.split(" ");
		var args = chunks.splice(1, chunks.length - 1);

		replaceArtifact(args, build.artifact);
		replaceDependencies(args, validatePhase.dependencyPaths);

		if(System.command(chunks[0], args) != 0)
			throw new Error(
				"Build " + build.name + " failed!",
				"System command failed to execute.",
				"Make sure system command can be executed.");
	}

	static function replaceArtifact(args:Array<String>, artifact:String):Void
	{
		for(i in 0...args.length)
			if(args[i].indexOf("{$artifact}") != -1)
				args[i] = StringTools.replace(args[i], "{$artifact}", artifact);
	}

	static function replaceDependencies(args:Array<String>, dependencies:Array<String>):Void
	{
		var index = Lambda.indexOf(args, "{$dependencies}");
		if(index == -1)
			return;

		args.splice(index, 1);
		for(i in 0...dependencies.length)
		{
			args.insert(index + i * 2, "-cp");
			args.insert(index + i * 2 + 1, dependencies[i]);
		}
	}
}