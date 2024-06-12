package states;

import components.HUD;
import components.SpellCastText;
import entities.Player;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import objects.SpellBook;

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
	var crosshairLine:FlxSprite;

	private var bg:FlxBackdrop;

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
		FlxCamera.defaultCameras = [camGame];
		FlxG.cameras.add(camHud);

		camHud.bgColor.alpha = 0;
		//--------------------\\
		hud = new HUD();
		hud.cameras = [camHud];

		player = new Player();
		player.screenCenter();

		plrHurtbox = new FlxObject(player.x, player.y, 50, 125);

		spellCastTxt = new SpellCastText();

		crosshairLine = new FlxSprite();
		crosshairLine.makeGraphic(FlxG.width, FlxG.height, 0, true);
		crosshairLine.antialiasing = true;

		crosshair = new FlxSprite('assets/images/crosshair.png');
		crosshair.antialiasing = true;
		crosshair.scale.set(.8, .8);
		crosshair.updateHitbox();
		crosshair.setPosition(FlxG.mouse.getWorldPosition(camGame).x, FlxG.mouse.getWorldPosition(camGame).y);

		final gridGraphic = FlxGridOverlay.createGrid(64, 64, 128, 128, true, 0xFF0E0E0E, 0xFF222222);
		bg = new FlxBackdrop(gridGraphic, XY);
		bg.scrollFactor.set(.3, .3);
		bg.velocity.set(15, 15);
		bg.color = 0xFF393939;

		//-----[Layering]-----\\
		add(bg);
		add(new FlxSprite(FlxG.width / 2, FlxG.height / 2, 'assets/images/poorCheem.png'));
		// add(crosshairLine); pretty broken sorry
		add(new SpellBook(HEAL));

		add(player);
		add(plrHurtbox);

		add(spellCastTxt);
		add(crosshair);

		// hud stuff
		add(hud);
		//---------------------\\
		camGame.follow(plrHurtbox, TOPDOWN, 1);
		super.create();

		camGame.bgColor = 0xFF353535;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		camGame.followLerp = 5 * elapsed;
		plrHurtbox.setPosition(player.x + 15, player.y - 125);

		spellCastTxt.setPosition(player.x + player.width / 2, player.y - 200);

		HandleCrosshair(elapsed);
		HandleSpellCasting(elapsed);
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

		FlxSpriteUtil.fill(crosshairLine, 0);

		FlxSpriteUtil.drawLine(crosshairLine, player.getScreenPosition().x
			+ player.width / 2, player.getScreenPosition().y
			+ player.height / 2,
			crosshair.x
			+ crosshair.origin.x, crosshair.y
			+ crosshair.origin.y, {
				thickness: 3,
				color: 0xFF872341
			});

		crosshairLine.setPosition(camGame.scroll.x, camGame.scroll.y);
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
			FlxTween.tween(camGame.scroll,
				{x: plrHurtbox.x + plrHurtbox.width / 2 - FlxG.width / 2, y: plrHurtbox.y + plrHurtbox.height / 2 - FlxG.height / 2}, 1,
				{ease: FlxEase.expoOut});

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
		new FlxTimer().start(1, (tmr) -> canCastSpell = true);
		camGame.follow(plrHurtbox, TOPDOWN);
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
				if (unlockedSpells[PIERCER] == false)
					return;
			case 'BOUNCE':
				if (unlockedSpells[BOUNCE] == false)
					return;
			case 'SONICSHOT':
				if (unlockedSpells[SONIC_SHOT] == false)
					return;
			case 'TWOXDMG':
				if (unlockedSpells[DOUBLE_DAMAGE] == false)
					return;
			case 'TWOXDEF':
				if (unlockedSpells[DOUBLE_DEFENCE] == false)
					return;
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
}
