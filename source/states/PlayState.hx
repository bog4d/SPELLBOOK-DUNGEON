package states;

import entities.Player;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;

class PlayState extends FlxState
{
	public static var instance:PlayState;

	var camGame:FlxCamera;
	var camHud:FlxCamera;

	var player:Player;

	override public function create()
	{
		instance = this;

		//-----[Cameras]-----\\
		camGame = new FlxCamera();
		camHud = new FlxCamera();

		camHud.bgColor.alpha = 0;

		FlxCamera.defaultCameras = [camGame];

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHud);
		//--------------------\\
		player = new Player();
		player.screenCenter();

		//-----[Layering]-----\\
		add(player);
		super.create();

		camGame.bgColor = 0xFF353535;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
