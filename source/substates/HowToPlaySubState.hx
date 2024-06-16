package substates;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.text.FlxText;

using StringTools;

class HowToPlaySubState extends FlxSubState
{
	var header:FlxText;

	final instructionText:String = 'Move with WASD or the arrow keys.
    To cast a spell, press CONTROL or SHIFT.
    While casting a spell, you have to type the spells name in order to invoke it.
    Spells can be found around the levels. Make sure you remember the names!
    (We ran out of time and couldnt make a menu for that lol)
    To finish a level, find and kill all the enemies, then find and enter the portal.
    Have fun! (We hope)';

	public function new():Void
	{
		super(0xFF000000);

		header = new FlxText(0, 25, FlxG.width, '-HOW TO PLAY-');
		header.setFormat('assets/fonts/Hello Roti.otf', 64, 0xFFFFFFFF, CENTER);

		for (i in 0...instructionText.split('\n').length)
		{
			var _instruction = new FlxText(0, 150 + 70 * i, FlxG.width, instructionText.split('\n')[i]);
			_instruction.setFormat('assets/fonts/Hello Roti.otf', 32, 0xFFFFFFFF, CENTER);
			add(_instruction);
		}
		add(header);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ANY)
			close();
	}
}
