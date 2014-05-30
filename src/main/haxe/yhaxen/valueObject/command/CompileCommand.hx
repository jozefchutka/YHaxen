package yhaxen.valueObject.command;

class CompileCommand extends AbstractLifecycleCommand
{
	public function new(configFile:String)
	{
		super(configFile);
	}
}