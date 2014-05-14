package sk.yoz.yhaxen.parsers;

import sk.yoz.yhaxen.enums.SourceType;
import sk.yoz.yhaxen.parsers.GenericParser;
import sk.yoz.yhaxen.valueObjects.config.Root;
import sk.yoz.yhaxen.valueObjects.config.DependencyDetail;
import sk.yoz.yhaxen.valueObjects.Error;

class DependencyParser extends GenericParser<DependencyDetail>
{
	override function parse(source:Dynamic):DependencyDetail
	{
		if(!Reflect.hasField(source, "name"))
			throw new Error(
				"Missing dependency name!",
				"Dependency definition is missing required name field.",
				"Provide dependency name in " + Root.FILENAME + ".");

		var name:String = Reflect.field(source, "name");
		if(!Reflect.hasField(source, "version"))
			throw new Error(
				"Missing dependency version!",
				"Dependency " + name + " is missing required version field.",
				"Provide dependency version in " + Root.FILENAME + ".");

		if(!Reflect.hasField(source, "sourceType"))
			throw new Error(
				"Missing dependency sourceType!",
				"Dependency " + name + " is missing sourceType field.",
				"Provide dependency sourceType in " + Root.FILENAME + ".");

		var sourceTypeRaw:String = Reflect.field(source, "sourceType");
		var sourceType:SourceType;
		try
		{
			sourceType = GenericParser.parseEnum(SourceType, sourceTypeRaw);
		}
		catch(error:Dynamic)
		{
			throw new Error(
				"Invalid dependency sourceType!",
				"Dependency " + name + " has invalid sourceType value " + sourceTypeRaw + ".",
				"Provide valid dependency sourceType in " + Root.FILENAME + ".");
		}

		if(sourceType == SourceType.GIT && !Reflect.hasField(source, "source"))
			throw new Error(
				"Missing dependency source!",
				"Dependency " + name + " is missing source field.",
				"Provide dependency source in " + Root.FILENAME + ".");

		var result:DependencyDetail = new DependencyDetail(
			name,
			Reflect.field(source, "version"),
			sourceType,
			Reflect.field(source, "source"));

		result.scope = Reflect.field(source, "scope");

		result.classPath = Reflect.field(source, "classPath");
		if(result.classPath == "")
			result.classPath = null;

		result.sourceType = Reflect.hasField(source, "sourceType")
			? GenericParser.parseEnum(SourceType, Reflect.field(source, "sourceType"))
			: SourceType.GIT;

		if(Reflect.hasField(source, "forceVersion"))
			result.forceVersion = Reflect.field(source, "forceVersion");

		return result;
	}
}