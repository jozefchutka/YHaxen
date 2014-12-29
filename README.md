YHaxen is a Haxe project management tool written in [Haxe](http://haxe.org/). YHaxen can manage a project's variables, dependency validation, tests, builds, and releases.

# Dependencies & Requirements

Works with:

| OS         | Haxe           | Neko  | Haxelib    |
| ---------- | -------------- | ----- | ---------- |
| Win 8.1    | 3.0.1 -> 3.1.3 | 2.0.0 | 3.1.0-rc.4 |
| OSX        | 3.0.1 -> 3.1.3 | 2.0.0 | 3.1.0-rc.4 |
| Ubuntu 14  | 3.0.1 -> 3.1.3 | 2.0.0 | 3.1.0-rc.4 |
 
# Install

Recommended installation from from haxelib:
```
haxelib install yhaxen
```

Optionally can be also installed from git:
```
haxelib git yhaxen git@github.com:jozefchutka/YHaxen.git 0.0.20 src/main/haxe
```

# Build

An yhaxen binary can be build from sources using yhaxen:
```
haxelib run yhaxen compile -version 123
```

Optionally can be built from sources using haxe command:
```
haxe -main yhaxen.Main -neko src/main/haxe/run.n -cp src/main/haxe -D version=123
```

# Usage

Default config filename is **yhaxen.json**. A config filename can be customized by `-config $name` arguments.

```json
{
	"variables": [...],
	"dependencies": [...],
	"tests": [...],
	"builds": [...],
	"releases": [...],
}
```

A config file can be executed using `haxelib run yhaxen compile`. See further documentation for more details.

## Variables

Different kind of variables are available:

1. defined in config file (use `${variable:...`)
2. dependency related (use `${dependency:...`)
3. command line arguments (use `${arg:...`)

Variable configuration:

```json
"variables": [
	{
		"name": "sourceDirectory",
		"value": "src/main/haxe"
	}
]
```

Config variable in use:
- `${variable:sourceDirectory}` outputs src/main/haxe

Single dependendcy:
- `${dependency:munit:dir}` c:/haxe/lib/munit/123
- `${dependency:munit:dir:-cp}` -cp c:/haxe/lib/munit/123
- `${dependency:munit:classPath:-cp}` -cp c:/haxe/lib/munit/123/src

Scope related dependencies:
- `${dependency:*:dir}` c:/haxe/lib/munit/123 c:/haxe/lib/mcover/123 ...
- `${dependency:*:dir:-cp}` -cp c:/haxe/lib/munit/123 -cp c:/haxe/lib/mcover/123 ...
- `${dependency:*:classPath:-cp}` -cp c:/haxe/lib/munit/123/src -cp c:/haxe/lib/mcover/123/src ...

Other dependency examples:
- `${dependency:munit:name:-lib}` -lib munit
- `${dependency:munit:nameVersion:-lib}` -lib munit:123
- `${dependency:*:name}` munit mcover ...
- `${dependency:*:nameVersion:-lib}` -lib munit:123 -lib mcover:123 ...

Command line arguments `haxelib run yhaxen compile version 123`:
- `${arg:version}` 123

## Phases

1. [validate](#validate) (variables)
2. [test](#test)
3. [compile](#compile) (build)
4. [release](#release)

Each phase has a related (optional) section in the config file. If a phase related section is not defined in config file, the phase is skipped. When a specific phase is requested, each preceding phase is invoked as well (e.g. `yhaxen release` would run validate, test and compile phase before the actual release).

Examples:
```
yhaxen validate
yhaxen validate -config src/test/resources/yhaxen.json
yhaxen test
yhaxen test:*
yhaxen test:testName
yhaxen compile
yhaxen compile:*
yhaxen compile:buildName
yhaxen compile -config src/test/resources/yhaxen.json
yhaxen release -version 0.0.1
yhaxen release -version 0.0.1 -message "Initial release."
yhaxen release -version 0.0.1 -message "Releasing version ${arg:-version}."
```

### Validate

Resolve and install dependencies from GIT or Haxelib (see type parameter).
 
- **name** (String, required) - Dependency name to be used for haxelib.
- **version** (String, required) - Dependency version to be used for haxelib. In case of git dependency, can point to branch, tag or commit.
- **type** (String, required) - Only *git* or *haxelib* values are available.
- **source** (String, required for git) - Points to git repository.
- **subdirectory** (String, optional) - Git subdirectory to sources or haxelib.json. Only available with git.
- **scopes** (Array<String>, optional) - Scope filtering is used with build or test phase. If dependency scope is not defined, the dependency will be avialable for all builds and tests. If scopes are defined, dependency will be used only for appropriate build or test name.
- **forceVersion** (Bool, optional) - If multiple versions of a lib is used, phase fails with error describing the conflicting dependencies. Enable this flag to resolve conflicts.
- **update** (Bool, optional) - Removes old version if exists and replaces with new one. Consider using this flag when dependency version is pointing to a branch.
- **useCurrent** (Bool, optional) - If true, the dependency dir will be resolved from .current file for variables (e.g. `${dependency:munit:dir}` or `${dependency:munit:classPath}`).
- **makeCurrent** (Bool, optional) - If true, the requested dependency version will be set as current with validation phase (using haxelib command `haxelib set munit 2.1.1`).

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
	}
]
```

### Test

Test the compiled source code using a unit testing framework.

- **name** (String, required) - Name of a test. Is used to resolve scoped dependencies. Must be unique across tests and builds.
- **command** (String, required) - Command to be executed.
- **arguments** (String, optional) - Additional arguments.

Example:
```json
"tests":
[
	{
		"name": "test",
		"command": "haxelib",
		"arguments": ["run", "munit", "test"]
	}
]
```

### Compile

Compile the source code of the project.

- **name** (String, required) - Name of a build. Is used to resolve scoped dependencies. Must be unique across tests and builds.
- **command** (String, required) - Command to be executed.
- **arguments** (String, optional) - Additional arguments.

Example:
```json
"builds":
[
	{
		"name": "main",
		"command": "haxe",
		"arguments":
		[
			"-main", "Main",
			"-js", "${variable:outputDirectory}/main.js",
			"-cp", "${variable:sourceDirectory}",
			"${dependency:*:classPath:-cp}"
		]
	}
]
```

### Release

Release versioned project. With git release, all modified files are commited and a tag is created in remote repository.

- **type** (String, required) - Release type (available options are **haxelib** or **git**).
- **haxelib** (String, optional) - Path to a haxelib.json file that would be updated with dependencies and version information.
- **archiveInstructions** (Array, required for haxelib release) - An array of instructions about paths to be archived and released.

Example:
```json
"releases":
[
	{
		"type": "git",
		"haxelib": "src/haxelib.json"
	},
	{
		"type": "haxelib",
		"haxelib": "src/haxelib.json",
		"archiveInstructions":
		[
			{"source": "src/haxelib.json", "target":"haxelib.json"},
			{"source": "doc", "target": "doc"},
			{"source": "bin/run.n", "target": "run.n"}
		]
	}
]
```

# Roadmap
- improved variables handling to add `-debug` flag etc.
- support importing configurations from dependencies

# Known Issues
- exeption with git release when no files to commit
- running yhaxen without privileges to haxelib/lib folder
- when repository does not contain "subdirectory" specified in dependency config use more proper error than "Error: std@sys_read_dir"
- on windows if neko/yhaxen is executed without admin rights and haxelib is setuped in "Prgorem Files" etd, FileSystem.hx create/write proxies directories into something like `c:\Users\<USER>\AppData\Local\VirtualStore\Program Files (x86)\HaxeToolkit\haxe-3.0.1\lib\`
- if a haxelib lib contains .dev file, haxe compiler is not able to use specific lib version with -lib $lib:$version
- if a lib A contains dependency B defined in haxelib.json with version C a haxe compiler cannot override it using `haxe -lib A -lib B:D`