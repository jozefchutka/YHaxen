package sk.yoz.yhaxen.parser;

import haxe.Json;

import sk.yoz.yhaxen.valueObject.config.Config;
import sk.yoz.yhaxen.valueObject.config.DependencyDetail;

import sys.io.File;
import sys.FileSystem;

class ConfigParser extends GenericParser<Config>
{
	public var configFile:String;

	override function parse(source:Dynamic):Config
	{
		if(!Reflect.hasField(source, "version"))
			throw "Missing version.";

		var version = Reflect.field(source, "version");
		var result:Config = new Config(version);
		if(Reflect.hasField(source, "dependencies"))
		{
			var dependencyParser = new DependencyParser();
			dependencyParser.configFile = configFile;
			result.dependencies = dependencyParser.parseList(Reflect.field(source, "dependencies"));
		}

		if(Reflect.hasField(source, "builds"))
		{
			var buildParser = new BuildParser();
			buildParser.configFile = configFile;
			result.builds = buildParser.parseList(Reflect.field(source, "builds"));
		}

		return result;
	}

	public static function fromFile(configFile:String, scope:String=null):Config
	{
		checkFile(configFile);
		var data = File.getContent(configFile);
		var json:Dynamic;
		try
		{
			json = Json.parse(data);
		}
		catch(error:String)
		{
			throw "Unable to parse " + configFile + ". " + error;
		}

		var parser = new ConfigParser();
		parser.configFile = configFile;
		var result = parser.parse(json);

		if(scope != null)
		{
			var dependencies:Array<DependencyDetail> = [];
			for(dependency in result.dependencies)
				if(dependency.scope == null || Lambda.has(dependency.scope, scope))
					dependencies.push(dependency);
			result.dependencies = dependencies;
		}
		return result;
	}

	static function checkFile(file:String):Void
	{
		if(!FileSystem.exists(file))
			throw "File " + file + " does not exist!";

		if(FileSystem.isDirectory(file))
			throw file + " is not a file!";
	}
}