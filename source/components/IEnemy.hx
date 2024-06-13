package components;

interface IKillable
{
	public var hp:Int;
	public function takeDamage(dmg:Int):Void;
	private function onDeath():Void;
}
