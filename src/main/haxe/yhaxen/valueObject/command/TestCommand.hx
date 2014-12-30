package yhaxen.valueObject.command;

class TestCommand extends AbstractBuildCommand
{
	public static function fromCompileCommand(command:CompileCommand):TestCommand
	{
		return new TestCommand(command.logLevel, command.configFile, command.followPhaseFlow, command.mode, null);
	}
}