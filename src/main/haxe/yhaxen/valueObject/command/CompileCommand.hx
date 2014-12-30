package yhaxen.valueObject.command;

class CompileCommand extends AbstractBuildCommand
{
	public static function fromReleaseCommand(command:ReleaseCommand):CompileCommand
	{
		return new CompileCommand(command.logLevel, command.configFile, command.followPhaseFlow, command.mode, null);
	}
}