package sk.yoz.yhaxen.valueObjects;

class DependencyTreeItem extends Dependency
{
	public var dependencies:Array<DependencyTreeItem>;

	public function new(name:String, version:String)
	{
		super(name, version);

		dependencies = [];
	}

	public static function joinList(list:Array<DependencyTreeItem>, separator:String, nullReplacer:String):String
	{
		if(list == null || list.length == 0)
			return "";

		var result:String = "";
		for(i in 0...list.length)
		{
			var item = list[i];
			result += item == null ? nullReplacer : item.toString();
			if(i < list.length - 1)
				result += separator;
		}
		return result;
	}
}