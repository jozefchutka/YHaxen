package yhaxen.valueObject.command;

class CompileCommand extends AbstractLifecycleCommand
{
	public function new(configFile:String, followPhaseFlow:Bool)
	{
		super(configFile, followPhaseFlow);
	}
}