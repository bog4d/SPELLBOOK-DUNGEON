package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.utils.Assets;
import states.MainMenuState;
import states.PlayState;

class ExitPortal extends FlxSprite
{
	public function new():Void
	{
		super();
		frames = FlxAtlasFrames.fromSparrow('assets/images/Portal.png', 'assets/images/Portal.xml');
		animation.addByPrefix('loop', 'Portal', 10, true);
		animation.play('loop');

		scale.set(.3, .3);
		updateHitbox();

		FlxTween.tween(offset, {y: offset.y - 10}, 1, {ease: FlxEase.sineInOut, type: PINGPONG});
	}

	var debounce:Bool = false;

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		alpha = FlxMath.lerp(alpha, (PlayState.instance.enemyGrp.countLiving() - 1 == 0) ? 1 : .3, 10 * elapsed);

		if (FlxG.overlap(this, PlayState.instance.player) && !debounce && PlayState.instance.enemyGrp.countLiving() - 1 == 0)
		{
			debounce = true;

			if (Assets.exists('assets/data/levels/lv_${PlayState.LevelID + 1}.json') && !PlayState.isLevelSelect)
			{
				PlayState.LevelID++;

				PlayState.instance.camHud.fade(0xFF000000, 1, false, () ->
				{
					FlxG.resetState();
				});
			}
			else
			{
				PlayState.instance.camHud.fade(0xFF000000, 1, false, () ->
				{
					FlxG.switchState(new MainMenuState());
				});
			}
		}
	}
}
