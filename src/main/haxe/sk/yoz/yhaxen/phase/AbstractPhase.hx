package sk.yoz.yhaxen.phase;

import sk.yoz.yhaxen.util.Haxelib;
import sk.yoz.yhaxen.util.System;
import sk.yoz.yhaxen.valueObject.config.Config;

import sys.FileSystem;

class AbstractPhase
{
	inline static var TEMP_DIRECTORY:String = ".yhaxen";

	public var config(default, null):Config;
	public var configFile(default, null):String;
	public var scope(default, null):String;
	public var verbose(default, null):Bool;
	@:isVar public var haxelib(get, set):Haxelib;

	private function new(config:Config, configFile:String, scope:String, verbose:Bool)
	{
		this.config = config;
		this.configFile = configFile;
		this.scope = scope;
		this.verbose = verbose;
	}

	private function get_haxelib():Haxelib
	{
		if(haxelib == null)
			haxelib = new Haxelib();
		return haxelib;
	}

	private function set_haxelib(value:Haxelib):Haxelib
	{
		return haxelib = value;
	}

	public function execute():Void
	{
		throw "Not implemented!";
	}

	function logPhase(name:String, scope:String, details:String):Void
	{
		log("");
		System.printRow("-");
		log("PHASE: " + name + (scope != null ? " " + scope : ""));
		log(details);
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

	function createTempDirectory():Void
	{
		deleteTempDirectory();
		FileSystem.createDirectory(TEMP_DIRECTORY);
	}

	function deleteTempDirectory():Void
	{
		if(FileSystem.exists(TEMP_DIRECTORY))
			haxelib.deleteDirectory(TEMP_DIRECTORY);
	}
}