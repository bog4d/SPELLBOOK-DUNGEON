package states;

import entities.Player;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;

class PlayState extends FlxState
{
	public static var instance:PlayState;

	var camGame:FlxCamera;
	var camHud:FlxCamera;

	var player:Player;

	var crosshair:FlxSprite;

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

		crosshair = new FlxSprite('assets/images/crosshair.png');
		crosshair.antialiasing = true;
		crosshair.scale.set(.8, .8);
		crosshair.updateHitbox();
		crosshair.setPosition(FlxG.mouse.getWorldPosition(camGame).x, FlxG.mouse.getWorldPosition(camGame).y);

		//-----[Layering]-----\\
		add(player);
		add(crosshair);
		//---------------------\\
		super.create();

		camGame.bgColor = 0xFF353535;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		HandleCrosshair(elapsed);
	}

	var crosshairLerpX:Float;
	var crosshairLerpY:Float;

	private function HandleCrosshair(elapsed:Float):Void
	{
		crosshairLerpX = FlxG.mouse.getWorldPosition(camGame).x - crosshair.width / 2;
		crosshairLerpY = FlxG.mouse.getWorldPosition(camGame).y - crosshair.height / 2;

		crosshair.x = FlxMath.lerp(crosshair.x, crosshairLerpX, 15 * elapsed);
		crosshair.y = FlxMath.lerp(crosshair.y, crosshairLerpY, 15 * elapsed);

		crosshair.angle += 25 * elapsed;
	}
}
