package yhaxen.valueObject.config;

import yhaxen.enums.ReleaseType;

class Release extends AbstractStep
{
	/**
	 * Required
	 **/
	public var type:ReleaseType;

	/**
	 * Optional haxelib.json file location that would be updated with version and dependencies.
	 **/
	public var haxelib:String;

	/**
	 * Available and required for haxelib release type
	 **/
	public var archiveInstructions:Array<ArchiveInstruction>;

	public function new(type:ReleaseType)
	{
		this.type = type;
	}
}