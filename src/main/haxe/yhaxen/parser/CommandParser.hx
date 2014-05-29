package yhaxen.parser;

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

		var configFile:String = getString("config", args);
		if(configFile == null)
			configFile = Config.DEFAULT_FILENAME;

		var verbose:Bool = getBool("verbose", args);
		var scope:String = getString("scope", args);

		var phase = args[0];
		switch(phase)
		{
			case Command.KEY_VALIDATE:
				return new ValidateCommand(configFile, scope, verbose);
			case Command.KEY_COMPILE:
				return new CompileCommand(configFile, scope, verbose);
			case Command.KEY_TEST:
				return new TestCommand(configFile, scope, verbose);
			case Command.KEY_RELEASE:
				var version = getString("version", args);
				if(version == null || version == "")
					throw new Error(
						"Missing release version.",
						"Command " + Command.KEY_RELEASE + " is missing required version argument.",
						"Provide version in " + Command.KEY_RELEASE + " command e.g. \"-version 1.2.3\".");
				var message = getString("message", args);
				return new ReleaseCommand(configFile, scope, verbose, version, message);
			case Command.KEY_HELP:
				return new HelpCommand();
			default:
				throw new Error(
					"Invalid command arguments.",
					"Command argument " + phase + " is invalid.",
					"Execute \"" + Command.KEY_HELP + "\" for help.");
		}
	}

	private function getStrings(key:String, args:Array<String>):Array<String>
	{
		var result:Array<String> = [];
		for(i in 0...args.length)
			if(args[i] == "-" + key && args.length > i)
				result.push(args[i + 1]);
		return result.length > 0 ? result : null;
	}

	private function getString(key:String, args:Array<String>):String
	{
		var result = getStrings(key, args);
		return result != null ? result[0] : null;
	}

	private function getBool(key:String, args:Array<String>):Bool
	{
		return getString(key, args) == "true";
	}
}