package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;
import haxe.display.JsonModuleTypes.JsonTypeParameters;
import states.PlayState;

class LevelSelectSubState extends FlxSubState
{
	var bg:FlxSprite;
	var curSelected:Int = 0;
	var levelText:FlxText;

	final maxLevels:Int = 4;

	public function new():Void
	{
		super();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xD7000000);
		bg.alpha = 0;
		FlxSpriteUtil.fadeIn(bg, 0.1);

		levelText = new FlxText(0, 0, FlxG.width, 'LEVEL ?');
		levelText.setFormat('assets/fonts/Hello Roti.otf', 128, 0xFFFFFFFF, CENTER);
		levelText.setBorderStyle(OUTLINE, 0x89000000, 10, 1);
		levelText.screenCenter();

		changeSelection(0);
		//-----[LAYERING]-----\\
		add(bg);
		add(levelText);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE]))
			close();

		if (FlxG.keys.anyJustPressed([RIGHT, D]))
			changeSelection(1);
		else if (FlxG.keys.anyJustPressed([LEFT, A]))
			changeSelection(-1);

		if (FlxG.keys.anyJustPressed([SPACE, ENTER]))
		{
			PlayState.isLevelSelect = true;
			PlayState.LevelID = curSelected;

			FlxG.switchState(new PlayState());
		}
	}

	function changeSelection(skips:Int):Void
	{
		curSelected += skips;

		if (curSelected > maxLevels)
			curSelected = maxLevels;
		else if (curSelected < 0)
			curSelected = 0;

		levelText.text = 'LEVEL $curSelected';
	}
}

class LevelSelectIcon extends FlxSpriteGroup
{
	public var targX:Int = 0;

	public function new():Void
	{
		super();
	}
}
