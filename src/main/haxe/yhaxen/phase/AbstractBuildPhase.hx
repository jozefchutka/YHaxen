package yhaxen.phase;

import yhaxen.enums.LogLevel;
import yhaxen.valueObject.command.AbstractBuildCommand;
import yhaxen.valueObject.config.AbstractBuild;

class AbstractBuildPhase<TBuild:AbstractBuild,TCommand:AbstractBuildCommand> extends AbstractPhase<TCommand>
{
	function getBuilds():Array<TBuild>
	{
		return null;
	}

	function getBuildByPart(part:String):TBuild
	{
		return null;
	}

	override function execute():Void
	{
		super.execute();

		if(command.part != null)
			executePart(command.part);
		else
			executeAll();
	}

	function executeAll():Void
	{
		var builds = getBuilds();
		if(builds == null || builds.length == 0)
			return logPhasesFound(0);

		logPhasesFound(builds.length);

		for(build in builds)
			executeBuild(build);
	}

	function executePart(part:String):Void
	{
		var build = getBuildByPart(part);

		if(build == null)
			throwMissingBuildByPartError(part);

		logPhasesFound(1);
		executeBuild(build);
	}

	function executeBuild(build:TBuild)
	{
		log(LogLevel.INFO, "");
		log(LogLevel.INFO, "# executing " + build.name);

		var command = resolveVariable(build.command, build);
		var arguments = null;

		if(build.arguments != null && build.arguments.length > 0)
			arguments = resolveVariablesInArray(build.arguments, build);

		var cwd = Sys.getCwd();

		if(build.dir != null)
			Sys.setCwd(resolveVariable(build.dir, build));

		if(systemCommand(LogLevel.DEBUG, command, arguments) != 0)
			throwExecuteBuildError(build);

		Sys.setCwd(cwd);
	}

	function logPhasesFound(count:Int)
	{
	}

	function throwMissingBuildByPartError(part:String)
	{
	}

	function throwExecuteBuildError(build:TBuild)
	{
	}
}
