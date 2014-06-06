package yhaxen.phase;

import yhaxen.parser.ConfigParser;
import yhaxen.util.System;
import yhaxen.valueObject.command.CompileCommand;
import yhaxen.valueObject.config.Build;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.Error;

class CompilePhase extends AbstractPhase
{
	var testPhase:TestPhase;

	public function new(config:Config, configFile:String, followPhaseFlow:Bool)
	{
		super(config, configFile, followPhaseFlow);
	}

	public static function fromCommand(command:CompileCommand):CompilePhase
	{
		var config = ConfigParser.fromFile(command.configFile);
		return new CompilePhase(config, command.configFile, command.followPhaseFlow);
	}

	override function execute():Void
	{
		super.execute();

		if(config.builds == null || config.builds.length == 0)
			return logPhase("compile", "No builds found.");

		logPhase("compile", "Found " + config.builds.length + " builds.");

		validateConfig();

		for(build in config.builds)
			compileBuild(build);
	}

	override function executePreviousPhase():Void
	{
		testPhase = new TestPhase(config, configFile, followPhaseFlow);
		testPhase.haxelib = haxelib;
		testPhase.execute();
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
			arguments = resolveVariablesInArray(build.arguments, build);

		var cwd = Sys.getCwd();

		if(build.dir != null)
			Sys.setCwd(resolveVariablesInArray([build.dir], build).join(""));

		if(System.command(build.command, arguments) != 0)
			throw new Error(
				"Build " + build.name + " failed!",
				"System command failed to execute.",
				"Make sure system command can be executed.");

		Sys.setCwd(cwd);
	}
}