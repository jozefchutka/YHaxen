package yhaxen.valueObject.command;

class ReleaseCommand extends AbstractLifecycleCommand
{
	public var version(default, null):String;
	public var message(default, null):String;

	public function new(logLevel:Int, configFile:String, mode:String, version:String, message:String)
	{
		super(logLevel, configFile, true, mode);

		this.version = version;
		this.message = message;
	}
}