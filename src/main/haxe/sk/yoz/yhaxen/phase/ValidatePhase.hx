package sk.yoz.yhaxen.phase;

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
import sk.yoz.yhaxen.valueObject.dependency.Version;
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

	inline static var TEMP_DIRECTORY:String = ".temp";

	private var haxelib:Haxelib;

	public function new(command:ValidateCommand)
	{
		super(command);

		haxelib = new Haxelib();
	}

	override function execute():Void
	{
		for(dependency in config.dependencies)
			validateDependency(dependency);

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

		if(haxelib.dependencyVersionExists(dependency.name, dependency.version))
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
		for(dependency in config.dependencies)
		{
			var item = new DependencyTreeItem(dependency.name, dependency.version);
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
		if(FileSystem.exists(TEMP_DIRECTORY))
			haxelib.deleteDirectory(TEMP_DIRECTORY);
		FileSystem.createDirectory(TEMP_DIRECTORY);

		try
		{
			Git.checkout(dependency.source, dependency.version, TEMP_DIRECTORY);
		}
		catch(error:Dynamic)
		{
			haxelib.deleteDirectory(TEMP_DIRECTORY);
			throw error;
		}

		haxelib.deleteDirectory(TEMP_DIRECTORY + "/.git");
		var depenencyDirectory:String = haxelib.getDependencyDirectory(dependency.name);
		haxelib.makeDirectory(depenencyDirectory);

		var target:String = haxelib.getDependencyVersionDirectory(dependency.name, dependency.version, false, null);
		if(dependency.classPath != null)
		{
			FileSystem.rename(TEMP_DIRECTORY + "/" + dependency.classPath, target);
			haxelib.deleteDirectory(TEMP_DIRECTORY);
		}
		else
		{
			FileSystem.rename(TEMP_DIRECTORY, target);
		}

		var currentFile:String = depenencyDirectory + "/" + Haxelib.FILE_CURRENT;
		if(!FileSystem.exists(currentFile))
			File.saveContent(currentFile, dependency.version);
	}

	function installDependencyHaxelib(dependency:DependencyDetail):Void
	{
		System.command("haxelib", ["install", dependency.name, dependency.version]);
	}

	function getDependencyTree(dependency:Dependency):Array<DependencyTreeItem>
	{
		var directory:String = haxelib.getDependencyVersionDirectory(dependency.name, dependency.version,
			dependency.metadata.isDev, dependency.metadata.versionCurrent.key);

		if(directory == null)
			return null;

		var haxelibFile:String = directory + "/" + Haxelib.FILE_HAXELIB;
		if(!FileSystem.exists(haxelibFile))
			return null;

		var list = Data.readData(File.getContent(haxelibFile), false);
		var result:Array<DependencyTreeItem> = [];
		for(info in list.dependencies)
		{
			var item = new DependencyTreeItem(info.project, info.version);
			updateMetadata(item);
			item.dependencies = item.metadata.exists ? getDependencyTree(item) : null;
			result.push(item);
		}
		return result;
	}

	function updateMetadata(dependency:Dependency):Void
	{
		var detail = DependencyDetail.getFromList(config.dependencies, dependency.name);
		var metadata = dependency.metadata;
		metadata.exists = haxelib.dependencyExists(dependency.name);
		metadata.isDev = metadata.exists && haxelib.getDependencyIsDev(dependency.name);

		metadata.versionExists = dependency.version == null
			? false
			: metadata.exists && haxelib.dependencyVersionExists(dependency.name, dependency.version);

		metadata.versionForced = (detail != null && detail.forceVersion)
			? new Version(detail.version, metadata.exists && haxelib.dependencyVersionExists(dependency.name, detail.version))
			: null;

		metadata.versionResolved = metadata.versionForced != null
			? metadata.versionForced.clone()
			: new Version(dependency.version, metadata.versionExists);

		var currentVersion:String = haxelib.getDependencyCurrentVersion(dependency.name);
		metadata.versionCurrent = metadata.exists
			? new Version(currentVersion, metadata.exists && haxelib.dependencyVersionExists(dependency.name, currentVersion))
			: null;
	}
}