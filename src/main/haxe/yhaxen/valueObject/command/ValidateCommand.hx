package yhaxen.valueObject.command;

class ValidateCommand extends AbstractLifecycleCommand
{
	public function new(configFile:String)
	{
		super(configFile);
	}
}