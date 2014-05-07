# YHaxen

## build
```
haxe -main sk.yoz.yhaxen.Main -neko run.n -cp src/main/haxe
```

## test
```
neko run.n dependency:install src/test/resources/yhaxen.json
```

## TODO
- hide haxelib "You already have msignal version ... Set msignal to version 1.2.2 [y/n/a]"
- test osx, linux

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

