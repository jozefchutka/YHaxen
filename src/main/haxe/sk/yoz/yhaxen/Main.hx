package sk.yoz.yhaxen;

import sk.yoz.yhaxen.phase.ValidatePhase;
import sk.yoz.yhaxen.valueObject.command.ValidateCommand;
import sk.yoz.yhaxen.valueObject.command.HelpCommand;
import sk.yoz.yhaxen.valueObject.command.AbstractCommand;
import sk.yoz.yhaxen.parser.CommandParser;
import sk.yoz.yhaxen.helper.System;
import sk.yoz.yhaxen.valueObject.Command;
import sk.yoz.yhaxen.valueObject.Error;

class Main
{
	private var commands:Array<Command>;

	private var commandValidate:Command;
	private var commandHelp:Command;

	public static function main()
	{
		new Main();
	}

	private function new()
	{
		System.print("YHaxen");
	
		commandValidate = new Command(Command.KEY_VALIDATE, "Validate the project is correct and all necessary information is available.");
		commandHelp = new Command(Command.KEY_HELP, "Print this legend.");
		commands = [commandValidate, commandHelp];

		try
		{
			var parser = new CommandParser();
			var args = Sys.args();
			var command = parser.parse(args);
			execute(command);
			System.print("");
			System.print("Successfully completed.");
		}
		catch(error:Error)
		{
			System.print("");
			System.print("Error: " + error.message);
			System.print("  reason: " + error.reason);
			System.print("  solution: " + error.solution);
		}
		catch(error:String)
		{
			System.print("");
			System.print("Error: " + error);
		}
	}

	private function execute(command:AbstractCommand):Void
	{
		if(Std.is(command, ValidateCommand))
		{
			var phase = new ValidatePhase(cast command);
			phase.execute();
			return;
		}

		if(Std.is(command, HelpCommand))
		{
			System.printCommand(commandHelp.key);
			printHelp();
			return;
		}
	}

	private function printHelp():Void
	{
		System.print("  Available commands:");
		for(item in commands)
			System.printKeyVal("    " + item.key, 40, item.info);
	}
}