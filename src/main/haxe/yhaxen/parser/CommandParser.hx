package yhaxen.parser;

import yhaxen.enums.LogLevel;
import yhaxen.valueObject.command.AbstractCommand;
import yhaxen.valueObject.command.CompileCommand;
import yhaxen.valueObject.command.HelpCommand;
import yhaxen.valueObject.command.ReleaseCommand;
import yhaxen.valueObject.command.TestCommand;
import yhaxen.valueObject.command.ValidateCommand;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.Command;
import yhaxen.valueObject.Error;

class CommandParser extends GenericParser<AbstractCommand>
{
	override function parse(source:Dynamic):AbstractCommand
	{
		var args:Array<String> = source;

		var logLevel = getInt("logLevel", args);
		if(logLevel == -1)
			logLevel = LogLevel.INFO;

		var configFile:String = getString("config", args);
		if(configFile == null)
			configFile = Config.DEFAULT_FILENAME;

		var mode:String = getString("mode", args);

		var phase = Command.KEY_HELP;
		var phaseStep:String = null;
		if(args != null && args.length > 0)
		{
			var phaseChunks = args[0].split(":");
			phase = phaseChunks[0];
			phaseStep = getPhaseStep(phaseChunks);
		}

		switch(phase)
		{
			case Command.KEY_VALIDATE:
				return new ValidateCommand(logLevel, configFile, mode);
			case Command.KEY_COMPILE:
				return new CompileCommand(logLevel, configFile, phaseStep == null, mode, phaseStep == "*" ? null : phaseStep);
			case Command.KEY_TEST:
				return new TestCommand(logLevel, configFile, phaseStep == null, mode, phaseStep == "*" ? null : phaseStep);
			case Command.KEY_RELEASE:
				var version = getString("version", args);
				if(version == null || version == "")
					throw new Error(
						"Missing release version.",
						"Command " + Command.KEY_RELEASE + " is missing required version argument.",
						"Provide version in " + Command.KEY_RELEASE + " command e.g. \"-version 1.2.3\".");
				var message = getString("message", args);
				return new ReleaseCommand(logLevel, configFile, mode, version, message);
			case Command.KEY_HELP:
				return new HelpCommand();
			default:
				throw new Error(
					"Invalid command arguments.",
					"Command argument " + phase + " is invalid.",
					"Execute \"" + Command.KEY_HELP + "\" for help.");
		}
	}

	function getStrings(key:String, args:Array<String>):Array<String>
	{
		var result:Array<String> = [];
		for(i in 0...args.length)
			if(args[i] == "-" + key && args.length > i)
				result.push(args[i + 1]);
		return result.length > 0 ? result : null;
	}

	function getString(key:String, args:Array<String>):String
	{
		var result = getStrings(key, args);
		return result != null ? result[0] : null;
	}

	function getBool(key:String, args:Array<String>):Bool
	{
		return getString(key, args) == "true";
	}

	function getInt(key, args:Array<String>):Int
	{
		var raw = getString(key, args);
		return raw == null ? -1 : Std.parseInt(raw);
	}

	function getPhaseStep(chunks:Array<String>):String
	{
		return (chunks != null && chunks.length > 1) ? chunks[1] : null;
	}
}