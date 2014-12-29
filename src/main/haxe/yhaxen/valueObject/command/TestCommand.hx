package yhaxen.valueObject.command;

class TestCommand extends AbstractLifecycleCommand
{
	public var part(default, null):String;

	public function new(configFile:String, followPhaseFlow:Bool, mode:String, part:String)
	{
		super(configFile, followPhaseFlow, mode);

		this.part = part;
	}
}