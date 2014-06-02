package yhaxen.valueObject.command;

class TestCommand extends AbstractLifecycleCommand
{
	public function new(configFile:String, followPhaseFlow:Bool)
	{
		super(configFile, followPhaseFlow);
	}
}