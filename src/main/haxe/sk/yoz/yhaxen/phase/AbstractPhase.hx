package sk.yoz.yhaxen.phase;

import haxe.Json;

import sk.yoz.yhaxen.helper.System;
import sk.yoz.yhaxen.parser.ConfigParser;
import sk.yoz.yhaxen.valueObject.command.AbstractLifecycleCommand;
import sk.yoz.yhaxen.valueObject.config.Config;

import sys.io.File;
import sys.FileSystem;

class AbstractPhase<TCommand>
{
	public var command(default, set):TCommand;
	public var config(default, null):Config;
	public var verbose(get, never):Bool;
	public var configFile(get, never):String;

	private function new(command:TCommand)
	{
		this.command = command;
	}

	private function set_command(value:TCommand):TCommand
	{
		if(value != command)
		{
			command = value;
			updateConfig();
		}
		return value;
	}

	private function get_verbose():Bool
	{
		var command:AbstractLifecycleCommand = cast this.command;
		return command.verbose;
	}

	private function get_configFile():String
	{
		var command:AbstractLifecycleCommand = cast this.command;
		return command.configFile;
	}

	public function execute():Void
	{
		throw "Not implemented!";
	}

	function updateConfig():Void
	{
		checkFile(configFile);
		var data = File.getContent(configFile);
		var json:Dynamic;
		try
		{
			json = Json.parse(data);
		}
		catch(error:String)
		{
			throw "Unable to parse " + configFile + ". " + error;
		}

		config = new ConfigParser().parse(json);
	}

	function log(message:String):Void
	{
		System.print(message);
	}

	function logKeyVal(key:String, pad:Int, value:String):Void
	{
		System.printKeyVal(key, pad, value);
	}

	function checkFile(file:String):Void
	{
		if(!FileSystem.exists(file))
			throw "File " + file + " does not exist!";

		if(FileSystem.isDirectory(file))
			throw file + " is not a file!";
	}
}