package sk.yoz.yhaxen.parser;

import sk.yoz.yhaxen.enums.SourceType;
import sk.yoz.yhaxen.valueObject.config.DependencyDetail;
import sk.yoz.yhaxen.valueObject.Error;

class DependencyParser extends GenericParser<DependencyDetail>
{
	public var configFile:String;

	override function parse(source:Dynamic):DependencyDetail
	{
		if(!Reflect.hasField(source, "name"))
			throw new Error(
				"Missing dependency name!",
				"Dependency definition is missing required name field.",
				"Provide dependency name in " + configFile + ".");

		var name:String = Reflect.field(source, "name");
		if(!Reflect.hasField(source, "version"))
			throw new Error(
				"Missing dependency version!",
				"Dependency " + name + " is missing required version field.",
				"Provide dependency version in " + configFile + ".");

		if(!Reflect.hasField(source, "type"))
			throw new Error(
				"Missing dependency type!",
				"Dependency " + name + " is missing type field.",
				"Provide dependency type in " + configFile + ".");

		var typeRaw:String = Reflect.field(source, "type");
		var type:SourceType;
		try
		{
			type = GenericParser.parseEnum(SourceType, typeRaw);
		}
		catch(error:Dynamic)
		{
			throw new Error(
				"Invalid dependency type!",
				"Dependency " + name + " has invalid type value " + typeRaw + ".",
				"Provide valid dependency type in " + configFile + ".");
		}

		if(type == SourceType.GIT && !Reflect.hasField(source, "source"))
			throw new Error(
				"Missing dependency source!",
				"Dependency " + name + " is missing source field.",
				"Provide dependency source in " + configFile + ".");

		var result:DependencyDetail = new DependencyDetail(
			name,
			Reflect.field(source, "version"),
			type,
			Reflect.field(source, "source"));

		result.scopes = Reflect.field(source, "scopes");

		result.classPath = Reflect.field(source, "classPath");
		if(result.classPath == "")
			result.classPath = null;

		if(Reflect.hasField(source, "forceVersion"))
			result.forceVersion = Reflect.field(source, "forceVersion");

		return result;
	}
}