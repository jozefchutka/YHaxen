package yhaxen.phase;

import yhaxen.parser.ConfigParser;
import yhaxen.phase.CompilePhase;
import yhaxen.valueObject.command.TestCommand;
import yhaxen.valueObject.config.Config;

class TestPhase extends AbstractPhase
{
	var compilePhase:CompilePhase;

	public function new(config:Config, configFile:String, scope:String, verbose:Bool)
	{
		super(config, configFile, scope, verbose);
	}

	public static function fromCommand(command:TestCommand):TestPhase
	{
		var config = ConfigParser.fromFile(command.configFile, command.scope);
		return new TestPhase(config, command.configFile, command.scope, command.verbose);
	}

	override function execute():Void
	{
		super.execute();

		if(config.tests == null || config.tests.length == 0)
			return logPhase("tests", scope, "No tests found.");

		logPhase("test", scope, "Found " + config.tests.length + " tests.");
	}

	override function executePreviousPhase():Void
	{
		compilePhase = new CompilePhase(config, configFile, scope, verbose);
		compilePhase.haxelib = haxelib;
		compilePhase.execute();
	}
}