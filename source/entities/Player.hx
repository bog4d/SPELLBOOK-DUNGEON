package entities;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;

class Player extends FlxSprite
{
	public var speed:Float = 250;

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

		HandleMovement();

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

	private function HandleMovement():Void
	{
		if (FlxG.keys.anyPressed(KeyBinds.PLR_RIGHT))
		{
			velocity.x = 1;
		}
		else if (FlxG.keys.anyPressed(KeyBinds.PLR_LEFT))
		{
			velocity.x = -1;
		}
		else
		{
			velocity.x = 0;
		}

		if (FlxG.keys.anyPressed(KeyBinds.PLR_UP))
		{
			velocity.y = -1;
		}
		else if (FlxG.keys.anyPressed(KeyBinds.PLR_DOWN))
		{
			velocity.y = 1;
		}
		else
		{
			velocity.y = 0;
		}

		velocity = velocity.normalize() * speed;
	}
}
