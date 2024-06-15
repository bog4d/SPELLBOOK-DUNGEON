package entities;

import components.FSM;
import components.IEnemy;
import components.IKillable;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.tweens.FlxTween;
import objects.Projectile;
import states.PlayState;

class Ghoul extends FlxSprite implements IKillable implements IEnemy
{
	var fsm:FSM;

	public var hp:Int = 100;
	public var speed:Float = 150; // TODO: INCREASE THE MORE YOU PLAY;
	public var dmg:Int = 25; // TODO: INCREASE THE MORE YOU PLAY;

	public var isAggro:Bool = false;

	public function new():Void
	{
		super();
		immovable = true;

		fsm = new FSM(state_idle);

		makeGraphic(50, 50, 0xFFFF0000);
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
		if (getPosition().distanceTo(PlayState.instance.plrHurtbox.getMidpoint()) < 300)
		{
			for (prefab in PlayState.instance.prefabGrp)
			{
				// This is definitely going to be hard to process the more prefabs there exist
				// Cheems im actually so fucking sorry but i want to finis hthis gamejam so im sorry
				if (prefab.ray(this.getMidpoint(), PlayState.instance.player.getMidpoint()))
				{
					fsm.setState(state_aggresive);
				}
			}
		}
	}

	function state_aggresive(elapsed:Float):Void
	{
		isAggro = true;
		FlxVelocity.moveTowardsPoint(this, PlayState.instance.plrHurtbox.getMidpoint(), (invincibilityTime <= 0) ? speed : speed / 2);
	}
}
