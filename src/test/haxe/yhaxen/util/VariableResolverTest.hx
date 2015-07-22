package yhaxen.util;

import yhaxen.enums.SourceType;
import massive.munit.Assert;

import yhaxen.valueObject.config.Dependency;
import yhaxen.valueObject.config.Variable;

class VariableResolverTest
{
	public function new()
	{

	}

	@BeforeClass
	public function beforeClass():Void
	{
	}

	@AfterClass
	public function afterClass():Void
	{
	}

	@Before
	public function setup():Void
	{
	}

	@After
	public function tearDown():Void
	{
	}

	@Test
	public function customEnfironment_variablesInArray_resolvesVariables():Void
	{
		var resolver = new VariableResolver(Haxelib.instance, null, false);
		resolver.variables = [new Variable("var1", "v1"), new Variable("var2", "v2")];
		resolver.dependencies = [new Dependency("dep1", "d1", null, null), new Dependency("dep2", "d2", null, null)];
		resolver.systemArguments = ["arg1", "a1", "arg2", "a2"];

		var result:Array<String> = [];
		try
		{
			result = resolver.variablesInArray([
				"${variable:var1}",
				"${arg:arg1}",
				"${arg:argx|arg:arg1}",
				"${arg:argx|variable:var1}",
				"${variable:varx|arg:arg1}",
				"abc",
				"${dependency:dep1:nameVersion}",
				"${dependency:depx:name|arg:arg1}",
				"${dependency:*:name}",
				"${dependency:dep1:dir}", // 10
				"${dependency:dep1:dir:-cp}", // 11,12
				"${dependency:dep1:classPath}", // 13
				"${dependency:dep1:classPath:-lib}", // 14,15
				"${system:cwd}", // 16
				"${dependency:depx:nameVersion|arg:arg1}", // 17
				"${variable:varx|variable:var1|arg:arg1}", // 18
				"${variable:varx|dependency:depx:nameVersion|arg:arg1}" // 19
			]);
		}
		catch(error:Dynamic)
		{
			System.print(haxe.Json.stringify(error));
		}

		//trace(haxe.Json.stringify(result));

		Assert.areEqual('v1', result[0]);
		Assert.areEqual('a1', result[1]);
		Assert.areEqual('a1', result[2]);
		Assert.areEqual('v1', result[3]);
		Assert.areEqual('a1', result[4]);
		Assert.areEqual('abc', result[5]);
		Assert.areEqual('dep1:d1', result[6]);
		Assert.areEqual('a1', result[7]);
		Assert.areEqual('dep1', result[8]);
		Assert.areEqual('dep2', result[9]);
		Assert.areEqual(true, result[10].indexOf("dep1") != -1);
		Assert.areEqual(true, result[10].indexOf("d1") != -1);
		Assert.areEqual('-cp', result[11]);
		Assert.areEqual(true, result[12].indexOf("dep1") != -1);
		Assert.areEqual(true, result[12].indexOf("d1") != -1);
		Assert.areEqual(true, result[13].indexOf("dep1") != -1);
		Assert.areEqual(true, result[13].indexOf("d1") != -1);
		Assert.areEqual('-lib', result[14]);
		Assert.areEqual(true, result[15].indexOf("dep1") != -1);
		Assert.areEqual(true, result[15].indexOf("d1") != -1);
		Assert.areEqual(true, result[16].length > 0);
		Assert.areEqual('a1', result[17]);
		Assert.areEqual('v1', result[18]);
		Assert.areEqual('a1', result[19]);
	}
}