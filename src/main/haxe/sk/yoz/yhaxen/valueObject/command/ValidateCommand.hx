package sk.yoz.yhaxen.valueObject.command;

class ValidateCommand extends AbstractLifecycleCommand
{
	public var scope(default, null):String;

	public function new(configFile:String, verbose:Bool, scope:String)
	{
		super(configFile, verbose);

		this.scope = scope;
	}
}