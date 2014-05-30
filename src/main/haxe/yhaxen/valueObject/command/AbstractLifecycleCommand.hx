package yhaxen.valueObject.command;

class AbstractLifecycleCommand extends AbstractCommand
{
	public var configFile(default, null):String;

	private function new(configFile:String)
	{
		super();

		this.configFile = configFile;
	}
}