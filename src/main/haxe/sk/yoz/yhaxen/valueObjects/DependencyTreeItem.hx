package sk.yoz.yhaxen.valueObjects;

class DependencyTreeItem extends Dependency
{
	public var dependencies:Array<DependencyTreeItem>;

	public var hasCurrentDependencies(get, never):Bool;
	public var hasDevDependencies(get, never):Bool;

	public function new(name:String, version:String)
	{
		super(name, version);

		dependencies = [];
	}

	private function get_hasCurrentDependencies():Bool
	{
		return version == null
			? true
			: (dependencies != null && listHasCurrentDependencies(dependencies));
	}

	private function get_hasDevDependencies():Bool
	{
		return isDev
			? true
			: (dependencies != null && listHasDevDependencies(dependencies));
	}

	public static function listHasCurrentDependencies(list:Array<DependencyTreeItem>):Bool
	{
		for(item in list)
			if(item.hasCurrentDependencies)
				return true;
		return false;
	}

	public static function listHasDevDependencies(list:Array<DependencyTreeItem>):Bool
	{
		for(item in list)
			if(item.hasDevDependencies)
				return true;
		return false;
	}
}