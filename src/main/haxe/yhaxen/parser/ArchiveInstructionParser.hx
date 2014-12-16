package yhaxen.parser;

import yhaxen.valueObject.config.ArchiveInstruction;
import yhaxen.valueObject.Error;

class ArchiveInstructionParser extends GenericParser<ArchiveInstruction>
{
	public var configFile:String;

	override function parse(source:Dynamic):ArchiveInstruction
	{
		checkUnexpectedFields(source, ArchiveInstruction);

		if(!Reflect.hasField(source, "source"))
			throw new Error(
				"Missing archive instruction source!",
				"Archive instruction is missing required source field.",
				"Provide source field for archive instructions in " + configFile + ".");

		if(!Reflect.hasField(source, "target"))
			throw new Error(
				"Missing archive instruction target!",
				"Archive instruction is missing required target field.",
				"Provide target field for archive instructions in " + configFile + ".");

		var result:ArchiveInstruction = new ArchiveInstruction();
		result.source = Reflect.field(source, "source");
		result.target = Reflect.field(source, "target");
		return result;
	}
}
