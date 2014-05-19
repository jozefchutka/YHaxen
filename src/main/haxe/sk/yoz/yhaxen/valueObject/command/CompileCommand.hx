package sk.yoz.yhaxen.valueObject.command;

class CompileCommand extends AbstractLifecycleCommand
{
	public var build(default, null):String;

	public function new(configFile:String, verbose:Bool, build:String)
	{
		super(configFile, verbose);

		this.build = build;
	}
}