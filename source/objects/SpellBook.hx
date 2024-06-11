package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import states.PlayState;

// idea: maybe projectile that freezes enemy?
enum SPELLS_ACTION
{
	EXPLOSION; // next time you shoot it just causes a big explosion. Make it have a big cooldown
	HEAL; // heals you. Prob like 25 hp with a cooldown
	POISON; // wand projectiles poisons enemies for couple of seconds;
	TELEPORT; // Wherever the wand projectile lands, it teleports you. If you tp in an enemy, enemy fucking EXPLOD ES
	SPEED_BOOST; // Makes you 1.5 times faster for a couple of seconds
	BURST; // Makes every want shot shoot 3 times consecutively for a couple of seconds
	PIERCER; // Projectile can go through multiple enemies (a max of 3)
	BOUNCE; // Projectiles bounce on walls and enemies for like 10 bounces, but you're also cooked if you touch it
	SONIC_SHOT; // Just makes the projectile twice as fast
	DOUBLE_DAMAGE; // Double the damage for a couple of seconds, but your defences get multipled by .5
	DOUBLE_DEFENCE; // Double the defence for a couple of seconds, but your damage get multipled by .5
}

enum SPELLS_STAT
{
	HEALTH;
	DEFENCE;
	SPEED;
	DAMAGE;
}

// maybe exploding the book completely deletes it?
class SpellBook extends FlxSprite
{
	public var containedAction:SPELLS_ACTION;

	public var containedStat:SPELLS_STAT;
	public var statPointsToGive:Int = 0;

	public function new(?containedAction:SPELLS_ACTION = null):Void
	{
		super();
		this.containedAction = containedAction;

		frames = FlxAtlasFrames.fromSparrow('assets/images/Spellbook.png', 'assets/images/Spellbook.xml');
		antialiasing = true;
		scale.set(.5, .5);
		updateHitbox();

		animation.addByPrefix('boil', 'SpellbookNest', 10, true);
		animation.play('boil');
	}

	var sinTime:Float = 0;

	var canPickUp:Bool = true;

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		sinTime += elapsed;

		offset.y = 42.5 + Math.cos(sinTime * 5) * 3;

		if (FlxG.overlap(this, PlayState.instance.player) && canPickUp)
		{
			canPickUp = false;
			PlayState.instance.UnlockSpell(containedAction);

			FlxTween.tween(scale, {x: 2, y: 0.01}, .2, {ease: FlxEase.backIn, onComplete: (twn) -> this.destroy()});
		}
	}

	public function setupStat(containedStat:SPELLS_STAT, pointsToGive:Int):Void
	{
		this.containedStat = containedStat;
		statPointsToGive = pointsToGive;
	}
}
