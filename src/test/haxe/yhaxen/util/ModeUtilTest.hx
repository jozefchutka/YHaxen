package yhaxen.util;

import massive.munit.Assert;

class ModeUtilTest
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
	public function testExample():Void
	{
		Assert.isTrue(ModeUtil.matches(["a"], "a"));
		Assert.isTrue(ModeUtil.matches(null, null));
		Assert.isTrue(ModeUtil.matches(["a", "b", "c"], "a"));
		Assert.isTrue(ModeUtil.matches(["a", "b", "c"], "b"));
		Assert.isTrue(ModeUtil.matches(["a", "b", "c"], "c"));

		Assert.isFalse(ModeUtil.matches(null, "a"));
		Assert.isFalse(ModeUtil.matches([], "a"));
		Assert.isFalse(ModeUtil.matches(["a", "b", "c"], "d"));
		Assert.isFalse(ModeUtil.matches(["a", "b", "c"], null));
	}
}