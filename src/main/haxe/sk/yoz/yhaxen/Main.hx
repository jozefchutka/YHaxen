package sk.yoz.yhaxen;

import sk.yoz.yhaxen.helpers.SysHelper;
import sk.yoz.yhaxen.valueObjects.config.Root;
import sk.yoz.yhaxen.valueObjects.Command;
import sk.yoz.yhaxen.valueObjects.Error;
import sk.yoz.yhaxen.resolvers.DependencyResolver;

class Main
{
	private var commands:Array<Command>;

	private var commandDependencyInstall:Command;
	private var commandDependencyReport:Command;
	private var commandHelp:Command;

	public static function main()
	{
		new Main();
	}

	private function new()
	{
		SysHelper.print("YHaxen by Yoz");
	
		commandDependencyInstall = new Command(Command.KEY_DEPENDENCY_INSTALL, "Install dependencies from file.", Command.KEY_DEPENDENCY_INSTALL + " [file]");
		commandDependencyReport = new Command(Command.KEY_DEPENDENCY_REPORT, "Report dependencies from file / scope.", Command.KEY_DEPENDENCY_REPORT + " [file [scope]]");
		commandHelp = new Command(Command.KEY_HELP, "Print this legend.", Command.KEY_HELP);
		commands = [commandDependencyInstall, commandDependencyReport, commandHelp];

		try
		{
			executeArgs(Sys.args());
			SysHelper.print("");
			SysHelper.print("Successfully completed.");
		}
		catch(error:Error)
		{
			SysHelper.print("");
			SysHelper.print("Error: " + error.message);
			SysHelper.print("  reason: " + error.reason);
			SysHelper.print("  solution: " + error.solution);
		}
		catch(error:String)
		{
			SysHelper.print("");
			SysHelper.print("Error: " + error);
		}
	}

	private function executeArgs(args:Array<String>):Void
	{
		var command = args[0];
		
		if(command == commandDependencyInstall.key)
		{
			var file:String = getFilenameFromArgs(args);
			var scope:String = getScopeFromArgs(args);
			SysHelper.printCommand(commandDependencyInstall.key
				+ " (from " + file + (scope == null ? "" : " for " + scope) + ")");
			new DependencyResolver().installFromFile(file, scope);
		}
		else if(command == commandDependencyReport.key)
		{
			var file:String = getFilenameFromArgs(args);
			var scope:String = getScopeFromArgs(args);
			SysHelper.printCommand(commandDependencyReport.key
				+ " (from " + file + (scope == null ? "" : " for " + scope) + ")");
			new DependencyResolver().reportFromFile(file, scope);
		}
		else if(command == commandHelp.key)
		{
			SysHelper.printCommand(commandHelp.key);
			printHelp();
		}
		else
		{
			printUnknownCommand(command);
			return;
		}
	}
	
	private function getFilenameFromArgs(args:Array<String>):String
	{
		return args.length > 1 ? args[1] : Root.FILENAME;
	}

	private function getScopeFromArgs(args:Array<String>):String
	{
		return args.length > 2 ? args[2] : null;
	}

	private function printHelp():Void
	{
		SysHelper.print("  Available commands:");
		for(item in commands)
			SysHelper.printKeyVal("    " + item.usage, 40, item.info);
	}

	private function printUnknownCommand(command:String):Void
	{
		SysHelper.print("Unknown command " + command);
		SysHelper.print("  Usage: haxelib run yhaxen [command] [options]");
		printHelp();
	}
}