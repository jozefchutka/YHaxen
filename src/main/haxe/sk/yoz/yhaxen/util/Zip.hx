package sk.yoz.yhaxen.util;

import haxe.crypto.Crc32;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.zip.Entry;
import haxe.zip.Writer;

import sys.io.File;
import sys.FileSystem;

import sk.yoz.yhaxen.valueObject.Error;

class Zip
{
	var entries:List<Entry>;

	public function new()
	{
		entries = new List();
	}

	public function add(path:String, target:String):Void
	{
		if(!FileSystem.exists(path))
			throw new Error(
				"Invalid path " + path + "!",
				"Path " + path + " does not exist in file system.",
				"Provide proper path.");

		if(FileSystem.isDirectory(path))
		{
			for(item in FileSystem.readDirectory(path))
				add(path + "/" + item, target + "/" + item);
		}
		else
		{
			addFile(path, target);
		}
	}

	private function addFile(path:String, target:String):Void
	{
		var bytes = File.getBytes(path);
		var entry:Entry =
		{
			fileName: target,
			fileSize: bytes.length,
			fileTime: Date.now(),
			compressed: false,
			dataSize: 0,
			data: bytes,
			crc32: Crc32.make(bytes),
			extraFields: new List()
		}
		entries.add(entry);
	}

	public function save(path:String):Void
	{
		var bytesOutput = new BytesOutput();
		var writer = new Writer(bytesOutput);
		writer.write(entries);
		var zipfileBytes = bytesOutput.getBytes();
		var file = File.write(path, true);
		file.write(zipfileBytes);
		file.close();
	}
}