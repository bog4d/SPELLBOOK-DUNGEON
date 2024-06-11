package components;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class HUD extends FlxSpriteGroup
{
	var vignette:FlxSprite;

	public var spellTimeBar:FlxSprite;

	public function new():Void
	{
		super();

		vignette = new FlxSprite('assets/images/vignette.png');
		vignette.color = 0xFF000000;
		vignette.antialiasing = true;
		vignette.scrollFactor.set();

		spellTimeBar = new FlxSprite(0, 25).makeGraphic(1, 25, 0xFFFFFFFF);
		spellTimeBar.alpha = 0;
		//-----[Layering]-----\\
		add(vignette);
		add(spellTimeBar);
	}

	override function update(elapsed:Float):Void
	{
		spellTimeBar.screenCenter(X);
	}
}
