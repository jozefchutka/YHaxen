package sk.yoz.yhaxen.valueObject.dependency;

class Metadata
{
	public var isDev:Bool;
	public var exists:Bool;
	public var versionExists:Bool;

	public var versionCurrent:Version;
	public var versionForced:Version;
	public var versionResolved:Version;

	public function new()
	{
	}
}