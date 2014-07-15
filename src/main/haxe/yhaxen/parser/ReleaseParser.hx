package yhaxen.parser;

import yhaxen.enums.ReleaseType;
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

		var result = new Release(type);
		result.files = Reflect.field(source, "files");
		return result;
	}
}