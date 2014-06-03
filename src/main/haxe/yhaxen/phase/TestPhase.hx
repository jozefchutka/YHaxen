package yhaxen.phase;

import yhaxen.parser.ConfigParser;
import yhaxen.phase.CompilePhase;
import yhaxen.util.System;
import yhaxen.valueObject.command.TestCommand;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.config.Test;
import yhaxen.valueObject.Error;
import yhaxen.valueObject.PhaseEnvironment;

class TestPhase extends AbstractPhase
{
	var compilePhase:CompilePhase;

	public function new(config:Config, configFile:String, followPhaseFlow:Bool)
	{
		super(config, configFile, followPhaseFlow);
	}

	public static function fromCommand(command:TestCommand):TestPhase
	{
		var config = ConfigParser.fromFile(command.configFile);
		return new TestPhase(config, command.configFile, command.followPhaseFlow);
	}

	override function execute():Void
	{
		super.execute();

		if(config.tests == null || config.tests.length == 0)
			return logPhase("tests", "No tests found.");

		logPhase("test", "Found " + config.tests.length + " tests.");

		for(test in config.tests)
			resolveTest(test);
	}

	override function executePreviousPhase():Void
	{
		compilePhase = new CompilePhase(config, configFile, followPhaseFlow);
		compilePhase.haxelib = haxelib;
		compilePhase.execute();
	}

	function resolveTest(test:Test):Void
	{
		var arguments = null;
		var phaseEnvironment = new PhaseEnvironment();
		phaseEnvironment.test = test;

		if(test.arguments != null && test.arguments.length > 0)
			arguments = resolveVariablesInArray(test.arguments, phaseEnvironment);

		var cwd = Sys.getCwd();

		if(test.dir != null)
			Sys.setCwd(resolveVariablesInArray([test.dir], phaseEnvironment).join(""));

		if(System.command(test.command, arguments) != 0)
			throw new Error(
				"Test failed!",
				"System command failed to execute or tests failed.",
				"Make sure system command can be executed and fix tests.");

		Sys.setCwd(cwd);
	}
}