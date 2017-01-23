package yhaxen.phase;

import tools.haxelib.SemVer;

import yhaxen.enums.LogLevel;
import yhaxen.enums.ReleaseType;
import yhaxen.parser.ConfigParser;
import yhaxen.phase.CompilePhase;
import yhaxen.util.Git;
import yhaxen.util.Haxelib;
import yhaxen.util.ScopeUtil;
import yhaxen.util.Zip;
import yhaxen.valueObject.command.CompileCommand;
import yhaxen.valueObject.command.ReleaseCommand;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.config.Dependency;
import yhaxen.valueObject.config.Release;
import yhaxen.valueObject.Error;

class ReleasePhase extends AbstractPhase<ReleaseCommand>
{
	inline static var DEFAULT_MESSAGE:String = "Release ${arg:-version}.";

	public static function fromCommand(command:ReleaseCommand):ReleasePhase
	{
		var config = ConfigParser.fromFile(command.configFile);
		return new ReleasePhase(config, command);
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
		new CompilePhase(config, CompileCommand.fromReleaseCommand(command)).execute();
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

		var currentBranch = Git.getCurrentBranch(null, logGit);
		var message:String = getReleaseMessage(release);

		Git.add(".", null, logGit);
		Git.commit(message, null, logGit);
		Git.tag(command.version, message, null, logGit);
		Git.push(currentBranch, null, logGit);
		Git.pushTag(command.version, null, logGit);
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
		systemCommand(LogLevel.DEBUG, "haxelib", ["submit", file]);
	}

	function updateHaxelibJson(release:Release, file:String, forHaxelib:Bool):Void
	{
		var message:String = getReleaseMessage(release);
		var dependencies:Dynamic = getHaxelibJsonDependencies(forHaxelib);
		if(!haxelib.updateHaxelibFile(file, command.version, dependencies, message))
			throw new Error(
				"Invalid " + Haxelib.FILE_HAXELIB + " file!",
				"Release related file " + file + " does not exist or is invalid.",
				"Provide correct path to " + Haxelib.FILE_HAXELIB + " file in " + command.configFile + ".");
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
		var result = command.message == null || command.message == "" ? DEFAULT_MESSAGE : command.message;
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