package yhaxen.valueObject.command;

class AbstractBuildCommand extends AbstractLifecycleCommand
{
	public var part(default, null):String;

	public function new(logLevel:Int, configFile:String, followPhaseFlow:Bool, mode:String, part:String)
	{
		super(logLevel, configFile, followPhaseFlow, mode);

		this.part = part;
	}
}
