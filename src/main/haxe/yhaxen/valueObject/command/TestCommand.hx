package yhaxen.valueObject.command;

class TestCommand extends AbstractLifecycleCommand
{
	public function new(configFile:String, scope:String, verbose:Bool)
	{
		super(configFile, scope, verbose);
	}
}