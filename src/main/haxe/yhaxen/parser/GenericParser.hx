package yhaxen.parser;

class GenericParser<T> 
{
	public function new()
	{
	}

	public function parse(source:Dynamic):T
	{
		throw "Not implemented!";
		return null;
	}

	public function parseList(source:Array<Dynamic>):Array<T>
	{
		if(source == null)
			return null;

		var result:Array<T> = [];
		for(item in source)
			result.push(parse(item));
		return result;
	}

	function checkUnexpectedFields(source:Dynamic, result:Class<T>):Void
	{
		var resultFields = Type.getInstanceFields(result);
		for(field in Reflect.fields(source))
			if(!Lambda.has(resultFields, field))
				throw getSimpleClassName(result) + " contains unexpected field " + field + ".";
	}

	public static function getSimpleClassName(clazz:Class<Dynamic>):String
	{
		var result = Type.getClassName(clazz);
		var chunks = result.split(".");
		return chunks[chunks.length - 1];
	}

	public static function parseEnum<E>(e:Enum<E>, source:String):E
	{
		if(source == null)
			return null;

		return Type.createEnum(e, source.toUpperCase());
	}
}