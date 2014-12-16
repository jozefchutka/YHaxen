package yhaxen.util;

import yhaxen.valueObject.Error;

import sys.io.Process;

class Git
{
	static function execute(arguments:Array<String>, directory:String):{exitCode:Int, result:String}
	{
		var cwd = Sys.getCwd();
		if(directory != null)
			Sys.setCwd(directory);

		var process:Process = System.process("git", arguments);
		var exitCode = process.exitCode();
		var result = StringTools.trim(process.stdout.readAll().toString());

		if(directory != null)
			Sys.setCwd(cwd);
		return {exitCode:exitCode, result:result};
	}

	public static function clone(source:String, directory:String):Void
	{
		if(execute(["clone", "--quiet", source, directory], null).exitCode != 0)
			throw new Error(
				"Git clone failed.",
				"Git command is not configured or repository does not exist.",
				"Make sure git is configured and repository exists.");
	}

	public static function checkout(branch:String, directory:String=null):Void
	{
		if(execute(["checkout", "--quiet", branch], directory).exitCode != 0)
			throw new Error(
				"Git checkout failed.",
				"Git was not able to checkout branch, tag or commit " + branch + ".",
				"Make sure " + branch + " exists in git repository.");
	}

	public static function createBranch(branch:String, directory:String=null):Void
	{
		if(execute(["checkout", "--quiet", "-b", branch], directory).exitCode != 0)
			throw new Error(
				"Git checkout failed.",
				"Git was not able to create branch " + branch + ".",
				"Make sure " + branch + " is a valid branch name.");
	}

	public static function deleteBranch(branch:String, directory:String=null):Void
	{
		if(execute(["branch", "--quiet", "-D", branch], directory).exitCode != 0)
			throw new Error(
				"Git checkout failed.",
				"Git was not able to delete branch " + branch + ".",
				"Make sure " + branch + " is a valid branch.");
	}


	public static function pull(directory:String=null):Void
	{
		if(execute(["pull", "--quiet"], directory).exitCode != 0)
			throw new Error(
				"Git pull failed.",
				"Git was not able to pull.",
				"Make sure directory " + directory + " is valid git repository.");
	}

	public static function fetchAll(directory:String=null):Void
	{
		if(execute(["fetch", "--quiet", "--all"], directory).exitCode != 0)
			throw new Error(
				"Git fetch failed.",
				"Git was not able to fetch.",
				"Make sure directory " + directory + " is valid git repository.");
	}

	public static function getCurrentCommit(directory:String=null):String
	{
		var execution = execute(["rev-parse", "HEAD"], directory);
		if(execution.exitCode != 0)
			throw new Error(
				"Git rev-parse failed.",
				"Git was not able to get current commit.",
				"Make sure project is under git control and current user has suffucient rights.");
		return execution.result;
	}

	public static function getCurrentBranch(directory:String=null):String
	{
		var execution = execute(["rev-parse", "--abbrev-ref", "HEAD"], directory);
		if(execution.exitCode != 0)
			throw new Error(
			"Git rev-parse failed.",
			"Git was not able to get current branch.",
			"Make sure project is under git control and current user has suffucient rights.");
		return execution.result;
	}

	public static function add(file:String, directory:String=null):Void
	{
		if(execute(["add", file], directory).exitCode != 0)
			throw new Error(
				"Git add failed.",
				"Git was not able to add file " + file + ".",
				"Make sure project is under git control and file " + file + " exists.");
	}

	public static function commit(message:String, directory:String=null):Void
	{
		if(execute(["commit", "-m", message], directory).exitCode != 0)
			throw new Error(
				"Git commit failed.",
				"Git was not able to commit.",
				"Make sure project is under git control.");
	}


	public static function tag(version:String, message:String, directory:String=null):Void
	{
		if(execute(["tag", "-a", version, "-m", message], directory).exitCode != 0)
			throw new Error(
				"Git tag failed.",
				"Git was not able to tag.",
				"Make sure project is under git control.");
	}

	public static function checkoutFile(commit:String, file:String, directory:String=null):Void
	{
		if(execute(["checkout", commit, "--", file], directory).exitCode != 0)
			throw new Error(
				"Git checkout failed.",
				"Git was not able to checkot " + file + " from " + commit + ".",
				"Make sure project is under git control.");
	}

	public static function rmCachedFile(file:String, directory:String=null):Void
	{
		if(execute(["rm", "--cached", file], directory).exitCode != 0)
			throw new Error(
				"Git rm failed.",
				"Git was not able to remove " + file + ".",
				"Make sure project is under git control.");
	}

	public static function pushTag(tag:String, directory:String=null):Void
	{
		if(execute(["push", "origin", tag], directory).exitCode != 0)
			throw new Error(
				"Git push failed.",
				"Git was not able to push tag to origin.",
				"Make sure project is under git control and " + tag + " is a valid tag name.");
	}



	public static function getRemoteOriginUrl(directory:String=null):String
	{
		var execution = execute(["config", "--get", "remote.origin.url"], directory);
		if(execution.exitCode != 0)
			throw new Error(
				"Git config failed.",
				"Git was not able to get current remote origin url.",
				"Make sure directory is under git control.");

		return execution.result;
	}
}