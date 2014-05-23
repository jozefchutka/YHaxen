# YHaxen

YHaxen is a Haxe project management tool written in [Haxe](http://haxe.org/). YHaxen can manage a project's validation, build, deployment and releasement.

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
haxelib run yhaxen compile
```

Optionally can be built from sources using haxe:
```
haxe -main yhaxen.Main -neko src/main/haxe/run.n -cp src/main/haxe
```

## Usage
```
yhaxen validate
yhaxen validate -config src/test/resources/yhaxen.json
yhaxen validate -scope web
yhaxen compile
yhaxen compile -config src/test/resources/yhaxen.json
yhaxen compile -scope web
yhaxen release -version 0.0.1
yhaxen release -version 0.0.1 -message "Initial release."
yhaxen release -version 0.0.1 -scope web
```

## Config

Default config filename is **yhaxen.json**. Each phase has a related section in config file. If a phase related section is not defined in config file, phase would be skipped.   

```json
{
	"version": 1,
	"dependencies": [...],
	"builds": [...],
	"releases": [...],
}
```

## Phases

1. validate
2. compile
3. test
4. deploy
5. release

When a specific phase is requested, each preceding phase is invoked as well (e.g. `yhaxen deploy` would run validate, compile and test phase before the actual deployment).

### Validate

Resolve and install dependencies from GIT or Haxelib (type **haxelib** or **git**). Config dependencies relates to validate phase.
 
```json
"dependencies":
	[
		{
			"name": "msignal",
			"version": "1.2.2",
			"sourceType": "haxelib",
			"forceVersion": true
		},
		...
	]
```

If multiple versions of a lib is used phase fails with error describing the conflicting dependencies. Conflicting dependencies can be resolved using `forceVersion` in config. 

### Compile

Executes compilation command.

Todo: example json, how dependencies variable is used

### Test

Not yet implemented.

### Deploy

Not yet implemented.

### Release

Todo: example json, describe git tags, submit to haxelib

## TODO
- use verbose
- validate all dependencies even when used scope, provide cp paths filtered by scope
- snapshot dependencies - via "reinstall"
- provide dependencies in haxelib.json
- provide commit message with release when available (via -message)
- unit tests
- deploy target
- test osx, linux
- running yhaxen without privileges to haxelib/lib folder

### should
- install specific version from git
- install into haxelib folder under proper version
- install subdependencies automatically
- provide list of necessary sub dependencies with versions
- dependencies in yhaxen.json
- yhaxen.json only at app/prject level not in dependencies (use haxelib.json)

### should not
- not use .current .dev
- change lib/compiler state at all
- do not install subdependencies but have them all defined in yhaxen.json

### known issues
- on windows if neko/yhaxen is executed without admin rights and haxelib is setuped in "Prgorem Files" etd, FileSystem.hx create/write proxies directories into something like
```
c:\Users\<USER>\AppData\Local\VirtualStore\Program Files (x86)\HaxeToolkit\haxe-3.0.1\lib\
```

- if a haxelib lib contains .dev file, haxe compiler is not able to use specific lib version with -lib $lib:$version
- if a lib A contains dependency B defined in haxelib.json with version C a haxe compiler cannot override it using `haxe -lib A -lib B:D`