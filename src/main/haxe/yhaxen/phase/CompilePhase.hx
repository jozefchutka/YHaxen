package yhaxen.phase;

import yhaxen.parser.ConfigParser;
import yhaxen.util.System;
import yhaxen.valueObject.command.CompileCommand;
import yhaxen.valueObject.config.Build;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.Error;

class CompilePhase extends AbstractPhase
{
	public var part(default, null):String;

	var testPhase:TestPhase;

	public function new(config:Config, configFile:String, followPhaseFlow:Bool, mode:String, part:String)
	{
		super(config, configFile, followPhaseFlow, mode);

		this.part = part;
	}

	public static function fromCommand(command:CompileCommand):CompilePhase
	{
		var config = ConfigParser.fromFile(command.configFile);
		return new CompilePhase(config, command.configFile, command.followPhaseFlow, command.mode, command.part);
	}

	override function execute():Void
	{
		super.execute();

		if(part != null)
			executePart(part);
		else
			executeAll();
	}

	function executeAll():Void
	{
		if(config.builds == null || config.builds.length == 0)
			return logPhase("compile", "No builds found.");

		logPhase("compile", "Found " + config.builds.length + " builds.");

		for(build in config.builds)
			compileBuild(build);
	}

	function executePart(part:String):Void
	{
		var build = config.getBuild(part);

		if(build == null)
			throw new Error(
				"Build " + part + " not found!",
				"Build named " + part + " is not defined in " + configFile + ".",
				"Provide build in " + configFile + " or execute different build.");

		logPhase("compile", "Found 1 build.");
		compileBuild(build);
	}


	override function executePreviousPhase():Void
	{
		testPhase = new TestPhase(config, configFile, followPhaseFlow, mode, null);
		testPhase.haxelib = haxelib;
		testPhase.execute();
	}

	function compileBuild(build:Build):Void
	{
		var arguments = null;

		if(build.arguments != null && build.arguments.length > 0)
			arguments = resolveVariablesInArray(build.arguments, build);

		var cwd = Sys.getCwd();

		if(build.dir != null)
			Sys.setCwd(resolveVariable(build.dir, build));

		if(System.command(build.command, arguments) != 0)
			throw new Error(
				"Build " + build.name + " failed!",
				"System command failed to execute.",
				"Make sure system command can be executed.");

		Sys.setCwd(cwd);
	}
}