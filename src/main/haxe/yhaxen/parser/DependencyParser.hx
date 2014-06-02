package yhaxen.parser;

import yhaxen.enums.SourceType;
import yhaxen.valueObject.config.DependencyDetail;
import yhaxen.valueObject.Error;

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

		var hasSource = Reflect.hasField(source, "source");
		if(type == SourceType.GIT && !hasSource)
			throw new Error(
				"Missing dependency source!",
				"Dependency " + name + " is missing source field.",
				"Provide dependency source in " + configFile + ".");

		if(type == SourceType.HAXELIB && hasSource)
			throw new Error(
				"Invalid dependency source!",
				"Haxelib dependency " + name + " should not contain source field.",
				"Remove source field in " + configFile + ".");

		var result:DependencyDetail = new DependencyDetail(
			name,
			Reflect.field(source, "version"),
			type,
			Reflect.field(source, "source"));

		if(Reflect.hasField(source, "scopes"))
			result.scopes = Reflect.field(source, "scopes");
		if(result.scopes != null && result.scopes.length == 0)
			result.scopes = null;

		if(Reflect.hasField(source, "update"))
			result.update = Reflect.field(source, "update");

		result.classPath = Reflect.field(source, "classPath");
		if(result.classPath == "")
			result.classPath = null;

		if(Reflect.hasField(source, "forceVersion"))
			result.forceVersion = Reflect.field(source, "forceVersion");

		return result;
	}
}