package yhaxen.phase;

import tools.haxelib.SemVer;

import yhaxen.enums.ReleaseType;
import yhaxen.parser.ConfigParser;
import yhaxen.phase.CompilePhase;
import yhaxen.util.Git;
import yhaxen.util.Haxelib;
import yhaxen.util.ScopeUtil;
import yhaxen.util.System;
import yhaxen.util.Zip;
import yhaxen.valueObject.command.ReleaseCommand;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.config.Dependency;
import yhaxen.valueObject.config.Release;
import yhaxen.valueObject.Error;

class ReleasePhase extends AbstractPhase
{
	inline static var DEFAULT_MESSAGE:String = "Release ${arg:-version}.";

	public var version(default, null):String;
	public var message(default, null):String;

	var compilePhase:CompilePhase;

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
		compilePhase = new CompilePhase(config, configFile, followPhaseFlow, null);
		compilePhase.haxelib = haxelib;
		compilePhase.execute();
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
		if(release.haxelib != null)
			updateHaxelibJson(release, resolveVariable(release.haxelib, release), false);

		var currentBranch = Git.getCurrentBranch();
		var releaseBranch = "release_" + version;
		var message:String = getReleaseMessage(release);

		Git.createBranch(releaseBranch);
		Git.add(".");
		Git.commit(message);
		Git.tag(version, message);
		Git.pushTag(version);
		Git.checkout(currentBranch);
		Git.deleteBranch(releaseBranch);
	}

	function releaseHaxelib(release:Release):Void
	{
		var zip:Zip = new Zip();

		if(release.haxelib != null)
			updateHaxelibJson(release, resolveVariable(release.haxelib, release), true);

		for(instruction in release.archiveInstructions)
		{
			var source = resolveVariable(instruction.source, release);
			var target = resolveVariable(instruction.target, release);
			zip.add(source, target);
		}

		var file = "release.zip";
		zip.save(file);
		System.command("haxelib", ["submit", file]);
	}

	function updateHaxelibJson(release:Release, file:String, forHaxelib:Bool):Void
	{
		var message:String = getReleaseMessage(release);
		var dependencies:Dynamic = getHaxelibJsonDependencies(forHaxelib);
		if(!haxelib.updateHaxelibFile(file, version, dependencies, message))
			throw new Error(
				"Invalid " + Haxelib.FILE_HAXELIB + " file!",
				"Release related file " + file + " does not exist or is invalid.",
				"Provide correct path to " + Haxelib.FILE_HAXELIB + " file in " + configFile + ".");
	}

	/**
	 * Haxelib does not like dependencies with version other then semver format submitted.
	 **/
	function getHaxelibJsonDependencies(forHaxelib:Bool):Dynamic
	{
		var result = {};
		var dependencies = getScopedDependencies();
		for(dependency in dependencies)
		{
			var version = dependency.version;
			if(forHaxelib)
			{
				try
				{
					SemVer.ofString(dependency.version);
				}
				catch(error:Dynamic)
				{
					version = "";
				}
			}

			Reflect.setProperty(result, dependency.name, version);
		}

		return result;
	}

	function getReleaseMessage(release:Release):String
	{
		var result = message == null || message == "" ? DEFAULT_MESSAGE : message;
		return resolveVariable(result, release);
	}

	public function getScopedDependencies():Array<Dependency>
	{
		var result:Array<Dependency> = [];
		var scopes = config.getBuildScopes();
		if(scopes != null)
			for(dependency in config.dependencies)
				if(!Lambda.has(result, dependency))
					for(scope in scopes)
						if(ScopeUtil.matches(dependency.scopes, scope))
							result.push(dependency);
		return result;
	}
}