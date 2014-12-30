package yhaxen.phase;

import yhaxen.parser.ConfigParser;
import yhaxen.valueObject.command.CompileCommand;
import yhaxen.valueObject.command.TestCommand;
import yhaxen.valueObject.config.Build;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.Error;

class CompilePhase extends AbstractBuildPhase<Build,CompileCommand>
{
	public static function fromCommand(command:CompileCommand):CompilePhase
	{
		var config = ConfigParser.fromFile(command.configFile);
		return new CompilePhase(config, command);
	}

	override function getBuilds():Array<Build>
	{
		return config.builds;
	}

	override function getBuildByPart(part:String):Build
	{
		return config.getBuild(part);
	}

	override function executePreviousPhase():Void
	{
		new TestPhase(config, TestCommand.fromCompileCommand(command)).execute();
	}

	override function logPhasesFound(count:Int)
	{
		var message = switch(count)
		{
			case 0: "no builds found";
			case 1: "1 build found";
			default: count + " builds found";
		}
		logPhase("compile", message);
	}

	override function throwMissingBuildByPartError(part:String)
	{
		throw new Error(
			"Build " + part + " not found!",
			"Build named " + part + " is not defined in " + command.configFile + ".",
			"Provide build in " + command.configFile + " or execute different build.");
	}

	override function throwExecuteBuildError(build:Build)
	{
		throw new Error(
			"Build " + build.name + " failed!",
			"System command failed to execute.",
			"Make sure system command can be executed.");
	}
}