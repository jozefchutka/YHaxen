package yhaxen.phase;

import yhaxen.parser.ConfigParser;
import yhaxen.valueObject.command.CompileCommand;
import yhaxen.valueObject.config.Build;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.Error;

class CompilePhase extends AbstractBuildPhase<Build>
{
	var testPhase:TestPhase;

	public static function fromCommand(command:CompileCommand):CompilePhase
	{
		var config = ConfigParser.fromFile(command.configFile);
		return new CompilePhase(config, command.configFile, command.followPhaseFlow, command.mode, command.part);
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
		testPhase = new TestPhase(config, configFile, followPhaseFlow, mode, null);
		testPhase.haxelib = haxelib;
		testPhase.execute();
	}

	override function logPhasesFound(count:Int)
	{
		var message = switch(count)
		{
			case 0: "No builds found.";
			case 1: "Found 1 build.";
			default: "Found " + count + " builds";
		}
		logPhase("compile", message);
	}

	override function throwMissingBuildByPartError(part:String)
	{
		throw new Error(
			"Build " + part + " not found!",
			"Build named " + part + " is not defined in " + configFile + ".",
			"Provide build in " + configFile + " or execute different build.");
	}

	override function throwExecuteBuildError(build:Build)
	{
		throw new Error(
			"Build " + build.name + " failed!",
			"System command failed to execute.",
			"Make sure system command can be executed.");
	}
}