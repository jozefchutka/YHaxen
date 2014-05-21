package sk.yoz.yhaxen.phase;

import StringTools;
import sk.yoz.yhaxen.util.Git;
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

	var haxelib:Haxelib;
	var compilePhase:CompilePhase;

	public function new(config:Config, configFile:String, scope:String, verbose:Bool, version:String)
	{
		super(config, configFile, scope, verbose);

		this.version = version;
		haxelib = new Haxelib();
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
		for(file in release.files)
			if(StringTools.endsWith(file, Haxelib.FILE_HAXELIB))
				updateHaxelibJson(file);

		var commit = Git.getCurrentCommit();

		for(file in release.files)
			Git.add(file);

		Git.commit("YHaxen release " + version + ".");
		Git.tag(version, "YHaxen release " + version + ".");

		for(file in release.files)
		{
			Git.checkoutFile(commit, file);
			Git.add(file);
		}

		Git.commit("YHaxen release " + version + " revert.");
		Git.pushWithTags();
	}

	function releaseHaxelib(release:Release):Void
	{

	}

	function updateHaxelibJson(file:String):Void
	{
		if(!haxelib.updateVersionInFile(file, version))
			throw new Error(
				"Invalid " + Haxelib.FILE_HAXELIB + " file!",
				"Release related file " + file + " does not exist or is invalid.",
				"Provide correct path to " + Haxelib.FILE_HAXELIB + " file in " + configFile + ".");
	}
}