package entities;

import components.IKillable;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import objects.Projectile;
import states.PlayState;
import substates.GameOverSubState;

class Player extends FlxSprite implements IKillable
{
	public var hp:Int = 100;
	public var speed:Float = 300;

	public var takeDamageMultiplier:Float = 1;

	public function new()
	{
		super();

		frames = FlxAtlasFrames.fromSparrow('assets/images/characters/player/Player.png', 'assets/images/characters/player/Player.xml');
		scale.set(.3, .3);
		updateHitbox();
		height = 10;
		width -= 25;
		// immovable = true; bro u broke the collision by adding this line LMAO

		origin.y += 300;
		offset.y += 360;
		offset.x += 10;

		animation.addByPrefix("Down", "Down", 10);
		animation.addByPrefix("Left", "Left", 10);
		animation.addByPrefix("Right", "Right", 10);
		animation.addByPrefix("Up", "Up", 10);

		antialiasing = true;
	}

	private var moveInput:FlxPoint = new FlxPoint(0, 0);

	var timeSinceSpawn:Float = 0;

	var invincibilityTime:Float = 0;

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		timeSinceSpawn += elapsed;
		invincibilityTime -= elapsed;

		HandleMovement(elapsed);
		HandleLooking();

		FlxG.overlap(this, PlayState.instance.projectileGrp, (plr:IKillable, projectile:Projectile) ->
		{
			if (invincibilityTime > 0 || projectile.ignorePlrTime > 0)
				return;
			projectile.targetHit();
			if (!projectile.actEff["teleport"])
				plr.takeDamage(projectile.damage);

			if (projectile.actEff["poison"])
				new FlxTimer().start(2, function(_)
				{
					plr.takeDamage(projectile.damage);
				}, 2);
		});

		scale.x = FlxMath.lerp(scale.x, .3, 20 * elapsed);

		if (Math.abs(velocity.x) > 5 || Math.abs(velocity.y) > 5)
		{
			scale.y = FlxMath.lerp(scale.y, .3 + Math.sin(timeSinceSpawn * 0.05 * speed) / 75, 20 * elapsed);
		}
		else
		{
			scale.y = FlxMath.lerp(scale.y, .3 + Math.sin(timeSinceSpawn * 0.0066 * speed) / 100, 20 * elapsed);
		}
	}

	public function takeDamage(dmg:Int):Void
	{
		if (invincibilityTime > 0)
			return;

		hp -= Std.int(dmg * takeDamageMultiplier);

		if (hp <= 0)
			onDeath();

		invincibilityTime = .7;
		FlxFlicker.flicker(this, invincibilityTime);
		FlxTween.shake(this, 0.15, invincibilityTime / 2, XY);
		FlxTween.color(this, invincibilityTime, 0xFFFF0000, 0xFFFFFFFF);
		FlxG.camera.shake(0.005, 0.2);
	}

	public function onDeath():Void
	{
		// PlayState.instance.resetProgress(); no more rougelike wuh oh

		FlxG.camera.shake(0.05, 0.1);
		var gameOverSubSub:GameOverSubState = new GameOverSubState();
		gameOverSubSub.cameras = [PlayState.instance.camHud];
		PlayState.instance.openSubState(gameOverSubSub);
	}

	public function heal(healHp:Int):Void
	{
		hp += healHp;

		FlxTween.color(this, invincibilityTime, 0xFF00FF2A, 0xFFFFFFFF);
		PlayState.instance.camHud.flash(0x0B00FF2A, 1);

		if (hp > 100)
			hp = 100;
	}

	public function teleportToPos(newPos:FlxPoint):Void
	{
		setPosition(newPos.x, newPos.y);
		PlayState.instance.player.scale.set(1, 0.01);
		PlayState.instance.hand.setPosition(newPos.x, newPos.y);
		PlayState.instance.camGame.fade(0xFF000000, 0.3, true, true);
	}

	var moveDir:FlxPoint = new FlxPoint(0, 0);

	public var disableMoveInput:Bool = false;

	private function HandleMovement(elapsed:Float):Void
	{
		if (FlxG.keys.anyPressed(KeyBinds.PLR_RIGHT))
		{
			moveDir.x = 1;
		}
		else if (FlxG.keys.anyPressed(KeyBinds.PLR_LEFT))
		{
			moveDir.x = -1;
		}
		else
		{
			moveDir.x = 0;
		}

		if (FlxG.keys.anyPressed(KeyBinds.PLR_UP))
		{
			moveDir.y = -1;
		}
		else if (FlxG.keys.anyPressed(KeyBinds.PLR_DOWN))
		{
			moveDir.y = 1;
		}
		else
		{
			moveDir.y = 0;
		}

		var newVel = (!disableMoveInput) ? (moveDir.normalize() * speed) : FlxPoint.get();

		velocity.x = FlxMath.lerp(velocity.x, newVel.x, 15 * elapsed);
		velocity.y = FlxMath.lerp(velocity.y, newVel.y, 15 * elapsed);
	}

	private function HandleLooking():Void
	{
		var mousePos:FlxPoint = FlxG.mouse.getWorldPosition(FlxG.camera);

		var hurtbox:FlxObject = PlayState.instance.plrHurtbox;

		if (mousePos.x > hurtbox.x + hurtbox.width)
		{
			animation.play("Right");
		}
		else if (mousePos.x < hurtbox.x)
		{
			animation.play("Left");
		}
		else if (mousePos.y > hurtbox.y + hurtbox.height / 2)
		{
			animation.play("Down");
		}
		else if (mousePos.y < hurtbox.y + hurtbox.height / 2)
		{
			animation.play("Up");
		}
	}
}
