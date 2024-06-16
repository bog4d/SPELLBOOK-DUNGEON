package entities;

import components.FSM;
import components.IEnemy;
import components.IKillable;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import objects.Projectile;
import states.PlayState;

class Slime extends FlxSprite implements IKillable implements IEnemy
{
	var fsm:FSM;

	public var hp:Int = 100;
	public var speed:Float = 150; // TODO: INCREASE THE MORE YOU PLAY;
	public var dmg:Int = 25; // TODO: INCREASE THE MORE YOU PLAY;

	public var isAggro:Bool = false;

	public function new():Void
	{
		super();
		// immovable = true;

		frames = FlxAtlasFrames.fromSparrow('assets/images/characters/slime/Slime.png', 'assets/images/characters/slime/Slime.xml');
		animation.addByPrefix('Idle', 'Slime', 10, true);
		animation.play('Idle');

		scale.set(.3, .3);
		updateHitbox();

		antialiasing = true;
		fsm = new FSM(state_idle);
	}

	var invincibilityTime:Float = 0;

	override public function update(elapsed:Float):Void
	{
		fsm.update(elapsed);
		super.update(elapsed);

		if (FlxG.overlap(this, PlayState.instance.plrHurtbox))
		{
			PlayState.instance.player.takeDamage(dmg);
		}

		invincibilityTime -= elapsed;
		invincibilityTime = FlxMath.bound(invincibilityTime, 0, 999);

		FlxG.overlap(this, PlayState.instance.projectileGrp, (enemy:IKillable, projectile:Projectile) ->
		{
			if (invincibilityTime > 0)
				return;

			projectile.targetHit();
			enemy.takeDamage(projectile.damage);
			if (projectile.actEff["poison"])
				new FlxTimer().start(2, function(_)
				{
					enemy.takeDamage(projectile.damage);
				}, 2);
		});
	}

	public function takeDamage(dmg:Int):Void
	{
		hp -= dmg;
		if (hp <= 0)
		{
			onDeath();
			return;
		}

		invincibilityTime = 0.5;
		FlxFlicker.flicker(this, invincibilityTime);
		FlxTween.shake(this, 0.05, invincibilityTime / 2, XY);
	}

	private function onDeath():Void
	{
		destroy();
	}

	override public function destroy():Void
	{
		PlayState.instance.enemyGrp.remove(this);
		super.destroy();
	}

	// STATES
	var idleTimer:Float = FlxG.random.float(0.5, 3);
	var idlePos:FlxPoint = new FlxPoint();

	function state_idle(elapsed:Float):Void
	{
		idleTimer -= elapsed;
		if (idleTimer <= 0)
		{
			idleTimer = FlxG.random.float(0.1, 3);
			idlePos.x += FlxG.random.float(-250, 250);
			idlePos.y += FlxG.random.float(-250, 250);
		}
		FlxVelocity.moveTowardsPoint(this, idlePos, 50);
		if (getPosition().distanceTo(PlayState.instance.plrHurtbox.getMidpoint()) < 500)
		{
			if (PlayState.instance.level.ray(this.getMidpoint(), PlayState.instance.player.getMidpoint()))
			{
				fsm.setState(state_aggresive);
			}
		}
	}

	function state_aggresive(elapsed:Float):Void
	{
		isAggro = true;
		animation.curAnim.frameRate = 24;
		FlxVelocity.moveTowardsPoint(this, PlayState.instance.plrHurtbox.getMidpoint(), (invincibilityTime <= 0) ? speed : speed / 2);
	}
}
