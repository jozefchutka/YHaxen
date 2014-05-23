package yhaxen.util;

import yhaxen.valueObject.Error;

import sys.io.Process;

class Git
{
	public static function checkout(source:String, branch:String, directory:String):Void
	{
		var cwd = Sys.getCwd();

		if(System.command("git", ["clone", "--quiet", source, directory]) != 0)
			throw new Error(
				"Git clone failed.",
				"Git command is not configured or repository does not exist.",
				"Make sure git is configured and repository exists.");

		Sys.setCwd(directory);

		if(System.command("git", ["checkout", "--quiet", "-b", "yhaxen-" + branch, branch]) != 0)
			throw new Error(
				"Git checkout failed.",
				"Git was not able to checkout branch, tag or commit " + branch + ".",
				"Make sure " + branch + " exists in git repository.");

		Sys.setCwd(cwd);
	}

	public static function getCurrentCommit():String
	{
		var process:Process = System.process("git", ["rev-parse", "HEAD"]);
		if(process.exitCode() != 0)
			throw new Error(
				"Git rev-parse failed.",
				"Git was not able to get current commit.",
				"Make sure project is under git control and current user has suffucient rights.");
		return StringTools.trim(process.stdout.readAll().toString());
	}

	public static function add(file:String):Void
	{
		if(System.command("git", ["add", file]) != 0)
			throw new Error(
				"Git add failed.",
				"Git was not able to add file " + file + ".",
				"Make sure project is under git control and file " + file + " exists.");
	}

	public static function commit(message:String):Void
	{
		if(System.command("git", ["commit", "-m", message]) != 0)
			throw new Error(
				"Git commit failed.",
				"Git was not able to commit.",
				"Make sure project is under git control.");
	}


	public static function tag(version:String, message:String):Void
	{
		if(System.command("git", ["tag", "-a", version, "-m", message]) != 0)
			throw new Error(
				"Git tag failed.",
				"Git was not able to tag.",
				"Make sure project is under git control.");
	}

	public static function checkoutFile(commit:String, file:String):Void
	{
		if(System.command("git", ["checkout", commit, "--", file]) != 0)
			throw new Error(
				"Git checkout failed.",
				"Git was not able to checkot " + file + " from " + commit + ".",
				"Make sure project is under git control.");
	}

	public static function rm(file:String):Void
	{
		if(System.command("git", ["rm", file]) != 0)
			throw new Error(
				"Git rm failed.",
				"Git was not able to remove " + file + ".",
				"Make sure project is under git control.");
	}

	public static function pushWithTags():Void
	{
		if(System.command("git", ["push", "origin", "--all"]) != 0)
			throw new Error(
				"Git push failed.",
				"Git was not able to push to origin.",
				"Make sure project is under git control.");

		if(System.command("git", ["push", "origin", "--tags"]) != 0)
			throw new Error(
				"Git push failed.",
				"Git was not able to push to origin.",
				"Make sure project is under git control.");
	}
}