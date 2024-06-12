package entities;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import states.PlayState;

class Player extends FlxSprite
{
	public var speed:Float = 300;

	public function new()
	{
		super();

		frames = FlxAtlasFrames.fromSparrow('assets/images/characters/player/Player.png', 'assets/images/characters/player/Player.xml');
		scale.set(.3, .3);
		updateHitbox();
		height = 10;
		width -= 25;

		origin.y += 300;
		offset.y += 360;
		offset.x += 10;

		antialiasing = true;
	}

	private var moveInput:FlxPoint = new FlxPoint(0, 0);

	var timeSinceSpawn:Float = 0;

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		timeSinceSpawn += elapsed;

		HandleMovement(elapsed);
		HandleLooking();

		if (Math.abs(velocity.x) > 5 || Math.abs(velocity.y) > 5)
		{
			scale.y = FlxMath.lerp(scale.y, .3 + Math.sin(timeSinceSpawn * 20) / 50, 15 * elapsed);
		}
		else
		{
			scale.y = FlxMath.lerp(scale.y, .3 + Math.sin(timeSinceSpawn * 2) / 100, 15 * elapsed);
		}
	}

	var moveDir:FlxPoint = new FlxPoint(0, 0);

	public var disableMoveInput:Bool = false;

	private function HandleMovement(elapsed:Float):Void
	{
		if (FlxG.keys.anyPressed(KeyBinds.PLR_RIGHT))
		{
			moveDir.x = 1;
		}
		else if (FlxG.keys.anyPressed(KeyBinds.PLR_LEFT))
		{
			moveDir.x = -1;
		}
		else
		{
			moveDir.x = 0;
		}

		if (FlxG.keys.anyPressed(KeyBinds.PLR_UP))
		{
			moveDir.y = -1;
		}
		else if (FlxG.keys.anyPressed(KeyBinds.PLR_DOWN))
		{
			moveDir.y = 1;
		}
		else
		{
			moveDir.y = 0;
		}

		var newVel = (!disableMoveInput) ? (moveDir.normalize() * speed) : FlxPoint.get();

		velocity.x = FlxMath.lerp(velocity.x, newVel.x, 15 * elapsed);
		velocity.y = FlxMath.lerp(velocity.y, newVel.y, 15 * elapsed);
	}

	private function HandleLooking():Void
	{
		var mousePos:FlxPoint = FlxG.mouse.getWorldPosition(FlxG.camera);

		var hurtbox:FlxObject = PlayState.instance.plrHurtbox;

		if (mousePos.x > hurtbox.x + hurtbox.width)
		{
			animation.frameIndex = 1;
		}
		else if (mousePos.x < hurtbox.x)
		{
			animation.frameIndex = 3;
		}
		else if (mousePos.y > hurtbox.y + hurtbox.height / 2)
		{
			animation.frameIndex = 0;
		}
		else if (mousePos.y < hurtbox.y + hurtbox.height / 2)
		{
			animation.frameIndex = 2;
		}
	}
}
