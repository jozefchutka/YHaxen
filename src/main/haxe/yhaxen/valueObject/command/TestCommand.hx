package yhaxen.valueObject.command;

class TestCommand extends AbstractLifecycleCommand
{
	public var part(default, null):String;

	public function new(configFile:String, followPhaseFlow:Bool, part:String)
	{
		super(configFile, followPhaseFlow);

		this.part = part;
	}
}