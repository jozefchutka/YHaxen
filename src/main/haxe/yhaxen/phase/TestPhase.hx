package yhaxen.phase;

import yhaxen.parser.ConfigParser;
import yhaxen.valueObject.command.TestCommand;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.config.Test;
import yhaxen.valueObject.Error;

class TestPhase extends AbstractBuildPhase<Test>
{
	var validatePhase:ValidatePhase;

	public static function fromCommand(command:TestCommand):TestPhase
	{
		var config = ConfigParser.fromFile(command.configFile);
		return new TestPhase(config, command.configFile, command.followPhaseFlow, command.mode, command.part);
	}

	override function getBuilds():Array<Test>
	{
		return config.tests;
	}

	override function getBuildByPart(part:String):Test
	{
		return config.getTest(part);
	}

	override function executePreviousPhase():Void
	{
		validatePhase = new ValidatePhase(config, configFile, followPhaseFlow, mode);
		validatePhase.haxelib = haxelib;
		validatePhase.execute();
	}

	override function logPhasesFound(count:Int)
	{
		var message = switch(count)
		{
			case 0: "No tests found.";
			case 1: "Found 1 test.";
			default: "Found " + count + " tests";
		}
		logPhase("test", message);
	}

	override function throwMissingBuildByPartError(part:String)
	{
		throw new Error(
			"Test " + part + " not found!",
			"Test named " + part + " is not defined in " + configFile + ".",
			"Provide test in " + configFile + " or execute different test.");
	}

	override function throwExecuteBuildError(test:Test)
	{
		throw new Error(
			"Test " + test.name + " failed!",
			"System command failed to execute or tests failed.",
			"Make sure system command can be executed and fix tests.");
	}
}