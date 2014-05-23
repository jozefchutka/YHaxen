package yhaxen.parser;

import haxe.Json;

import yhaxen.valueObject.config.Build;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.config.DependencyDetail;
import yhaxen.valueObject.config.Release;

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

		if(Reflect.hasField(source, "releases"))
		{
			var releaseParser = new ReleaseParser();
			releaseParser.configFile = configFile;
			result.releases = releaseParser.parseList(Reflect.field(source, "releases"));
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
		filterScope(result, scope);
		return result;
	}

	static function filterScope(config:Config, scope:String):Void
	{
		if(scope == null)
			return;

		if(config.dependencies != null)
		{
			var dependencies:Array<DependencyDetail> = [];
			for(dependency in config.dependencies)
				if(dependency.matchesScope(scope))
					dependencies.push(dependency);
			config.dependencies = dependencies;
		}

		if(config.builds != null)
		{
			var builds:Array<Build> = [];
			for(build in config.builds)
				if(build.matchesScope(scope))
					builds.push(build);
			config.builds = builds;
		}

		if(config.releases != null)
		{
			var releases:Array<Release> = [];
			for(release in config.releases)
				if(release.matchesScope(scope))
					releases.push(release);
			config.releases = releases;
		}
	}

	static function checkFile(file:String):Void
	{
		if(!FileSystem.exists(file))
			throw "File " + file + " does not exist!";

		if(FileSystem.isDirectory(file))
			throw file + " is not a file!";
	}
}