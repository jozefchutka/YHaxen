package sk.yoz.yhaxen.valueObject.command;

class ValidateCommand extends AbstractLifecycleCommand
{
	public function new(configFile:String, scope:String, verbose:Bool)
	{
		super(configFile, scope, verbose);
	}
}