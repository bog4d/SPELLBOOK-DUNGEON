package components;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class HUD extends FlxSpriteGroup
{
	var vignette:FlxSprite;

	public function new():Void
	{
		super();

		vignette = new FlxSprite('assets/images/vignette.png');
		vignette.color = 0xFF000000;
		vignette.antialiasing = true;
		vignette.scrollFactor.set();

		//-----[Layering]-----\\
		add(vignette);
	}
}
