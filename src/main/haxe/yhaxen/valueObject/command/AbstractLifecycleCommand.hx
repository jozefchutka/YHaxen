package yhaxen.valueObject.command;

class AbstractLifecycleCommand extends AbstractCommand
{
	public var configFile(default, null):String;
	public var scope(default, null):String;
	public var verbose(default, null):Bool;

	private function new(configFile:String, scope:String, verbose:Bool)
	{
		super();

		this.configFile = configFile;
		this.scope = scope;
		this.verbose = verbose;
	}
}