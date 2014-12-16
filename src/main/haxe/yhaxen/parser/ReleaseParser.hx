package yhaxen.parser;

import yhaxen.enums.ReleaseType;
import yhaxen.valueObject.config.ArchiveInstruction;
import yhaxen.valueObject.config.Release;
import yhaxen.valueObject.Error;

class ReleaseParser extends GenericParser<Release>
{
	public var configFile:String;

	override function parse(source:Dynamic):Release
	{
		checkUnexpectedFields(source, Release);

		if(!Reflect.hasField(source, "type"))
			throw new Error(
				"Missing release type!",
				"Release definition is missing required type field.",
				"Provide release type in " + configFile + ".");

		var typeRaw:String = Reflect.field(source, "type");
		var type:ReleaseType;
		try
		{
			type = GenericParser.parseEnum(ReleaseType, typeRaw);
		}
		catch(error:Dynamic)
		{
			throw new Error(
				"Invalid release type!",
				"Release has invalid type value " + typeRaw + ".",
				"Provide valid release type in " + configFile + ".");
		}

		var hasArchiveInstructions = Reflect.hasField(source, "archiveInstructions");
		var archiveInstructionsRaw = Reflect.field(source, "archiveInstructions");
		var archiveInstructions:Array<ArchiveInstruction> = null;
		switch(type)
		{
			case ReleaseType.GIT:
				if(hasArchiveInstructions)
					throw new Error(
						"Invalid release configuration!",
						"Git release does not use archiveInstructions.",
						"Remove archiveInstructions configuration for git release.");
			case ReleaseType.HAXELIB:
				if(!hasArchiveInstructions)
					throw new Error(
						"Invalid release configuration!",
						"Haxelib release requires archiveInstructions.",
						"Provide archiveInstructions configuration for haxelib release.");
				var archiveInstructionsParser = new ArchiveInstructionParser();
				archiveInstructionsParser.configFile = configFile;
				archiveInstructions = archiveInstructionsParser.parseList(archiveInstructionsRaw);
		}

		var result = new Release(type);
		result.haxelib = Reflect.field(source, "haxelib");
		result.archiveInstructions = archiveInstructions;
		return result;
	}
}