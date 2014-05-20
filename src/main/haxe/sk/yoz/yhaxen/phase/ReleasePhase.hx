package sk.yoz.yhaxen.phase;

import sk.yoz.yhaxen.util.Haxelib;
import sk.yoz.yhaxen.valueObject.Error;
import sys.FileSystem;
import sys.io.File;
import sk.yoz.yhaxen.enums.ReleaseType;
import sk.yoz.yhaxen.parser.ConfigParser;
import sk.yoz.yhaxen.phase.CompilePhase;
import sk.yoz.yhaxen.valueObject.config.Config;
import sk.yoz.yhaxen.valueObject.config.Release;
import sk.yoz.yhaxen.valueObject.command.ReleaseCommand;

class ReleasePhase extends AbstractPhase
{
	public var version(default, null):String;

	var compilePhase:CompilePhase;

	public function new(config:Config, configFile:String, scope:String, verbose:Bool, version:String)
	{
		super(config, configFile, scope, verbose);

		this.version = version;
	}

	public static function fromCommand(command:ReleaseCommand):ReleasePhase
	{
		var config = ConfigParser.fromFile(command.configFile, command.scope);
		return new ReleasePhase(config, command.configFile, command.scope, command.verbose, command.version);
	}

	override function execute():Void
	{
		executeCompilePhase();

		logPhase("release", scope, "Found " + config.releases.length + " releases.");

		validateConfig();

		for(release in config.releases)
			resolveRelease(release);
	}

	function executeCompilePhase():Void
	{
		compilePhase = new CompilePhase(config, configFile, scope, verbose);
		compilePhase.execute();
	}

	function validateConfig():Void
	{

	}

	function resolveRelease(release:Release):Void
	{
		switch(release.type)
		{
			case ReleaseType.GIT:
				releaseGit(release);
			case ReleaseType.HAXELIB:
				releaseHaxelib(release);
		}
	}

	function releaseGit(release:Release):Void
	{
		updateHaxelib(release.haxelib);
	}

	function releaseHaxelib(release:Release):Void
	{
		updateHaxelib(release.haxelib);
	}

	function updateHaxelib(file:String):Void
	{
		if(file == null)
			return;

		if(!FileSystem.exists(file) || FileSystem.isDirectory(file))
			throw new Error(
				"Invalid " + Haxelib.FILE_HAXELIB + " file!",
				"Release related file " + file + " does not exist or is invalid.",
				"Provide correct path to " + Haxelib.FILE_HAXELIB + " file in " + configFile + ".");

		var content = File.getContent(file);
		var result = updateVersionInHaxelib(content, version);
		File.saveContent(file, result);
	}

	function updateVersionInHaxelib(content:String, version:String):String
	{
		var reg:EReg = ~/([\\"\\']version[\\"\\']\s*:\s*[\\"\\'])[^\\"\\']*?([\\"\\'])/;
		return reg.replace(content, "$1" + version + "$2");
	}
}