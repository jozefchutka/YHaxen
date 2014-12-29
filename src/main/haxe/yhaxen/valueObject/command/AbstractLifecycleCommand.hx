package yhaxen.valueObject.command;

class AbstractLifecycleCommand extends AbstractCommand
{
	public var configFile(default, null):String;
	public var followPhaseFlow(default, null):Bool;
	public var mode(default, null):String;

	private function new(configFile:String, followPhaseFlow:Bool, mode:String)
	{
		super();

		this.configFile = configFile;
		this.followPhaseFlow = followPhaseFlow;
		this.mode = mode;
	}
}