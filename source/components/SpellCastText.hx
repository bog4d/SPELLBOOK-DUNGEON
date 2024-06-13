package components;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

class SpellCastText extends FlxSpriteGroup
{
	public var acceptInput:Bool = false;
	public var curSpell:String = '';

	var acceptedKeys:Array<FlxKey> = [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z];

	var characters:FlxSpriteGroup;

	public function new():Void
	{
		super();

		characters = new FlxSpriteGroup();

		add(characters);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		characters.x = FlxMath.lerp(characters.x, x - characters.width / 2, 25 * elapsed);

		for (character in characters)
			character.y = y;
		HandleTyping(elapsed);
	}

	function HandleTyping(elapsed:Float):Void
	{
		if (!acceptInput)
			return;

		if (FlxG.keys.firstJustPressed() != -1)
		{
			// im just stupid
			if (FlxG.keys.firstJustPressed() == FlxKey.BACKSPACE && characters.members != [])
			{
				characters.group.remove(characters.members[characters.length - 1], true);
				return;
			}

			for (key in acceptedKeys)
			{
				if (FlxG.keys.firstJustPressed() == key)
				{
					var key = String.fromCharCode(key);
					trace(key);
					curSpell += key;

					characters.add(new SpellCharacter(key, 20 * characters.length, y));
				}
			}
		}
	}

	public function resetText():Void
	{
		for (character in characters)
		{
			FlxSpriteUtil.fadeOut(character, 0.3);
		}

		new FlxTimer().start(.3, (tmr) -> characters.clear());
	}
}

class SpellCharacter extends FlxText
{
	public function new(char:String, X:Float, Y:Float):Void
	{
		super(X, 0, 100, char.charAt(0));
		setFormat('assets/fonts/Hello Roti.otf', 32, 0xFFFFFFFF, CENTER, OUTLINE, 0x64000000);
		borderSize = 4;
		antialiasing = true;
		appear();
	}

	function appear():Void
	{
		alpha = 0;
		offset.y -= 25;
		FlxTween.tween(this, {alpha: 1}, 0.1, {ease: FlxEase.backOut});
		FlxTween.tween(this.offset, {y: 0}, 0.1, {ease: FlxEase.backOut});
	}
}
