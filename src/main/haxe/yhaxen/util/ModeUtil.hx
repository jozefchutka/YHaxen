package yhaxen.util;

class ModeUtil
{
	public static function matches(modes:Array<String>, mode:String):Bool
	{
		return (mode == null || modes == null) ? true : Lambda.has(modes, mode);
	}
}