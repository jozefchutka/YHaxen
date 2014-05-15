package sk.yoz.yhaxen.valueObject.command;

class ValidateCommand extends AbstractLifecycleCommand
{
	public function new(configFile:String, verbose:Bool)
	{
		super(configFile, verbose);
	}
}