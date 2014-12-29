package yhaxen.parser;

import yhaxen.enums.SourceType;
import yhaxen.valueObject.config.Dependency;
import yhaxen.valueObject.Error;

class DependencyParser extends GenericParser<Dependency>
{
	public var configFile:String;

	override function parse(source:Dynamic):Dependency
	{
		checkUnexpectedFields(source, Dependency);

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

		var hasSubdirectory = Reflect.hasField(source, "subdirectory");
		if(type == SourceType.HAXELIB && hasSubdirectory)
			throw new Error(
				"Invalid dependency subdirectory!",
				"Haxelib dependency " + name + " should not contain subdirectory field.",
				"Remove subdirectory field in " + configFile + ".");

		var result:Dependency = new Dependency(
			name,
			Reflect.field(source, "version"),
			type,
			Reflect.field(source, "source"));

		if(hasSubdirectory)
			result.subdirectory = Reflect.field(source, "subdirectory");
		if(result.subdirectory == "")
			result.subdirectory = null;

		if(Reflect.hasField(source, "scopes"))
		{
			var scopes:Array<String> = Reflect.field(source, "scopes");
			if(scopes != null && scopes.length != 0)
				result.scopes = scopes;
		}

		if(Reflect.hasField(source, "update"))
			result.update = Reflect.field(source, "update");

		if(Reflect.hasField(source, "forceVersion"))
			result.forceVersion = Reflect.field(source, "forceVersion");

		if(Reflect.hasField(source, "useCurrent"))
			result.useCurrent = Reflect.field(source, "useCurrent");

		if(Reflect.hasField(source, "makeCurrent"))
			result.makeCurrent = Reflect.field(source, "makeCurrent");

		if(result.useCurrent && result.makeCurrent)
			throw new Error(
				"Invalid dependency useCurrent makeCurrent combination!",
				"Haxelib dependency " + name + " should not have both useCurrent and makeCurrent enabled at the same time.",
				"Remove useCurrent or makeCurrent field in " + configFile + ".");

		return result;
	}
}