package yhaxen.valueObject.command;

class ValidateCommand extends AbstractLifecycleCommand
{
	public function new(logLevel:Int, configFile:String, mode:String)
	{
		super(logLevel, configFile, true, mode);
	}

	public static function fromTestCommand(command:TestCommand):ValidateCommand
	{
		return new ValidateCommand(command.logLevel, command.configFile, command.mode);
	}
}