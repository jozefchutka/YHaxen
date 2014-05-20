package sk.yoz.yhaxen.valueObject.command;

class ReleaseCommand extends AbstractLifecycleCommand
{
	public var version(default, null):String;

	public function new(configFile:String, scope:String, verbose:Bool, version:String)
	{
		super(configFile, scope, verbose);

		this.version = version;
	}
}