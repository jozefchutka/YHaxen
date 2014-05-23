package yhaxen.util;

class ArrayUtil
{
	public static function sortNames(x:String, y:String):Int
	{
		if(x == y)
			return 0;
		return x > y ? 1 : -1;
	}
}