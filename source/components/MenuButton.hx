package components;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.text.FlxText;

class MenuButton extends FlxText
{
	public function new(txtWidth:Float, txt:String):Void
	{
		super(0, 0, txtWidth, txt);
		setFormat('assets/fonts/Hello Roti.otf', 55, 0xFFFFFFFF, CENTER);
		setBorderStyle(OUTLINE, 0xFF000000, 4, 1);

		autoSize = antialiasing = true;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		var newScale = FlxG.mouse.overlaps(this) ? 1.1 : 1;
		var lerpVal:Float = 10 * elapsed;
		var lerpAlpha:Float = FlxG.mouse.overlaps(this) ? 1 : .6;

		scale.set(FlxMath.lerp(scale.x, newScale, lerpVal), FlxMath.lerp(scale.y, newScale, lerpVal));
		alpha = FlxMath.lerp(alpha, lerpAlpha, lerpVal);

		if (FlxG.mouse.justReleased && FlxG.mouse.overlaps(this))
			onClick();
	}

	dynamic public function onClick():Void
	{
		trace("CLICKED OPTION! :P");
	}
}
