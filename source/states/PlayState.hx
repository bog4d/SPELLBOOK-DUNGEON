package states;

import components.HUD;
import components.IEnemy;
import components.IKillable;
import components.SpellCastText;
import entities.Player;
import entities.Slime;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import objects.Projectile;
import objects.SpellBook;
import openfl.Assets;

class PlayState extends FlxState
{
	public static var instance:PlayState;

	public var camGame:FlxCamera;
	public var camHud:FlxCamera;

	var hud:HUD;

	public var player:Player;
	public var plrHurtbox:FlxObject;

	var spellCastTxt:SpellCastText;
	var crosshair:FlxSprite;

	public var levelLoader:FlxOgmo3Loader;
	public var level:FlxTilemap;

	public var projectileGrp:FlxTypedGroup<Projectile>;
	public var enemyGrp:FlxGroup;

	public var baseMusic:FlxSound;
	public var calmMusic:FlxSound;
	public var combatMusic:FlxSound;

	public var isInCombat:Bool = false;

	public static var unlockedSpells:Map<SPELLS_ACTION, Bool> = [
		EXPLOSION => false, HEAL => false, POISON => false, TELEPORT => false, SPEED_BOOST => false, BURST => false, PIERCER => false, BOUNCE => false,
		SONIC_SHOT => false, DOUBLE_DAMAGE => false, DOUBLE_DEFENCE => false
	];

	override public function create()
	{
		instance = this;
		FlxG.timeScale = 1;
		//-----[Cameras]-----\\
		camGame = new FlxCamera();
		camHud = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHud, false);

		camHud.bgColor.alpha = 0;
		//-----[LV LOADER SHITS]-----\\
		levelLoader = new FlxOgmo3Loader('assets/data/SpellbookDungeon.ogmo', 'assets/data/levels/lv_3.json');
		level = levelLoader.loadTilemap('assets/images/tileset.png', 'Level');
		addTileProprieties(level);
		level.follow(camGame);

		//------[LE SOUND]------\\

		calmMusic = new FlxSound().loadEmbedded('assets/music/calm_mode.ogg', true);
		FlxG.sound.list.add(calmMusic);
		calmMusic.volume = 0;
		calmMusic.play();

		combatMusic = new FlxSound().loadEmbedded('assets/music/combat_mode.ogg', true);
		FlxG.sound.list.add(combatMusic);
		combatMusic.volume = 0;
		combatMusic.play();

		baseMusic = new FlxSound().loadEmbedded('assets/music/base.ogg', true);
		FlxG.sound.list.add(baseMusic);
		baseMusic.volume = .3;
		// baseMusic.endTime = baseMusic.length - 10;
		baseMusic.play();

		//-----[Other]-----\\

		hud = new HUD();
		hud.cameras = [camHud];

		player = new Player();
		player.screenCenter();
		plrHurtbox = new FlxObject(player.x, player.y, 50, 125);

		spellCastTxt = new SpellCastText();

		crosshair = new FlxSprite('assets/images/crosshair.png');
		crosshair.antialiasing = true;
		crosshair.scale.set(.8, .8);
		crosshair.updateHitbox();
		crosshair.setPosition(FlxG.mouse.getWorldPosition(camGame).x, FlxG.mouse.getWorldPosition(camGame).y);

		projectileGrp = new FlxTypedGroup<Projectile>();
		Projectile.resetEffects();

		enemyGrp = new FlxGroup();

		var slime = new Slime();
		slime.screenCenter();
		slime.y -= 500;
		enemyGrp.add(slime);

		final gridGraphic = FlxGridOverlay.createGrid(64, 64, 128, 128, true, 0xFF0E0E0E, 0xFF222222);
		var bg = new FlxBackdrop(gridGraphic, XY);
		bg.scrollFactor.set(.3, .3);
		bg.velocity.set(15, 15);
		bg.color = 0xFF393939;

		//-----[Layering]-----\\
		add(bg);
		add(level);

		add(enemyGrp);
		add(projectileGrp);
		add(player);
		add(plrHurtbox);

		add(spellCastTxt);
		add(crosshair);

		// hud stuff
		add(hud);
		//---------------------\\
		camGame.follow(plrHurtbox, LOCKON, 1);
		super.create();

		levelLoader.loadEntities((ent:EntityData) ->
		{
			switch (ent.name)
			{
				case 'PlayerSpawn':
					player.setPosition(ent.x - player.width / 2, ent.y - player.height / 2);
				case 'Enemy':
					var _slime:Slime = new Slime();
					_slime.setPosition(ent.x - _slime.width / 2, ent.y - _slime.height / 2);
					enemyGrp.add(_slime);
				case 'SpellbookSpawner':
					var _spellBook:SpellBook = new SpellBook(SPELLS_ACTION.createByName(ent.values.SPELL));
					_spellBook.setPosition(ent.x - _spellBook.width / 2, ent.y - _spellBook.height / 2);

					insert(members.indexOf(enemyGrp), _spellBook);
			}
		}, 'Entities');
		camGame.bgColor = 0xFF353535;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.collide(enemyGrp, level);
		FlxG.collide(enemyGrp, enemyGrp);
		FlxG.collide(player, level);

		camGame.followLerp = 5 * elapsed;
		plrHurtbox.setPosition(player.x + 15, player.y - 125);

		spellCastTxt.setPosition(player.x + player.width / 2, player.y - 200);

		var aggroCheckArray:Array<Bool> = [];
		for (enm in enemyGrp)
		{
			var _enemy:IEnemy = cast enm;
			aggroCheckArray.insert(0, _enemy.isAggro);
		}
		isInCombat = aggroCheckArray.contains(true);

		HandleCrosshair(elapsed);
		HandleSpellCasting(elapsed);
		HandleShooting();
		HandleMusicStuff(elapsed);

		#if debug
		FlxG.watch.addQuick('isInCombat', isInCombat);
		#end
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

	var canCastSpell:Bool = true;
	var isinSpellMode:Bool = false;

	private function HandleSpellCasting(elapsed:Float):Void
	{
		if (FlxG.keys.anyJustPressed(KeyBinds.CAST_SPELL) && canCastSpell)
		{
			canCastSpell = false;
			isinSpellMode = true;

			player.disableMoveInput = true;
			spellCastTxt.acceptInput = true;

			spellCastTxt.curSpell = '';

			camGame.follow(null);
			var mid = plrHurtbox.getMidpoint();
			FlxTween.tween(camGame.scroll, {x: mid.x - FlxG.width * 0.5, y: mid.y - FlxG.height * 0.5}, 1, {ease: FlxEase.expoOut});

			FlxTween.num(FlxG.timeScale, 0.3, 1, {ease: FlxEase.expoOut}, (num) -> if (isinSpellMode) FlxG.timeScale = num);
			FlxTween.tween(camGame, {zoom: 1.5}, 1, {ease: FlxEase.expoOut});

			hud.spellTimeBar.scale.x = FlxG.width;
			FlxSpriteUtil.fadeIn(hud.spellTimeBar, 0.1);

			FlxTween.tween(hud.spellTimeBar.scale, {x: 1}, 1.2, {
				onComplete: (twn) ->
				{
					exitSpell();
				}
			});
		}

		if (FlxG.keys.justPressed.ENTER && isinSpellMode)
		{
			FlxTween.cancelTweensOf(camGame);
			FlxTween.cancelTweensOf(camGame.scroll);
			FlxTween.cancelTweensOf(hud.spellTimeBar.scale);
			exitSpell();
		}
	}

	private function exitSpell():Void
	{
		isinSpellMode = false;
		FlxG.timeScale = 1;
		new FlxTimer().start(.3, (tmr) -> canCastSpell = true);
		camGame.follow(plrHurtbox, LOCKON);
		spellCastTxt.resetText();
		player.disableMoveInput = spellCastTxt.acceptInput = false;

		FlxTween.tween(camGame, {zoom: 1}, .3, {ease: FlxEase.backInOut});
		FlxSpriteUtil.fadeOut(hud.spellTimeBar, 0.1);
		camGame.flash(0x10FFFFFF, 0.3);

		trace('FINAL SPELL: ${spellCastTxt.curSpell}');
		InvokeSpell(spellCastTxt.curSpell);
	}

	private function InvokeSpell(spell:String):Void
	{
		switch (spell.toUpperCase())
		{
			case 'KYS', 'KILLYOURSELF', 'DIE':
				trace('DIE!!!!');
				player.takeDamage(player.hp);
			case 'EXPLOSION':
				if (unlockedSpells[EXPLOSION] == false)
					return;
			case 'HEAL':
				if (unlockedSpells[HEAL] == false)
					return;
				PlayState.instance.player.heal(10);
			case 'POISON':
				if (unlockedSpells[POISON] == false)
					return;

				Projectile.activeEffects['poison'] = true;

				new FlxTimer().start(5, (tmr) ->
				{
					Projectile.activeEffects['poison'] = false;
				});
			case 'TELEPORT':
				// return; // probbb not for the jam. Too buggy.
				if (unlockedSpells[TELEPORT] == false || Projectile.activeEffects['teleport'])
					return;

				Projectile.activeEffects['teleport'] = true;

				new FlxTimer().start(5, (tmr) ->
				{
					Projectile.activeEffects['teleport'] = false;
				});
			case 'SPEEDBOOST':
				if (unlockedSpells[SPEED_BOOST] == false)
					return;
			case 'BURST':
				if (unlockedSpells[BURST] == false)
					return;
			case 'PIERCER':
				if (unlockedSpells[PIERCER] == false || Projectile.activeEffects['piercer'])
					return;

				Projectile.activeEffects['piercer'] = true;

				new FlxTimer().start(5, (tmr) ->
				{
					Projectile.activeEffects['piercer'] = false;
				});
			case 'BOUNCE':
				if (unlockedSpells[BOUNCE] == false || Projectile.activeEffects['bounce'])
					return;

				Projectile.activeEffects['bounce'] = true;

				new FlxTimer().start(5, (tmr) ->
				{
					Projectile.activeEffects['bounce'] = false;
				});
			case 'SONICSHOT':
				if (unlockedSpells[SONIC_SHOT] == false || Projectile.activeEffects['sonic_shot'])
					return;
				Projectile.activeEffects['sonic_shot'] = true;

				Projectile.speed *= 2;
				shootingCooldown = 0.1;

				new FlxTimer().start(5, (tmr) ->
				{
					Projectile.activeEffects['sonic_shot'] = false;
					Projectile.speed /= 2;
					shootingCooldown = 0.3;
				});

			case 'TWOXDMG':
				if (unlockedSpells[DOUBLE_DAMAGE] == false && Projectile.damageMultiplier == 1)
					return;

				Projectile.damageMultiplier = 2;

				new FlxTimer().start(5, (tmr) ->
				{
					Projectile.damageMultiplier = 1;
				});
			case 'TWOXDEF':
				if (unlockedSpells[DOUBLE_DEFENCE] == false && player.takeDamageMultiplier == 0.5)
					return;

				player.takeDamageMultiplier = 0.5;

				new FlxTimer().start(5, (tmr) ->
				{
					player.takeDamageMultiplier = 1;
				});
			#if debug
			case 'UNLOCKALL':
				for (spell in unlockedSpells.keys())
					unlockedSpells[spell] = true;

				trace(unlockedSpells);
			#end
			default:
				trace("SPELL DOESNT EXIST!!!");
		}
	}

	public function UnlockSpell(spell:SPELLS_ACTION)
	{
		if (spell == null)
			return;
		hud.triggerNewSpellBg(spell);
		unlockedSpells[spell] = true;
	}

	public function resetProgress():Void
	{
		for (spell in unlockedSpells.keys())
			unlockedSpells[spell] = false;
	}

	var canShoot:Bool = true;
	var shootingCooldown:Float = 0.3;

	private function HandleShooting():Void
	{
		if (FlxG.mouse.justPressed && canShoot && !isinSpellMode)
		{
			canShoot = false;
			var projSpawnPos:FlxPoint = new FlxPoint(plrHurtbox.getMidpoint().x - 25, plrHurtbox.getMidpoint().y);
			var projectile:Projectile = new Projectile(projSpawnPos, FlxG.mouse.getScreenPosition(camGame));

			projectileGrp.add(projectile);

			new FlxTimer().start(shootingCooldown, (tmr) -> canShoot = true);
		}
	}

	private function HandleMusicStuff(elapsed:Float):Void
	{
		// redirect the time to the normal one in cae

		if (isInCombat)
		{
			calmMusic.volume -= elapsed;
			combatMusic.volume += elapsed;
		}
		else
		{
			calmMusic.volume += elapsed;
			combatMusic.volume -= elapsed;
		}
	}

	private function addTileProprieties(tilemap:FlxTilemap):Void
	{
		tilemap.setTileProperties(1, NONE);
		tilemap.setTileProperties(8, NONE);
		tilemap.setTileProperties(9, NONE);
		tilemap.setTileProperties(10, NONE);
		tilemap.setTileProperties(11, NONE);
		tilemap.setTileProperties(12, NONE);
		tilemap.setTileProperties(16, NONE);
		tilemap.setTileProperties(17, ANY); // INVISIBLE TO THE PLAYER!!
		tilemap.setTileProperties(18, NONE);
		tilemap.setTileProperties(19, NONE);
		tilemap.setTileProperties(20, NONE);
		tilemap.setTileProperties(24, NONE);
		tilemap.setTileProperties(25, NONE);
		tilemap.setTileProperties(26, NONE);

		tilemap.setTileProperties(13, ANY);
		tilemap.setTileProperties(14, ANY);
		tilemap.setTileProperties(15, ANY);
		tilemap.setTileProperties(21, ANY);
		tilemap.setTileProperties(22, ANY);
		tilemap.setTileProperties(23, ANY);
		tilemap.setTileProperties(29, ANY);
		tilemap.setTileProperties(30, ANY);
		tilemap.setTileProperties(31, ANY);
	}
}
