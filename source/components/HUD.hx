package components;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import objects.SpellBook.SPELLS_ACTION;
import states.PlayState;

class HUD extends FlxSpriteGroup
{
	var vignette:FlxSprite;

	public var spellTimeBar:FlxSprite;
	public var enemiesLeftCounter:FlxText;
	public var enemyCounterObjective:FlxText;

	var spellunlock_bg:FlxSprite;
	var spellUnlock_header:FlxText;
	var spellUnlock_description:FlxText;

	var healthBar:FlxBar;

	var spellUnlockDescriptions:Map<SPELLS_ACTION, String> = [
		EXPLOSION => '"EXPLOSION" Next time you use your wand, it will cause an explosion.\nMake sure you\'re not close!',
		HEAL => '"HEAL" Cast this spell to heal 25 HP.',
		POISON => '"POISON" For a brief period, your wand projectiles will poison enemies\ndealing significant damage overtime.',
		TELEPORT => '"TELEPORT" Next time you use your wand, wherever the projectile lands\nyou\'ll teleport to its location.',
		SPEED_BOOST => '"SPEEDBOOST" Cast this spell to become twice as fast for a brief period of time\nbut you wont be able to stand still.',
		BURST => '"BURST" Cast this spell to tripple the amount of projectiles shot from your wand for\na brief period of time.',
		PIERCER => '"PIERCER" Casting this spell will allow your projectiles to pierce through enemies\nfor a brief period of time.',
		BOUNCE => '"BOUNCE" Casting this spell will make your projectiles bounce off of walls\nand enemies for a brief period of time.',
		SONIC_SHOT => '"SONICSHOT" Casting this spell will double the speed of your\nprojectiles for a brief period of time.',
		DOUBLE_DAMAGE => '"TWOXDMG" Casting this spell will double the amount damage\n your projectiles deal for a brief period of time.',
		DOUBLE_DEFENCE => '"TWOXDEF" Casting this spell will double your\ndefence for a brief period of time.'
	];

	public function new():Void
	{
		super();

		vignette = new FlxSprite('assets/images/vignette.png');
		vignette.color = 0xFF000000;
		vignette.antialiasing = true;
		vignette.scrollFactor.set();

		healthBar = new FlxBar(10, FlxG.height - 50, LEFT_TO_RIGHT, 250, 40, null, null, 0, 100);
		healthBar.createFilledBar(0xFF0F0305, 0xFFBE3144);

		enemiesLeftCounter = new FlxText(FlxG.width - 110, 10, 100, '0');
		enemiesLeftCounter.setFormat('assets/fonts/Hello Roti.otf', 50, 0xFFFF0000, RIGHT);
		enemiesLeftCounter.setBorderStyle(OUTLINE, 0xAD440000, 3, 1);
		enemiesLeftCounter.antialiasing = true;

		enemyCounterObjective = new FlxText(FlxG.width - FlxG.width / 2, enemiesLeftCounter.y + enemiesLeftCounter.height, FlxG.width / 2,
			'Kill all remaining enemies.');
		enemyCounterObjective.setFormat('assets/fonts/Hello Roti.otf', 20, 0xFFFF0000, RIGHT);
		enemyCounterObjective.setBorderStyle(OUTLINE, 0xC35D0000, 3, 1);
		enemyCounterObjective.antialiasing = true;

		spellTimeBar = new FlxSprite(0, 25).makeGraphic(1, 25, 0xFFFFFFFF);
		spellTimeBar.alpha = 0;

		spellunlock_bg = new FlxSprite(0, 50).makeGraphic(1, 150, 0x50000000);
		spellunlock_bg.alpha = 0;

		spellUnlock_header = new FlxText(0, spellunlock_bg.y + 35, FlxG.width, 'UNLOCKED A NEW SPELL!');
		spellUnlock_header.setFormat('assets/fonts/Hello Roti.otf', 50, 0xFFFFD900, CENTER);
		spellUnlock_header.setBorderStyle(OUTLINE, 0x6BFFD900, 3, 1);
		spellUnlock_header.scale.set(1, 0.01);
		spellUnlock_header.alpha = 0;
		spellUnlock_header.antialiasing = true;

		spellUnlock_description = new FlxText(0, spellunlock_bg.y + 70, FlxG.width,
			'This is a text description to check out how various stuff would\nlook like lol. Hi Cheems! Man we should start doing gameplay stuff LOL');
		spellUnlock_description.setFormat('assets/fonts/Hello Roti.otf', 25, 0xFFFFFFFF, CENTER);
		spellUnlock_description.scale.set(1, 0.1);
		spellUnlock_description.alpha = 0;
		spellUnlock_description.antialiasing = true;

		//-----[Layering]-----\\
		add(vignette);
		add(healthBar);
		add(enemiesLeftCounter);
		add(enemyCounterObjective);
		add(spellTimeBar);

		add(spellunlock_bg);
		add(spellUnlock_header);
		add(spellUnlock_description);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		spellTimeBar.screenCenter(X);
		spellunlock_bg.screenCenter(X);

		healthBar.value = FlxMath.lerp(healthBar.value, PlayState.instance.player.hp, 25 * elapsed);
		enemiesLeftCounter.text = '${PlayState.instance.enemyGrp.countLiving() - 1}';

		if (enemiesLeftCounter.text == '0')
			enemyCounterObjective.text = 'Find the exit portal.';
		/*
			#if debug
			if (FlxG.keys.justPressed.K)
				triggerNewSpellBg(SPEED_BOOST);
			#end
		 */
	}

	public function triggerNewSpellBg(spell:SPELLS_ACTION):Void
	{
		FlxSpriteUtil.fadeIn(spellunlock_bg, 0.5);
		FlxTween.tween(spellunlock_bg.scale, {x: FlxG.width}, 0.5, {ease: FlxEase.expoInOut});

		spellUnlock_description.text = spellUnlockDescriptions[spell];

		new FlxTimer().start(0.3, (tmr) ->
		{
			spellUnlock_header.y = spellunlock_bg.y + 35;
			FlxSpriteUtil.fadeIn(spellUnlock_header, 0.5);
			FlxTween.tween(spellUnlock_header.scale, {x: 1, y: 1}, 0.2, {ease: FlxEase.backOut});

			new FlxTimer().start(0.2, (tmr) ->
			{
				FlxTween.tween(spellUnlock_header, {y: spellUnlock_header.y - 25}, 1, {ease: FlxEase.expoInOut});

				FlxTween.tween(spellUnlock_description, {alpha: 1}, 0.1, {startDelay: .6});
				FlxTween.tween(spellUnlock_description.scale, {x: 1, y: 1}, 0.2, {ease: FlxEase.backOut, startDelay: 0.6});

				new FlxTimer().start(5, (tmr) ->
				{
					FlxTween.tween(spellunlock_bg.scale, {y: 0.01}, .5, {ease: FlxEase.expoIn});
					FlxTween.tween(spellUnlock_header, {alpha: 0}, .3, {startDelay: .1});
					FlxTween.tween(spellUnlock_description, {alpha: 0}, .3);

					new FlxTimer().start(0.5, (tmr) ->
					{
						spellunlock_bg.alpha = 0;
						spellunlock_bg.scale.set(1, 1);
						spellUnlock_header.scale.set(1, 0.01);
						spellUnlock_description.scale.set(1, 0.1);
					});
				});
			});
		});
	}
}
