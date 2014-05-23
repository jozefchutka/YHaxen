package yhaxen.valueObject.command;

class ReleaseCommand extends AbstractLifecycleCommand
{
	public var version(default, null):String;
	public var message(default, null):String;

	public function new(configFile:String, scope:String, verbose:Bool, version:String, message:String)
	{
		super(configFile, scope, verbose);

		this.version = version;
		this.message = message;
	}
}