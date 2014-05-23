# YHaxen

## build
```
haxe -main sk.yoz.yhaxen.Main -neko run.n -cp src/main/haxe
```

```
haxelib run yhaxen compile
```

## test
```
neko run.n compile -config src/test/resources/yhaxen.json
```

## TODO
- use verbose
- validate all dependencies even when used scope, provide cp paths filtered by scope
- snapshot dependencies - via "reinstall"
- unit tests
- deploy target
- test osx, linux
- running yhaxen without privileges to haxelib/lib folder

### Phases
- validate
	- resolve dependencies
	- install dependencies
- compile
- test
- deploy
- release
	- make git tags
	- upload to haxelib

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