# YHaxen

YHaxen is a Haxe project management tool written in [Haxe](http://haxe.org/). YHaxen can manage a project's validation, build, and release.

## Dependencies

Works with:

| OS         | Haxe           | Neko  | Haxelib    |
| ---------- | -------------- | ----- | ---------- |
| Win 8.1    | 3.0.1 -> 3.1.3 | 2.0.0 | 3.1.0-rc.4 |
| OSX        | 3.0.1 -> 3.1.3 | 2.0.0 | 3.1.0-rc.4 |
| Ubuntu 14  | 3.0.1 -> 3.1.3 | 2.0.0 | 3.1.0-rc.4 |
 
## Install

Recommended installation from from haxelib:
```
haxelib install yhaxen
```

Optionally can be also installed from git:
```
haxelib git yhaxen git@github.com:jozefchutka/YHaxen.git 0.0.20 src/main/haxe
```

## Build

Recommended build from sources using yhaxen:
```
haxelib run yhaxen compile -version 123
```

Optionally can be built from sources using haxe:
```
haxe -main yhaxen.Main -neko src/main/haxe/run.n -cp src/main/haxe -D version=123
```

## Usage
```
yhaxen validate
yhaxen validate -config src/test/resources/yhaxen.json
yhaxen compile
yhaxen compile:*
yhaxen compile:buildName
yhaxen compile -config src/test/resources/yhaxen.json
yhaxen test
yhaxen test:*
yhaxen test:testName
yhaxen release -version 0.0.1
yhaxen release -version 0.0.1 -message "Initial release."
yhaxen release -version 0.0.1 -message "Releasing version ${arg:-version}."
```

## Config

Default config filename is **yhaxen.json**. Each phase has a related section in config file. If a phase related section is not defined in config file, phase would be skipped.   

```json
{
	"variables": {...},
	"dependencies": [...],
	"tests": [...],
	"builds": [...],
	"releases": [...],
}
```

## Phases

1. validate
2. test
3. compile
4. release

When a specific phase is requested, each preceding phase is invoked as well (e.g. `yhaxen release` would run validate, test and compile phase before the actual release).

### Validate

Resolve and install dependencies from GIT or Haxelib (type **haxelib** or **git**).
 
**name** (String, required) - Dependency name to be used for haxelib.

**version** (String, required) - Dependency version to be used for haxelib. In case of git dependency, can point to branch, tag or commit.

**type** (String, required) - Only *git* or *haxelib* values are available. 

**source** (String, required for git) - Points to git repository.
 
**subdirectory** (String, optional) - Git subdirectory to sources or haxelib.json. Only available with git.

**scopes** (Array<String>, optional) - Scope filtering is used with build or test phase. If dependency scope is not defined, the dependency will be avialable for all builds and tests. If scopes are defined, dependency will be used only for appropriate build or test name.

**forceVersion** (Bool, optional) - If multiple versions of a lib is used, phase fails with error describing the conflicting dependencies. Enable this flag to resolve conflicts.

**update** (Bool, optional) - Removes old version if exists and replaces with new one. Consider using this flag when dependency version is pointing to a branch. 

**useCurrent** (Bool, optional) - If true, the dependency dir will be resolved from .current file for variables (e.g. `${dependency:munit:dir}` or `${dependency:munit:classPath}`).

**makeCurrent** (Bool, optional) - If true, the requested dependency version will be set as current with validation phase (using haxelib command `haxelib set munit 2.1.1`).

Example dependency configuration:
 
```json
"dependencies": [
	{
		"name": "msignal",
		"version": "1.2.2",
		"type": "haxelib"
	},
	{
		"name":"munit",
		"version":"2.1.1",
		"source": "git@github.com:massiveinteractive/MassiveUnit.git",
		"type": "git",
		"classPath": "src",
		"scopes": ["test"]
	},
	{...}
]
```

### Test

Test the compiled source code using a unit testing framework.

### Compile

Compile the source code of the project.

Todo: example json, how dependencies variable is used

### Release

Release versioned project.

Only haxelib depenedencies will appear in updated haxelib.json.

Todo: example json, describe git tags, submit to haxelib

## Variables

Available in build, test and release phases.

Variable configuration and usage in yhaxen.json: 
```json
{
	"variables": [
		{
			"name": "sourceDirectory",
			"value": "src/main/haxe"
		}
	],
	"builds": [
		{
			"name": "main",
			"command": "haxe",
			"arguments": ["-cp", "${variable:sourceDirectory}"]
		}
	]
}
```

### Dependencies

Single dependendcy **dir**: 
```
${dependency:munit:dir} -> c:/haxe/lib/munit/123
${dependency:munit:dir:-cp} -> -cp c:/haxe/lib/munit/123
${dependency:munit:classPath:-cp} -> -cp c:/haxe/lib/munit/123/src
```

All scope related dependencies **dir** via **-cp** argument:
```
${dependency:*:dir} -> c:/haxe/lib/munit/123 c:/haxe/lib/mcover/123 ...
${dependency:*:dir:-cp} -> -cp c:/haxe/lib/munit/123 -cp c:/haxe/lib/mcover/123 ...
${dependency:*:classPath:-cp} -> -cp c:/haxe/lib/munit/123/src -cp c:/haxe/lib/mcover/123/src ...
```

Other examples:
```
${dependency:munit:name:-lib} -> -lib munit
${dependency:munit:nameVersion:-lib} -> -lib munit:123
${dependency:*:name} -> munit mcover ...
${dependency:*:nameVersion:-lib} -> -lib munit:123 -lib mcover:123 ...
```

### Arguments

Command line arguments:

```
haxelib run yhaxen compile version 123 
${arg:version} -> 123
```

## TODO
- deploy target
- running yhaxen without privileges to haxelib/lib folder

### should
- install specific version from git
- install into haxelib folder under proper version
- install subdependencies automatically
- provide list of necessary sub dependencies with versions
- dependencies in yhaxen.json
- yhaxen.json only at app/prject level not in dependencies (use haxelib.json)
- only place for defining dependencies (no .munit, munit.hxml, main.hxml)

### should not
- not use .current .dev
- change lib/compiler state at all
- do not install subdependencies but have them all defined in yhaxen.json
- no channel.json

### known issues
- on windows if neko/yhaxen is executed without admin rights and haxelib is setuped in "Prgorem Files" etd, FileSystem.hx create/write proxies directories into something like
```
c:\Users\<USER>\AppData\Local\VirtualStore\Program Files (x86)\HaxeToolkit\haxe-3.0.1\lib\
```

- if a haxelib lib contains .dev file, haxe compiler is not able to use specific lib version with -lib $lib:$version
- if a lib A contains dependency B defined in haxelib.json with version C a haxe compiler cannot override it using `haxe -lib A -lib B:D`