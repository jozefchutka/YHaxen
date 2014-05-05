package sk.yoz.yhaxen;

import sk.yoz.yhaxen.helpers.SysHelper;
import sk.yoz.yhaxen.valueObjects.config.Root;
import sk.yoz.yhaxen.valueObjects.Command;
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
	
		commandDependencyInstall = new Command("dependency:install", "Install dependencies from file.");
		commandDependencyReport = new Command("dependency:report", "Report dependencies from file.");
		commandHelp = new Command("help", "Print this info.");
		commands = [commandDependencyInstall, commandDependencyReport, commandHelp];

		try
		{
			executeArgs(Sys.args());
			SysHelper.print("");
			SysHelper.print("Successfully completed.");
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
			SysHelper.printCommand(commandDependencyInstall.key + " (from " + file + ")");
			new DependencyResolver().installFromFile(file);
		}
		else if(command == commandDependencyReport.key)
		{
			var file:String = getFilenameFromArgs(args);
			SysHelper.printCommand(commandDependencyReport.key + " (from " + file + ")");
			new DependencyResolver().reportFromFile(file);
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
	
	private function printHelp():Void
	{
		SysHelper.print("  Available commands:");
		for(item in commands)
			SysHelper.printKeyVal("    " + item.key, 30, item.info);
	}

	private function printUnknownCommand(command:String):Void
	{
		SysHelper.print("Unknown command " + command);
		SysHelper.print("  Usage: haxelib run yhaxen [command] [options]");
		printHelp();
	}
}