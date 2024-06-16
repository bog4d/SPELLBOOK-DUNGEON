package states;

import components.MenuButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class MainMenuState extends FlxState
{
	public static var instance:MainMenuState;

	var haxeJamTxt:FlxText;

	var middleBg:FlxSprite;
	var title:FlxText;

	var them:FlxSprite;

	var mainMenuOptions:Array<Array<Dynamic>> = [
		[
			'Play',
			() ->
			{
				FlxG.camera.fade(0xFF000000, 0.5, false, () -> FlxG.switchState(new states.PlayState()));
			}
		],
		['Level Select', () -> {}],
		[
			'Credits',
			() ->
			{
				FlxG.openURL('https://twitter.com/Bogdan4D');
				FlxG.openURL('https://x.com/CheemsnFriendos');
			}
		]
	];

	var mainOptionsGrp:FlxTypedGroup<MenuButton>;

	override function create():Void
	{
		instance = this;

		camera.bgColor = 0xFF808080;
		camera.fade(0xFF000000, 0.5, true);

		middleBg = new FlxSprite().makeGraphic(600, FlxG.height, 0x64000000);
		middleBg.screenCenter();

		haxeJamTxt = new FlxText(0, 5, FlxG.width, 'Submitted for HaxeJam 2024');
		haxeJamTxt.setFormat('assets/fonts/Hello Roti.otf', 20, 0xFFFF8800, CENTER);
		haxeJamTxt.setBorderStyle(OUTLINE, 0xB6000000, 4);
		haxeJamTxt.alpha = 0.5;
		haxeJamTxt.antialiasing = true;

		title = new FlxText(0, 60, FlxG.width, 'SPELLBOOK\nDUNGEON');
		title.setFormat('assets/fonts/Hello Roti.otf', 100, 0xFFFFFFFF, CENTER);
		title.setBorderStyle(OUTLINE, 0xB6000000, 4);
		title.antialiasing = true;
		FlxTween.tween(title, {y: 75}, 2, {ease: FlxEase.sineInOut, type: PINGPONG});

		them = new FlxSprite(10, 535);
		them.frames = FlxAtlasFrames.fromSparrow('assets/images/Us.png', 'assets/images/Us.xml');
		them.animation.addByPrefix('Loop', 'Them', 10, true);
		them.animation.play('Loop');
		them.antialiasing = true;

		mainOptionsGrp = new FlxTypedGroup<MenuButton>();

		for (i in 0...mainMenuOptions.length)
		{
			var _btn = new MenuButton(middleBg.width, mainMenuOptions[i][0]);
			_btn.onClick = mainMenuOptions[i][1];
			_btn.screenCenter(X);
			_btn.y = 330 + i * 70;

			mainOptionsGrp.add(_btn);
		}
		//-----[Layering]-----\\
		add(middleBg);
		add(haxeJamTxt);
		add(mainOptionsGrp);
		add(title);
		add(them);
		//---------------------\\
		super.create();
		//---------------------\\
	}
}
