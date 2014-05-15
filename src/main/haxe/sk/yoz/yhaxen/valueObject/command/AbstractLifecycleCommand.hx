package sk.yoz.yhaxen.valueObject.command;

class AbstractLifecycleCommand extends AbstractCommand
{
	public var configFile(default, null):String;
	public var verbose(default, null):Bool;

	private function new(configFile:String, verbose:Bool)
	{
		super();

		this.configFile = configFile;
		this.verbose = verbose;
	}
}