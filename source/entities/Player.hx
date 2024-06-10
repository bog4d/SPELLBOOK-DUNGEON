package entities;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

class Player extends FlxSprite
{
	public var speed:Float = 300;

	public function new()
	{
		super();

		frames = FlxAtlasFrames.fromSparrow('assets/images/characters/player/Player.png', 'assets/images/characters/player/Player.xml');
		scale.set(.3, .3);
		updateHitbox();

		antialiasing = true;
	}

	private var moveInput:FlxPoint = new FlxPoint(0, 0);

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		HandleMovement(elapsed);
		HandleLooking();
	}

	var moveDir:FlxPoint = new FlxPoint(0, 0);

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

		var newVel = moveDir.normalize() * speed;

		velocity.x = FlxMath.lerp(velocity.x, newVel.x, 15 * elapsed);
		velocity.y = FlxMath.lerp(velocity.y, newVel.y, 15 * elapsed);
	}

	private function HandleLooking():Void
	{
		var mousePos:FlxPoint = FlxG.mouse.getWorldPosition(FlxG.camera);

		if (mousePos.x > this.x + width)
		{
			animation.frameIndex = 1;
		}
		else if (mousePos.x < this.x)
		{
			animation.frameIndex = 3;
		}
		else if (mousePos.y > y + height / 2)
		{
			animation.frameIndex = 0;
		}
		else if (mousePos.y < y + height / 2)
		{
			animation.frameIndex = 2;
		}
	}
}
