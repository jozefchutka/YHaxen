package sk.yoz.yhaxen.phase;

import sk.yoz.yhaxen.util.System;
import sk.yoz.yhaxen.valueObject.config.Config;

class AbstractPhase
{
	public var config(default, null):Config;
	public var configFile(default, null):String;
	public var verbose(default, null):Bool;

	private function new(config:Config, configFile:String, verbose:Bool)
	{
		this.config = config;
		this.configFile = configFile;
		this.verbose = verbose;
	}

	public function execute():Void
	{
		throw "Not implemented!";
	}

	function logPhase(name:String):Void
	{
		System.printRow("-");
		log("PHASE:" + name);
		System.printRow("-");
	}

	function log(message:String):Void
	{
		System.print(message);
	}

	function logKeyVal(key:String, pad:Int, value:String):Void
	{
		System.printKeyVal(key, pad, value);
	}
}