package states;

import components.HUD;
import components.IEnemy;
import components.IKillable;
import components.SpellCastText;
import entities.Ghoul;
import entities.Player;
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

	var camGame:FlxCamera;
	var camHud:FlxCamera;

	var hud:HUD;

	public var player:Player;
	public var plrHurtbox:FlxObject;

	var spellCastTxt:SpellCastText;
	var crosshair:FlxSprite;

	var prefabLoader:FlxOgmo3Loader;
	var prefabLoaders:Map<String, FlxOgmo3Loader> = [];

	public var prefabGrp:FlxTypedGroup<FlxTilemap>;

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
		var map:Map<String, FlxOgmo3Loader> = [];

		var otiles = Assets.list(TEXT).filter((_) -> StringTools.contains(_, "data/lv_prefabs/"));

		for (tile in otiles)
		{
			map.set(haxe.io.Path.withoutDirectory(haxe.io.Path.withoutExtension(tile)),
				new FlxOgmo3Loader('assets/data/SpellbookDungeon.ogmo', 'assets/data/lv_prefabs/start.json'));
		}

		prefabLoaders = map;

		prefabLoader = map["start"];
		var tilemap:FlxTilemap = prefabLoader.loadTilemap('assets/images/tileset.png', 'Level');

		prefabLoader.loadEntities(function(_) {}, "Entities");

		prefabGrp = new FlxTypedGroup<FlxTilemap>();
		prefabGrp.add(tilemap);

		for (prefab in prefabGrp.members)
			addTileProprieties(prefab); // read the func comment, vic

		//------[LE SOUND]------\\

		baseMusic = new FlxSound().loadEmbedded('assets/music/base.ogg', true);
		FlxG.sound.list.add(baseMusic);
		baseMusic.volume = .3;
		baseMusic.play();

		calmMusic = new FlxSound().loadEmbedded('assets/music/calm_mode.ogg', true);
		FlxG.sound.list.add(calmMusic);
		calmMusic.volume = 0;
		calmMusic.play();

		combatMusic = new FlxSound().loadEmbedded('assets/music/combat_mode.ogg', true);
		FlxG.sound.list.add(combatMusic);
		combatMusic.volume = 0;
		combatMusic.play();

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

		var ghoul = new Ghoul();
		ghoul.screenCenter();
		ghoul.y -= 500;
		enemyGrp.add(ghoul);

		final gridGraphic = FlxGridOverlay.createGrid(64, 64, 128, 128, true, 0xFF0E0E0E, 0xFF222222);
		var bg = new FlxBackdrop(gridGraphic, XY);
		bg.scrollFactor.set(.3, .3);
		bg.velocity.set(15, 15);
		bg.color = 0xFF393939;

		//-----[Layering]-----\\
		add(bg);
		add(prefabGrp);

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

		camGame.bgColor = 0xFF353535;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.collide(player, prefabGrp);
		FlxG.collide(enemyGrp, prefabGrp);

		camGame.followLerp = 5 * elapsed;
		plrHurtbox.setPosition(player.x + 15, player.y - 125);

		// THIS IS BAD. I HATE THIS. CHEEM. HELP. CHEEEEM. CHEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEM
		// *superman pose gif meme with Starman by David Bowie playing in the background* - Cheems
		camGame.setScrollBoundsRect(plrHurtbox.x - FlxG.width * 0.5, plrHurtbox.y - FlxG.height * 0.5, FlxG.width * 2, FlxG.height * 2, true);
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
			case 'EXPLOSION':
				if (unlockedSpells[EXPLOSION] == false)
					return;
			case 'HEAL':
				if (unlockedSpells[HEAL] == false)
					return;
				trace('gain sum more hp hehe');
			case 'POISON':
				if (unlockedSpells[POISON] == false)
					return;
			case 'TELEPORT':
				if (unlockedSpells[TELEPORT] == false)
					return;
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
				if (unlockedSpells[DOUBLE_DAMAGE] == false)
					return;
			case 'TWOXDEF':
				if (unlockedSpells[DOUBLE_DEFENCE] == false)
					return;
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
		for (spell in unlockedSpells)
		{
			spell = false;
		}
	}

	var canShoot:Bool = true;
	var shootingCooldown:Float = 0.3;

	private function HandleShooting():Void
	{
		if (FlxG.mouse.justPressed && canShoot && !isinSpellMode)
		{
			canShoot = false;
			var projSpawnPos:FlxPoint = new FlxPoint(plrHurtbox.getMidpoint().x, plrHurtbox.getMidpoint().y);
			var projectile:Projectile = new Projectile(projSpawnPos, FlxG.mouse.getScreenPosition(camGame));

			projectileGrp.add(projectile);

			new FlxTimer().start(shootingCooldown, (tmr) -> canShoot = true);
		}
	}

	private function HandleMusicStuff(elapsed:Float):Void
	{
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

	// VIC! Read this: Im guessing since we'll have multiple tilemaps, we still need to
	// add tile proprieties to each one of them. So just use this function on every one of them-
	// oooor if you have a better idea, be my guest! As long as it makes ur job easier...
	private function addTileProprieties(tilemap:FlxTilemap):Void
	{
		tilemap.setTileProperties(1, NONE);
		tilemap.setTileProperties(3, ANY);
		tilemap.setTileProperties(4, ANY);
		tilemap.setTileProperties(5, ANY);
		tilemap.setTileProperties(11, ANY);
		tilemap.setTileProperties(12, ANY);
		tilemap.setTileProperties(13, ANY);

		tilemap.setTileProperties(8, NONE);
		tilemap.setTileProperties(9, NONE);
		tilemap.setTileProperties(10, NONE);
		tilemap.setTileProperties(16, NONE);
		tilemap.setTileProperties(17, ANY); // INVISIBLE TO THE PLAYER!!
		tilemap.setTileProperties(18, NONE);
		tilemap.setTileProperties(24, NONE);
		tilemap.setTileProperties(25, NONE);
		tilemap.setTileProperties(26, NONE);
	}
}
