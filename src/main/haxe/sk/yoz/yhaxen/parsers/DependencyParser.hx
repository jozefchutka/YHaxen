package sk.yoz.yhaxen.parsers;

import sk.yoz.yhaxen.enums.SourceType;
import sk.yoz.yhaxen.parsers.GenericParser;
import sk.yoz.yhaxen.valueObjects.config.DependencyDetail;

class DependencyParser extends GenericParser<DependencyDetail>
{
	override function parse(source:Dynamic):DependencyDetail
	{
		if(!Reflect.hasField(source, "name"))
			throw "Missing dependency name!";

		if(!Reflect.hasField(source, "version"))
			throw "Missing dependency version!";

		if(!Reflect.hasField(source, "source"))
			throw "Missing dependency source!";

		var result:DependencyDetail = new DependencyDetail(
			Reflect.field(source, "name"),
			Reflect.field(source, "version"),
			Reflect.field(source, "source"));

		result.scope = Reflect.field(source, "scope");

		result.classPath = Reflect.field(source, "classPath");
		if(result.classPath == "")
			result.classPath = null;

		result.sourceType = Reflect.hasField(source, "sourceType")
			? GenericParser.parseEnum(SourceType, Reflect.field(source, "sourceType"))
			: SourceType.GIT;
		return result;
	}
}