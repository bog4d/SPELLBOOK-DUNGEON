package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, states.MainMenuState));
		addChild(new FPS(10, 10, 0xFFFFFFFF));

		FlxG.fixedTimestep = false;
		FlxG.mouse.useSystemCursor = true;
	}
}
