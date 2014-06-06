package yhaxen.phase;

import yhaxen.phase.TestPhase;
import haxe.io.Path;

import yhaxen.enums.ReleaseType;
import yhaxen.parser.ConfigParser;
import yhaxen.phase.CompilePhase;
import yhaxen.util.Git;
import yhaxen.util.Haxelib;
import yhaxen.util.System;
import yhaxen.util.Zip;
import yhaxen.valueObject.command.ReleaseCommand;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.config.Release;
import yhaxen.valueObject.Error;

class ReleasePhase extends AbstractPhase
{
	inline static var DEFAULT_MESSAGE:String = "Regular release by YHaxen.";

	public var version(default, null):String;
	public var message(default, null):String;

	var testPhase:TestPhase;

	public function new(config:Config, configFile:String, followPhaseFlow:Bool, version:String, message:String)
	{
		super(config, configFile, followPhaseFlow);

		this.version = version;
		this.message = message;
	}

	public static function fromCommand(command:ReleaseCommand):ReleasePhase
	{
		var config = ConfigParser.fromFile(command.configFile);
		return new ReleasePhase(config, command.configFile, command.followPhaseFlow, command.version, command.message);
	}

	override function execute():Void
	{
		super.execute();

		if(config.releases == null || config.releases.length == 0)
			return logPhase("release", "No releases found.");

		logPhase("release", "Found " + config.releases.length + " releases.");

		for(release in config.releases)
			resolveRelease(release);
	}

	override function executePreviousPhase():Void
	{
		testPhase = new TestPhase(config, configFile, followPhaseFlow);
		testPhase.haxelib = haxelib;
		testPhase.execute();
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

	function getResolvedFiles(release:Release):Array<String>
	{
		var result:Array<String> = [];
		for(item in release.files)
		{
			var file = resolveVariable(item, release);
			result.push(file);
		}
		return result;
	}

	function releaseGit(release:Release):Void
	{
		var files = getResolvedFiles(release);
		for(file in files)
			if(StringTools.endsWith(file, Haxelib.FILE_HAXELIB))
				updateHaxelibJson(file);

		var commit = Git.getCurrentCommit();

		for(file in files)
			Git.add(file);

		Git.commit("YHaxen release " + version + ".");
		Git.tag(version, "YHaxen release " + version + ".");

		for(file in files)
		{
			try
			{
				Git.checkoutFile(commit, file);
				Git.add(file);
			}
			catch(error:Error)
			{
				Git.rmKeepLocal(file);
			}
		}

		Git.commit("YHaxen release " + version + " revert.");
		Git.pushWithTags();
	}

	function releaseHaxelib(release:Release):Void
	{
		var files = getResolvedFiles(release);
		var zip:Zip = new Zip();
		for(file in files)
		{
			if(StringTools.endsWith(file, Haxelib.FILE_HAXELIB))
				updateHaxelibJson(file);

			zip.add(file, Path.withoutDirectory(file));
		}

		createTempDirectory();
		var file = AbstractPhase.TEMP_DIRECTORY + "/release.zip";
		zip.save(file);
		System.command("haxelib", ["submit", file]);
		deleteTempDirectory();
	}

	function updateHaxelibJson(file:String):Void
	{
		var message:String = this.message == null || this.message == "" ? DEFAULT_MESSAGE : this.message;
		if(!haxelib.updateHaxelibFile(file, version, message))
			throw new Error(
				"Invalid " + Haxelib.FILE_HAXELIB + " file!",
				"Release related file " + file + " does not exist or is invalid.",
				"Provide correct path to " + Haxelib.FILE_HAXELIB + " file in " + configFile + ".");
	}
}