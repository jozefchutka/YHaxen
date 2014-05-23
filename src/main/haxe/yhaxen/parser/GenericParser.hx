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

	public static function parseEnum<E>(e:Enum<E>, source:String):E
	{
		if(source == null)
			return null;

		return Type.createEnum(e, source.toUpperCase());
	}
}