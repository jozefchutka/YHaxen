package yhaxen.phase;

import yhaxen.enums.DependencyVersionType;
import yhaxen.enums.SourceType;
import yhaxen.parser.ConfigParser;
import yhaxen.util.ArrayUtil;
import yhaxen.util.Git;
import yhaxen.util.Haxelib;
import yhaxen.util.System;
import yhaxen.valueObject.command.ValidateCommand;
import yhaxen.valueObject.config.Config;
import yhaxen.valueObject.config.DependencyDetail;
import yhaxen.valueObject.dependency.Dependency;
import yhaxen.valueObject.dependency.DependencyTreeItem;
import yhaxen.valueObject.dependency.FlattenDependencies;
import yhaxen.valueObject.Error;

import tools.haxelib.Data;

import sys.io.File;
import sys.FileSystem;

class ValidatePhase extends AbstractPhase
{
	inline static var WORD_OK:String = "OK";
	inline static var WORD_MISSING:String = "MISSING";
	inline static var WORD_WARNING:String = "WARNING";
	inline static var WORD_INVALID:String = "INVALID";
	inline static var WORD_UNDEFINED:String = "UNDEFINED";

	public function new(config:Config, configFile:String, scope:String, verbose:Bool)
	{
		super(config, configFile, scope, verbose);
	}

	public static function fromCommand(command:ValidateCommand):ValidatePhase
	{
		var config = ConfigParser.fromFile(command.configFile, command.scope);
		return new ValidatePhase(config, command.configFile, command.scope, command.verbose);
	}

	override function execute():Void
	{
		super.execute();

		if(config.dependencies == null || config.dependencies.length == 0)
			return logPhase("validate", scope, "No dependencies found.");

		logPhase("validate", scope, "Found " + config.dependencies.length + " dependencies.");
		validateConfig();

		for(dependency in config.dependencies)
			resolveDependency(dependency);

		var list:Array<Dependency> = [];
		var tree = getTree();
		var flatten = flattenTree(tree);

		log("");
		log("Tree:");
		validateTree(tree);

		log("");
		log("Flatten:");
		validateFlatten(flatten);
	}

	function resolveDependency(dependency:DependencyDetail)
	{
		var exists:Bool = false;
		try
		{
			exists = haxelib.dependencyVersionExists(dependency.name, dependency.version);
		}
		catch(error:Dynamic)
		{
			throw new Error(
				"Invalid dependency " + dependency.name + ".",
				"Dependency directory " + dependency.version + " could not be resolved.",
				"Provide valid dependency version that can be resolved into a directory.");
		}

		if(exists)
		{
			logKeyVal("Resolving " + dependency.toString(), 40, WORD_OK);
			return;
		}

		log("Resolving " + dependency.toString());
		switch(dependency.type)
		{
			case SourceType.GIT:
				installDependencyGit(dependency);
			case SourceType.HAXELIB:
				installDependencyHaxelib(dependency);
		}
		log("");
	}

	function validateConfig():Void
	{
		var names:Array<String> = [];
		for(dependency in config.dependencies)
		{
			if(Lambda.has(names, dependency.name))
				throw new Error(
					"Misconfigured dependency " + dependency.name + "!",
					"Dependency " + dependency.name + " is defined multiple times.",
					"Provide only one definition for " + dependency.name + " in " + configFile + ".");

			names.push(dependency.name);
		}
	}

	function validateTree(list:Array<DependencyTreeItem>, level:Int=0):Void
	{
		for(item in list)
		{
			var result:String = WORD_INVALID;
			if(item.versionResolved != null)
				result = (item.versionResolvedExists ? WORD_OK : WORD_MISSING) + " (" + item.versionResolved + ")";

			var pad:String = StringTools.lpad("", " ", level * 2 + 2);
			logKeyVal(pad + item.toString(), 40, result);

			var detail = DependencyDetail.getFromList(config.dependencies, item.name);
			if(detail == null)
				throw new Error(
					"Undefined dependency " + item.name + "!",
					"Dependency " + item.name + " is not defined in " + configFile
						+ (scope != null ? " for scope " + scope : "") + ".",
					"Provide dependency details in " + configFile + ".");

			if(item.versionResolved == null)
				throw new Error(
					"Invalid dependency " + item.name + "!",
					"Dependency " + item.name + " is defined without version information.",
					"Provide forceVersion in " + configFile + " for this dependency.");

			if(!item.versionResolvedExists)
				throw new Error(
					"Missing dependency " + item.name + "!",
					"Dependency " + item.name + " with resolved version " + item.versionResolved + " is missing.",
					"Check dependency details in " + configFile + ".");

			if(item.dependencies != null)
				validateTree(item.dependencies, level + 1);
		}
	}

	function validateFlatten(data:FlattenDependencies):Void
	{
		var names:Array<String> = [];
		for(name in data.keys())
			names.push(name);
		names.sort(ArrayUtil.sortNames);

		for(name in names)
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

			logKeyVal("  " + name, 40, WORD_WARNING);
			for(version in dataName.keys())
			{
				if(version == WORD_UNDEFINED)
					continue;
				var sources = dataName.get(version);
				for(source in sources)
					logKeyVal("    in " + (source == null ? configFile : source.toString()), 40, " ! (" + version + ")");
			}

			var detail = DependencyDetail.getFromList(config.dependencies, name);
			if(detail == null || !detail.forceVersion)
				throw new Error(
					"Invalid dependency version for " + name + "!",
					"Dependency " + name + " has multiple versions used.",
					"Provide forceVersion in " + configFile + ".");
		}
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
		result.sort(DependencyTreeItem.sort);
		return result;
	}

	function flattenTree(list:Array<DependencyTreeItem>, parent:DependencyTreeItem=null,
		target:FlattenDependencies=null):FlattenDependencies
	{
		if(list == null || list.length == 0)
			return null;

		if(target == null)
			target = new FlattenDependencies();

		for(dependency in list)
		{
			if(!target.exists(dependency.name))
				target.set(dependency.name, new Map<String,Array<DependencyTreeItem>>());
			var targetName = target.get(dependency.name);
			var version = dependency.version == null ? WORD_UNDEFINED : dependency.version;
			if(!targetName.exists(version))
				targetName.set(version, []);
			var targetNameVersion = targetName.get(version);
			if(!DependencyTreeItem.listContainsByNameAndVersion(targetNameVersion, parent))
				targetNameVersion.push(parent);
			flattenTree(dependency.dependencies, dependency, target);
		}

		return target;
	}

	function installDependencyGit(dependency:DependencyDetail):Void
	{
		createTempDirectory();

		try
		{
			Git.checkout(dependency.source, dependency.version, AbstractPhase.TEMP_DIRECTORY);
		}
		catch(error:Dynamic)
		{
			deleteTempDirectory();
			throw error;
		}

		haxelib.deleteDirectory(AbstractPhase.TEMP_DIRECTORY + "/.git");
		var depenencyDirectory:String = haxelib.getDependencyDirectory(dependency.name);
		haxelib.makeDirectory(depenencyDirectory);

		var target:String = haxelib.getDependencyVersionDirectory(dependency.name, dependency.version, false);
		if(dependency.classPath != null)
		{
			FileSystem.rename(AbstractPhase.TEMP_DIRECTORY + "/" + dependency.classPath, target);
			deleteTempDirectory();
		}
		else
		{
			FileSystem.rename(AbstractPhase.TEMP_DIRECTORY, target);
		}

		var currentFile:String = depenencyDirectory + "/" + Haxelib.FILE_CURRENT;
		if(!FileSystem.exists(currentFile))
			File.saveContent(currentFile, dependency.version);
	}

	function installDependencyHaxelib(dependency:DependencyDetail):Void
	{
		if(System.command("haxelib", ["install", dependency.name, dependency.version]) != 0)
			throw new Error(
				"Invalid haxelib dependency " + dependency.name + " version " + dependency.version + "!",
				"Haxelib could not install " + dependency.name + " with version " + dependency.version + ".",
				"Make sure dependency name and version is correctly defined in " + configFile + ".");
	}

	function getDependencyTree(dependency:Dependency):Array<DependencyTreeItem>
	{
		var directory:String = haxelib.getDependencyVersionDirectory(dependency.name, dependency.versionResolved,
			dependency.versionType == DependencyVersionType.DEV);

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
			item.dependencies = item.exists ? getDependencyTree(item) : null;
			result.push(item);
		}
		result.sort(DependencyTreeItem.sort);
		return result;
	}

	function updateMetadata(dependency:Dependency):Void
	{
		var detail = DependencyDetail.getFromList(config.dependencies, dependency.name);
		dependency.exists = haxelib.dependencyExists(dependency.name);

		if(dependency.exists && haxelib.getDependencyIsDev(dependency.name))
			dependency.versionType = DependencyVersionType.DEV;
		else if(dependency.version == null)
			dependency.versionType = DependencyVersionType.ANY;
		else
			dependency.versionType = DependencyVersionType.REGULAR;

		dependency.versionResolved = (detail != null && detail.forceVersion) ? detail.version : dependency.version;

		dependency.versionResolvedExists = dependency.versionResolved != null
			&& dependency.exists
			&& haxelib.dependencyVersionExists(dependency.name, dependency.versionResolved);
	}
}