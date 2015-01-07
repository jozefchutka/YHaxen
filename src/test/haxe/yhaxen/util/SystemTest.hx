package yhaxen.util;

import massive.munit.Assert;

class SystemTest
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
	public function argument_escapeArgument_areEscaped():Void
	{
		Assert.areEqual('a', System.escapeArgument("a"));
		Assert.areEqual('"a=b"', System.escapeArgument("a=b"));
		Assert.areEqual('"a b"', System.escapeArgument("a b"));
		Assert.areEqual('aZ1-8.', System.escapeArgument("aZ1-8."));
		Assert.areEqual('"a\nb"', System.escapeArgument("a\nb"));
		Assert.areEqual('"version=0.0"', System.escapeArgument("version=0.0"));
		Assert.areEqual('src/main/haxe', System.escapeArgument("src/main/haxe"));
		Assert.areEqual('"a\\"b"', System.escapeArgument('a"b'));
	}
}