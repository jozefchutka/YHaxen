package yhaxen.phase;

import yhaxen.parser.ConfigParser;
import yhaxen.valueObject.command.TestCommand;
import yhaxen.valueObject.command.ValidateCommand;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.config.Test;
import yhaxen.valueObject.Error;

class TestPhase extends AbstractBuildPhase<Test,TestCommand>
{
	public static function fromCommand(command:TestCommand):TestPhase
	{
		var config = ConfigParser.fromFile(command.configFile);
		return new TestPhase(config, command);
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
		new ValidatePhase(config, ValidateCommand.fromTestCommand(command)).execute();
	}

	override function logPhasesFound(count:Int)
	{
		var message = switch(count)
		{
			case 0: "no tests found";
			case 1: "1 test found";
			default: count + " tests found";
		}
		logPhase("test", message);
	}

	override function throwMissingBuildByPartError(part:String)
	{
		throw new Error(
			"Test " + part + " not found!",
			"Test named " + part + " is not defined in " + command.configFile + ".",
			"Provide test in " + command.configFile + " or execute different test.");
	}

	override function throwExecuteBuildError(test:Test)
	{
		throw new Error(
			"Test " + test.name + " failed!",
			"System command failed to execute or tests failed.",
			"Make sure system command can be executed and fix tests.");
	}
}