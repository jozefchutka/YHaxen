package sk.yoz.yhaxen.valueObjects;

class Error
{
	public var message(default, null):String;
	public var reason(default, null):String;
	public var solution(default, null):String;

	public function new(message:String, reason:String, solution:String)
	{
		this.message = message;
		this.reason = reason;
		this.solution = solution;
	}
}