# YHaxen

## build
```
haxe -main sk.yoz.yhaxen.Main -neko bin/release/main.n -cp src/main/haxe
```

## TODO

### should
- install specific version from git
- install into haxelib folder under proper version
- install subdependencies automatically
- dependencies in yhaxen.json
- provide list of necessary sub dependencies with versions
- yhaxen.json on project level, haxelib.json on dependency level (libraries)

### should not
- not use .current .dev
- change lib/compiler state at all

