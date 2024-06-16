package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import states.PlayState;

class GameOverSubState extends FlxSubState
{
	var gameOverHeader:FlxText;

	var canExit:Bool = false;

	public function new():Void
	{
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.scrollFactor.set();
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: .64}, 0.3);
		FlxTween.tween(bg, {alpha: 1}, 3, {startDelay: 2});

		gameOverHeader = new FlxText(0, 0, FlxG.width, 'GAME OVER');
		gameOverHeader.setFormat('assets/fonts/Hello Roti.otf', 100, 0xFFFF0000, CENTER);
		gameOverHeader.setBorderStyle(OUTLINE, 0x6B720000, 5, 1);
		gameOverHeader.scale.set(1, 0.01);
		gameOverHeader.antialiasing = true;

		gameOverHeader.screenCenter();
		FlxTween.tween(gameOverHeader.scale, {y: 1}, 0.5, {ease: FlxEase.backOut});
		FlxTween.shake(gameOverHeader, 0.001, 999, XY);
		//-----[Layering]-----\\
		add(bg);
		add(gameOverHeader);

		new FlxTimer().start(1, (tmr) -> canExit = true);

		FlxG.sound.play('assets/sounds/gameOver.ogg', .4);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		PlayState.instance.baseMusic.volume -= elapsed * .25;
		PlayState.instance.combatMusic.volume -= elapsed * .3;
		PlayState.instance.calmMusic.volume += elapsed * .3;
		PlayState.instance.camGame.zoom -= elapsed * .01;
		if (FlxG.keys.justPressed.ANY && canExit)
		{
			canExit = false;
			PlayState.instance.camHud.fade(0xFF000000, 1, false, () ->
			{
				if (PlayState.isLevelSelect)
					FlxG.switchState(new states.MainMenuState());
				else
					FlxG.resetState();
				close();
			});
		}
	}
}
