package yhaxen.valueObject.command;

class ValidateCommand extends AbstractLifecycleCommand
{
	public function new(configFile:String, mode:String)
	{
		super(configFile, true, mode);
	}
}