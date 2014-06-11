# YHaxen

YHaxen is a Haxe project management tool written in [Haxe](http://haxe.org/). YHaxen can manage a project's validation, build, deployment and releasement.

## Dependencies

Works with:

| OS         | Haxe  | Neko  | Haxelib    |
| ---------- | ----- | ----- | ---------- |
| Win 8.1    | 3.0.1 | 2.0.0 | 3.1.0-rc.4 |
| OSX        | 3.0.1 | 2.0.0 | 3.1.0-rc.4 |
| Ubuntu 14  | 3.0.1 | 2.0.0 | 3.1.0-rc.4 |
 
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
yhaxen compile:compile
yhaxen compile -config src/test/resources/yhaxen.json
yhaxen test
yhaxen test:test
yhaxen release -version 0.0.1
yhaxen release -version 0.0.1 -message "Initial release."
```

## Config

Default config filename is **yhaxen.json**. Each phase has a related section in config file. If a phase related section is not defined in config file, phase would be skipped.   

```json
{
	"variables": {...},
	"dependencies": [...],
	"builds": [...],
	"releases": [...],
}
```

## Phases

1. validate
2. test
3. compile
4. deploy
5. release

When a specific phase is requested, each preceding phase is invoked as well (e.g. `yhaxen deploy` would run validate, compile and test phase before the actual deployment).

### Validate

Resolve and install dependencies from GIT or Haxelib (type **haxelib** or **git**).
 
**name** (String, required) - Dependency name to be used for haxelib.

**version** (String, required) - Dependency version to be used for haxelib. In case of git dependency, can point to branch, tag or commit.

**type** (String, required) - Only *git* or *haxelib* values are available. 

**source** (String, required for git) - Points to git repository.
 
**classPath** (String, optional) - Class path to sources. Only available with git.

**scopes** (Array<String>, optional) - Scope filtering is used with build or test phase. If dependency scope is not defined, the dependency will be avialable for all builds and tests. If scopes are defined, dependency will be used only for appropriate build or test name.

**forceVersion** (Bool, optional) - If multiple versions of a lib is used, phase fails with error describing the conflicting dependencies. Enable this flag to resolve conflicts.

**update** (Bool, optional) - Removes old version if exists and replaces with new one. Consider using this flag when dependency version is pointing to a branch. 

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

Todo: example json, describe git tags, submit to haxelib

### Deploy

Not yet implemented.

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
```

All scope related dependencies **dir** via **-cp** argument:
```
${dependency:*:dir} -> c:/haxe/lib/munit/123 c:/haxe/lib/mcover/123 ...
${dependency:*:dir:-cp} -> -cp c:/haxe/lib/munit/123 -cp c:/haxe/lib/mcover/123 ...
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
- with release provide dependencies in haxelib.json
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