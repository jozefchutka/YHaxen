package yhaxen.valueObject.dependency;

import yhaxen.enums.DependencyVersionType;
import yhaxen.util.ArrayUtil;

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
		return versionType == DependencyVersionType.DEV
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

	public static function listContainsByNameAndVersion(list:Array<DependencyTreeItem>, item:DependencyTreeItem):Bool
	{
		if(item == null)
			return Lambda.has(list, item);

		for(i in list)
			if(i != null && i.name == item.name && i.version == item.version)
				return true;
		return false;
	}

	public static function sort(x:DependencyTreeItem, y:DependencyTreeItem):Int
	{
		return ArrayUtil.sortNames(x.name, y.name);
	}
}