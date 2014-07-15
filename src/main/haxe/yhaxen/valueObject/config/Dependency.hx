package yhaxen.valueObject.config;

import yhaxen.enums.SourceType;
import yhaxen.util.ScopeUtil;

class Dependency extends yhaxen.valueObject.dependency.Dependency
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
	public var subdirectory:String;

	/**
	 * Optional
	 **/
	public var scopes:Array<String>;

	/**
	 * Optional
	 **/
	public var forceVersion:Bool = false;

	/**
	 * Optional
	 **/
	public var update:Bool = false;

	/**
	 * Optional
	 **/
	public var followDev:Bool = false;

	public function new(name:String, version:String, type:SourceType, source:String)
	{
		super(name, version);
		this.type = type;
		this.source = source;
	}

	public function matchesScope(scope:String):Bool
	{
		return ScopeUtil.matches(scopes, scope);
	}

	public static function getFromList(list:Array<Dependency>, name:String):Dependency
	{
		if(list != null)
			for(item in list)
				if(item.name == name)
					return item;
		return null;
	}
}