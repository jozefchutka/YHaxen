package sk.yoz.yhaxen.phase;

import sk.yoz.yhaxen.valueObject.dependency.Version;
import sk.yoz.yhaxen.valueObject.dependency.Version;
import sk.yoz.yhaxen.enums.SourceType;
import sk.yoz.yhaxen.helper.Git;
import sk.yoz.yhaxen.helper.Haxelib;
import sk.yoz.yhaxen.helper.System;
import sk.yoz.yhaxen.valueObject.config.Config;
import sk.yoz.yhaxen.valueObject.config.DependencyDetail;
import sk.yoz.yhaxen.valueObject.command.ValidateCommand;
import sk.yoz.yhaxen.valueObject.dependency.Dependency;
import sk.yoz.yhaxen.valueObject.dependency.DependencyTreeItem;
import sk.yoz.yhaxen.valueObject.dependency.FlattenDependencies;
import sk.yoz.yhaxen.valueObject.Command;
import sk.yoz.yhaxen.valueObject.Error;

import tools.haxelib.Data;

import sys.io.File;
import sys.FileSystem;

class ValidatePhase extends AbstractPhase<ValidateCommand>
{
	inline static var WORD_OK:String = "OK";
	inline static var WORD_MISSING:String = "MISSING";
	inline static var WORD_CONFLICT:String = "CONFLICT";
	inline static var WORD_ROOT:String = "<ROOT>";
	inline static var WORD_INVALID:String = "INVALID";
	inline static var WORD_UNDEFINED:String = "UNDEFINED";

	private var haxelib:Haxelib;

	public function new(command:ValidateCommand)
	{
		super(command);

		haxelib = new Haxelib();
	}

	override function execute():Void
	{
		for(item in config.dependencies)
			validateDependency(item);

		var list:Array<Dependency> = [];
		var tree = getTree();
		var flatten = flattenTree(tree);

		log("");
		log("Legend:");
		logKeyVal("  " + WORD_OK, 20, "Dependency exists.");
		logKeyVal("  " + WORD_MISSING, 20, "Dependency needs to be installed.");
		logKeyVal("  " + WORD_CONFLICT, 20, "Different versions of dependencies used across project.");
		logKeyVal("  " + WORD_ROOT, 20, "Project level.");

		log("");
		log("Tree:");
		validateTree(tree);

		log("");
		log("Flatten:");
		validateFlatten(flatten);

		log("");
		log("Compilation:");
		validateCompile(flatten);
	}

	function validateDependency(dependency:DependencyDetail)
	{
		log("");
		log("Resolving " + dependency.toString());

		if(haxelib.versionExists(dependency.name, dependency.version))
		{
			log("  Dependency already installed.");
		}
		else
		{
			switch(dependency.sourceType)
			{
				case SourceType.GIT:
					installDependencyGit(dependency);
				case SourceType.HAXELIB:
					installDependencyHaxelib(dependency);
			}
		}
	}

	function validateTree(list:Array<DependencyTreeItem>, level:Int=0):Void
	{
		for(item in list)
		{
			var result:String = WORD_INVALID;
			if(item.metadata.versionResolved != null)
				result = (item.metadata.versionResolved.exists ? WORD_OK : WORD_MISSING) + " (" + item.metadata.versionResolved.key + ")";

			var pad:String = StringTools.lpad("", " ", level * 2 + 2);
			logKeyVal(pad + item.toString(), 40, result);

			if(item.metadata.isDev)
				throw new Error(
					"Invalid dependency " + item.name + "!",
					"Dependency " + item.name + " is dev dependency, not recommended for projects.",
					"Execute \"haxelib dev " + item.name + "\" to turn of dev dependency.");

			if(item.metadata.versionResolved == null)
				throw new Error(
					"Invalid dependency " + item.name + "!",
					"Dependency " + item.name + " is defined without version information.",
					"Provide forcedVersion in " + Config.DEFAULT_FILENAME + " for this dependency.");

			if(!item.metadata.versionResolved.exists && item.metadata.versionForced == null)
				throw new Error(
					"Missing dependency " + item.name + "!",
					"Dependency " + item.name + " with resolved version " + item.metadata.versionResolved.key + " is missing.",
					"Install dependency using " + Command.KEY_VALIDATE + " command or provide forcedVersion in " + Config.DEFAULT_FILENAME + ".");

			if(!item.metadata.versionResolved.exists)
				throw new Error(
					"Missing dependency " + item.name + "!",
					"Dependency " + item.name + " with resolved version " + item.metadata.versionResolved.key + " is missing.",
					"Install dependenciy using " + Command.KEY_VALIDATE + " command.");

			if(item.dependencies != null)
				validateTree(item.dependencies, level + 1);
		}
	}

	function validateFlatten(data:FlattenDependencies):Void
	{
		for(name in data.keys())
		{
			var dataName = data.get(name);
			var versions:Array<String> = [];
			for(version in dataName.keys())
				if(version != WORD_UNDEFINED && Lambda.indexOf(versions, version) == -1)
					versions.push(version);

			if(versions.length == 1)
			{
				logKeyVal("  " + name, 40, WORD_OK + " (" + versions[0] + ")");
				continue;
			}

			logKeyVal("  " + name, 40, WORD_CONFLICT);
			for(version in dataName.keys())
			{
				if(version == WORD_UNDEFINED)
					continue;
				var sources = dataName.get(version);
				for(source in sources)
					logKeyVal("    in " + (source == null ? WORD_ROOT : source.toString()), 40, " ! (" + version + ")");
			}

			var detail = DependencyDetail.getFromList(config.dependencies, name);
			if(detail == null || detail.metadata.versionForced == null)
				throw new Error(
					"Invalid dependency version for " + name + "!",
					"Dependency " + name + " has multiple versions used.",
					"Provide forcedVersion in " + Config.DEFAULT_FILENAME + ".");
		}
	}

	function validateCompile(data:FlattenDependencies):Void
	{
		var items:Array<String> = [];
		for(name in data.keys())
			for(version in data.get(name).keys())
				if(version != WORD_UNDEFINED)
					items.push("-lib " + name + ":" + version);
		log(items.join(" "));
	}

	function getTree():Array<DependencyTreeItem>
	{
		var result:Array<DependencyTreeItem> = [];
		for(detail in config.dependencies)
		{
			var item = new DependencyTreeItem(detail.name, detail.version);
			updateMetadata(item);
			item.dependencies = getDependencyTree(item);
			result.push(item);
		}
		return result;
	}

	function flattenTree(list:Array<DependencyTreeItem>, parent:DependencyTreeItem=null,
		target:FlattenDependencies=null):FlattenDependencies
	{
		if(list == null || list.length == 0)
			return null;

		if(target == null)
			target = new FlattenDependencies();

		for(item in list)
		{
			if(!target.exists(item.name))
				target.set(item.name, new Map<String,Array<DependencyTreeItem>>());
			var targetName = target.get(item.name);
			var version = item.version == null ? WORD_UNDEFINED : item.version;
			if(!targetName.exists(version))
				targetName.set(version, []);
			var targetNameVersion = targetName.get(version);
			if(!DependencyTreeItem.listContainsByNameAndVersion(targetNameVersion, parent))
				targetNameVersion.push(parent);
			flattenTree(item.dependencies, item, target);

		}

		return target;
	}

	function installDependencyGit(dependency:DependencyDetail):Void
	{
		var tmp:String = ".temp";
		if(FileSystem.exists(tmp))
			haxelib.deleteDirectory(tmp);
		FileSystem.createDirectory(tmp);
		try
		{
			Git.checkout(dependency.source, dependency.version, tmp);
		}
		catch(error:Dynamic)
		{
			haxelib.deleteDirectory(tmp);
			throw error;
		}

		haxelib.deleteDirectory(tmp + "/.git");
		var projectDirectory:String = haxelib.getProjectDirectory(dependency.name);
		haxelib.ensureDirectoryExists(projectDirectory);

		var target:String = haxelib.getVersionDirectory(dependency.name, dependency.version, false, null);
		var source:String = tmp;
		if(dependency.classPath != null)
		{
			FileSystem.rename(source + "/" + dependency.classPath, target);
			haxelib.deleteDirectory(tmp);
		}
		else
		{
			FileSystem.rename(source, target);
		}

		var currentFile:String = projectDirectory + "/" + Haxelib.FILE_CURRENT;
		if(!FileSystem.exists(currentFile))
			File.saveContent(currentFile, dependency.version);
	}

	function installDependencyHaxelib(dependency:DependencyDetail):Void
	{
		System.command("haxelib", ["install", dependency.name, dependency.version]);
	}

	function getDependencyTree(dependency:Dependency):Array<DependencyTreeItem>
	{
		var directory:String = haxelib.getVersionDirectory(dependency.name, dependency.version,
			dependency.metadata.isDev, dependency.metadata.versionCurrent.key);

		if(directory == null)
			return null;

		var path:String = directory + "/" + Haxelib.FILE_HAXELIB;
		if(!FileSystem.exists(path))
			return null;

		var haxelibJson = File.getContent(path);
		var list = Data.readData(haxelibJson, false);
		var result:Array<DependencyTreeItem> = [];
		for(info in list.dependencies)
		{
			var name = info.project;
			var version = info.version;
			var item = new DependencyTreeItem(name, version);
			updateMetadata(item);
			item.dependencies = item.metadata.exists ? getDependencyTree(item) : null;
			result.push(item);
		}
		return result;
	}

	function updateMetadata(item:Dependency):Void
	{
		var detail = DependencyDetail.getFromList(config.dependencies, item.name);
		var metadata = item.metadata;
		metadata.exists = haxelib.dependencyExists(item.name);
		metadata.isDev = metadata.exists && haxelib.isDev(item.name);

		metadata.versionExists = item.version == null
			? false
			: metadata.exists && haxelib.versionExists(item.name, item.version);

		metadata.versionForced = (detail != null && detail.forceVersion)
			? new Version(detail.version, metadata.exists && haxelib.versionExists(item.name, detail.version))
			: null;

		metadata.versionResolved = metadata.versionForced != null
			? metadata.versionForced.clone()
			: new Version(item.version, metadata.versionExists);

		var currentVersion:String = haxelib.getCurrentVersion(item.name);
		metadata.versionCurrent = metadata.exists
			? new Version(currentVersion, metadata.exists && haxelib.versionExists(item.name, currentVersion))
			: null;
	}
}