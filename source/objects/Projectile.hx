package objects;

import flixel.FlxG;
import flixel.FlxObject;
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
	public static var damageMultiplier:Int = 1;

	public var damage:Int = 25;

	var lifetime:Float = 5; // in case the projectile doesnt hit anything

	public var ignorePlrTime:Float;

	public static var activeEffects:Map<String, Bool> = [
		'piercer' => false,
		'bonuce' => false,
		'explosion' => false,
		'poison' => false,
		'sonic_shot' => false,
		'teleport' => false,
	];

	public function new(spawnPos:FlxPoint, clickPoint:FlxPoint):Void
	{
		super();
		this.clickPoint = clickPoint;
		damage *= damageMultiplier;
		ignorePlrTime = activeEffects['sonic_shot'] ? .1 : .15;

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
		ignorePlrTime -= elapsed;
		ignorePlrTime = FlxMath.bound(ignorePlrTime, 0, 1);

		if (activeEffects['bounce'])
			FlxG.collide(this, PlayState.instance.enemyGrp,
				(_:Projectile, two:FlxObject) -> _.angle = FlxAngle.TO_DEG * Math.atan2(velocity.x / speed, -(velocity.y / speed)) - 90);

		elasticity = activeEffects['bounce'] ? 1 : 0;

		FlxG.collide(this, PlayState.instance.prefabGrp, (projectile:Projectile, prefab) ->
		{
			if (activeEffects['teleport'])
			{
				PlayState.instance.player.teleportToPos(getMidpoint());
			}

			if (activeEffects['bounce'])
			{
				projectile.angle = FlxAngle.TO_DEG * Math.atan2(velocity.x / speed, -(velocity.y / speed)) - 90;
				return;
			}
			destroy();
		});

		lifetime -= elapsed;

		if (lifetime < 0)
			this.destroy();
	}

	var remainingPierces:Int = 3;

	public function targetHit():Void
	{
		if (activeEffects['teleport'])
		{
			PlayState.instance.player.teleportToPos(getMidpoint());
		}

		if (activeEffects['piercer'] == true && remainingPierces > 0)
		{
			remainingPierces--;
		}
		else
		{
			if (activeEffects['bounce'])
				return;

			destroy();
		}
	}

	override public function destroy()
	{
		PlayState.instance.projectileGrp.remove(this);
		super.destroy();
	}

	public static function resetEffects():Void
	{
		for (key in activeEffects.keys())
		{
			activeEffects[key] = false;
		}
	}
}
