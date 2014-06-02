package yhaxen.valueObject.command;

class AbstractLifecycleCommand extends AbstractCommand
{
	public var configFile(default, null):String;
	public var followPhaseFlow(default, null):Bool;

	private function new(configFile:String, followPhaseFlow:Bool)
	{
		super();

		this.configFile = configFile;
		this.followPhaseFlow = followPhaseFlow;
	}
}