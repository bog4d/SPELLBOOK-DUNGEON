package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import states.PlayState;

class Projectile extends FlxSprite
{
	var clickPoint:FlxPoint;

	public static var speed:Float = 1000;

	var lifetime:Float = 5; // in case the projectile doesnt hit anything

	public function new(spawnPos:FlxPoint, clickPoint:FlxPoint):Void
	{
		super();
		this.clickPoint = clickPoint;

		makeGraphic(50, 10, 0xFFFFFFFF);

		// lookAt(clickPoint)
		setPosition(spawnPos.x, spawnPos.y);

		angle = FlxAngle.angleBetweenMouse(this, true);
		velocity = FlxVelocity.velocityFromAngle(angle, speed);
	}

	// TODO: HANDLE PROJECTILE COLLISIONS ONCE CHEEMS FINISHED THE LEVEL SYSTEM!!!!
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		lifetime -= elapsed;

		if (lifetime < 0)
			this.destroy();
	}
}
