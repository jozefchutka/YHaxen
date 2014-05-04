package sk.yoz.yhaxen;

import sk.yoz.yhaxen.resolvers.DependencyResolver;
import haxe.Json;
import sk.yoz.yhaxen.parsers.YHaxenParser;
import sys.io.File;

class Main
{
	public static function main()
	{
		new Main();
	}

	private function new()
	{
		var file:String = Sys.args()[0];
		var data = File.getContent(file);
		var json = Json.parse(data);
		var yhaxen = new YHaxenParser().parse(json);
		
		for(dependency in yhaxen.dependencies)
		{
			new DependencyResolver().resolve(dependency);
		}
	}
}