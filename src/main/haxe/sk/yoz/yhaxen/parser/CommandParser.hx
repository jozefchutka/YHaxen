package sk.yoz.yhaxen.parser;

import sk.yoz.yhaxen.valueObject.command.AbstractCommand;
import sk.yoz.yhaxen.valueObject.command.CompileCommand;
import sk.yoz.yhaxen.valueObject.command.HelpCommand;
import sk.yoz.yhaxen.valueObject.command.ValidateCommand;
import sk.yoz.yhaxen.valueObject.config.Config;
import sk.yoz.yhaxen.valueObject.Command;
import sk.yoz.yhaxen.valueObject.Error;

class CommandParser extends GenericParser<AbstractCommand>
{
	override function parse(source:Dynamic):AbstractCommand
	{
		var args:Array<String> = source;

		var configFile:String = getString("config", args);
		if(configFile == null)
			configFile = Config.DEFAULT_FILENAME;

		var verbose:Bool = getBool("verbose", args);

		var phase = args[0];
		switch(phase)
		{
			case Command.KEY_VALIDATE:
				return new ValidateCommand(configFile, verbose, getString("scope", args));
			case Command.KEY_COMPILE:
				return new CompileCommand(configFile, verbose, getString("build", args));
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