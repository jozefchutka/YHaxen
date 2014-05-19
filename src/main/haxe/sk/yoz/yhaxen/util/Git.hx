package sk.yoz.yhaxen.util;

import sk.yoz.yhaxen.valueObject.Error;

class Git
{
	public static function checkout(source:String, branch:String, directory:String):Void
	{
		var cwd = Sys.getCwd();

		if(System.command("git", ["clone", "--quiet", source, directory]) != 0)
			throw new Error("Git clone failed.",
				"Git command is not configured or repository does not exist.",
				"Make sure git is configured and repository exists.");

		Sys.setCwd(directory);

		if(System.command("git", ["checkout", "--quiet", "-b", "yhaxen-" + branch, branch]) != 0)
			throw new Error("Git checkout failed.",
				"Git was not able to checkout branch, tag or commit " + branch + ".",
				"Make sure " + branch + " exists in git repository.");

		Sys.setCwd(cwd);
	}
}