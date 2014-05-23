package yhaxen.valueObject.config;

import yhaxen.enums.SourceType;
import yhaxen.valueObject.dependency.Dependency;

class DependencyDetail extends Dependency
{
	/**
	 * Required for GIT sourceType
	 **/
	public var source:String;

	/**
	 * Required
	 **/
	public var type:SourceType;

	/**
	 * Optional
	 **/
	public var classPath:String;

	/**
	 * Optional
	 **/
	public var scopes:Array<String>;

	/**
	 * Optional
	 **/
	public var forceVersion:Bool = false;

	public function new(name:String, version:String, type:SourceType, source:String)
	{
		super(name, version);
		this.type = type;
		this.source = source;
	}

	public function matchesScope(scope:String):Bool
	{
		return (scope == null || scopes == null) ? true : Lambda.has(scopes, scope);
	}

	public static function getFromList(list:Array<DependencyDetail>, name:String):DependencyDetail
	{
		if(list != null)
			for(item in list)
				if(item.name == name)
					return item;
		return null;
	}
}