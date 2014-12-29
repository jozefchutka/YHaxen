package yhaxen;

import yhaxen.parser.CommandParser;
import yhaxen.phase.CompilePhase;
import yhaxen.phase.ReleasePhase;
import yhaxen.phase.TestPhase;
import yhaxen.phase.ValidatePhase;
import yhaxen.util.System;
import yhaxen.valueObject.command.AbstractCommand;
import yhaxen.valueObject.command.CompileCommand;
import yhaxen.valueObject.command.HelpCommand;
import yhaxen.valueObject.command.ReleaseCommand;
import yhaxen.valueObject.command.TestCommand;
import yhaxen.valueObject.command.ValidateCommand;
import yhaxen.valueObject.Command;
import yhaxen.valueObject.Error;

class Main
{
	private var commands:Array<Command>;

	private var commandValidate:Command;
	private var commandCompile:Command;
	private var commandCompileAll:Command;
	private var commandCompileName:Command;
	private var commandTest:Command;
	private var commandTestAll:Command;
	private var commandTestName:Command;
	private var commandRelease:Command;
	private var commandHelp:Command;

	public static function main()
	{
		new Main();
	}

	private function new()
	{
		var args = System.fixCwd();
		System.print("YHaxen version " + System.getVersion() + " from " + System.getBuildDate());

		commandValidate = new Command(Command.KEY_VALIDATE, "Validate the project is correct and all necessary information is available.");
		commandCompile = new Command(Command.KEY_COMPILE, "Compile the source code of the project.");
		commandCompileAll = new Command(Command.KEY_COMPILE_ALL, "Execute compile phase only.");
		commandCompileName = new Command(Command.KEY_COMPILE_NAME, "Execute build named XY only.");
		commandTest = new Command(Command.KEY_TEST, "Test the compiled source code using a unit testing framework.");
		commandTestAll = new Command(Command.KEY_TEST_ALL, "Execute test phase only.");
		commandTestName = new Command(Command.KEY_TEST_NAME, "Execute test named XY only.");
		commandRelease = new Command(Command.KEY_RELEASE, "Release versioned project.");
		commandHelp = new Command(Command.KEY_HELP, "Print this legend.");
		commands = [commandValidate,
			commandTest, commandTestAll, commandTestName,
			commandCompile, commandCompileAll, commandCompileName,
			commandRelease, commandHelp];

		try
		{
			var parser = new CommandParser();
			var command = parser.parse(args);
			execute(command);
			System.print("");
			System.print("Successfully completed.");
			Sys.exit(0);
		}
		catch(error:Error)
		{
			System.print("");
			System.print("Error: " + error.message);
			System.print("  reason: " + error.reason);
			System.print("  solution: " + error.solution);
			Sys.exit(1);
		}
		catch(error:String)
		{
			System.print("");
			System.print("Error: " + error);
			Sys.exit(1);
		}
	}

	private function execute(command:AbstractCommand):Void
	{
		if(Std.is(command, ValidateCommand))
			return ValidatePhase.fromCommand(cast command).execute();

		if(Std.is(command, TestCommand))
			return TestPhase.fromCommand(cast command).execute();

		if(Std.is(command, CompileCommand))
			return CompilePhase.fromCommand(cast command).execute();

		if(Std.is(command, ReleaseCommand))
			return ReleasePhase.fromCommand(cast command).execute();

		if(Std.is(command, HelpCommand))
		{
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