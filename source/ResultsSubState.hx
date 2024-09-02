package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;

class ResultsSubState extends MusicBeatSubstate
{
	//var moneyEarned:Float = PlayState.campaignScore/Highscore.floorDecimal(PlayState.accuracy * 100,2)/PlayState.campaignMisses;
	override public function create() {
		// MUSIC AND SOUNDS
		FlxG.sound.playMusic(Paths.music('Results \'115'), 0);
		FlxG.sound.play(Paths.sound('confirmMenuTankerKraken'), 0.75);
		FlxG.sound.music.fadeIn(10, 0, 0.32);
		
		// Sets a list of lines depending on how good you did so far.
		var tone:Array<String> = [
			"*sigh* Man, could you\ndo better than that!?",
			"Boo hoo, LOSER!\nDo better next time!",
			"You could get a better\nrank than that...",
			"Okay",
			"Not bad",
			"Nice.",
			"Good.",
			"Great.",
			"Cool!",
			"SICK!!",
			"PERFECT!!!"
		];

		var accuracy:Float = Highscore.floorDecimal(PlayState.accuracy * 100,2);
		trace(/*"You got: " + */accuracy+"%");

		var toneTxt:FlxText = new FlxText(105, Std.int(FlxG.height / 2.75), 0, '' + tone[Std.int(accuracy/10)].toUpperCase(), 64);
		toneTxt.alpha = 0;
		toneTxt.scrollFactor.set();
		toneTxt.setFormat(Paths.font('cinemaTxt.ttf'), 64);
		toneTxt.updateHitbox();
		add(toneTxt);

		var infoTxt:FlxText = new FlxText(105, toneTxt.y + 72, 0, PlayState.accuracy != 0 || PlayState.campaignScore != 0 && PlayState.campaignMisses != 0 ? 'Your Rankings:
		Total Score: ' + PlayState.campaignScore
		+ '
		Total Misses: ' + PlayState.campaignMisses
		//+ '
		//Accuracy: $accuracy%
		//\nEarned: $' + Highscore.floorDecimal(moneyEarned,2)
		: 'Your Rankings:
		Accuracy: $accuracy%', 32);
		infoTxt.alpha = 0;
		infoTxt.scrollFactor.set();
		infoTxt.setFormat(Paths.font('cinemaTxt.ttf'), 32);
		infoTxt.updateHitbox();
		add(infoTxt);

		super.create();

		FlxTween.tween(toneTxt, {x: toneTxt.x - 65, alpha: 1}, 1, {ease: FlxEase.expoOut});
		FlxTween.tween(infoTxt, {x: infoTxt.x - 65, alpha: 1}, 1, {ease: FlxEase.expoOut, startDelay: 0.1});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		toneTxt.color = 0x00FFFF;

		// Winnin' the money
		/*if (PlayState.accuracy < 0) moneyEarned = 0;
		if (PlayState.campaignScore < 0) moneyEarned = 0;
		if (PlayState.campaignScore < 0 && PlayState.accuracy < 0) 0;
		if (PlayState.campaignMisses < 0 && PlayState.campaignScore < 0) 0;
		if (PlayState.campaignMisses < 0 && PlayState.accuracy < 0) 0;
		if (PlayState.campaignMisses < 0) moneyEarned = 0;
		FlxG.save.data.money += moneyEarned;*/
	}

	override function update(elapsed:Float) {
		if (controls.ACCEPT) {
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			WeekData.loadTheFirstEnabledMod();
			MusicBeatState.switchState(new MainMenuState());
			PlayState.cancelMusicFadeTween();
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.changedDifficulty = false;
			PlayState.chartingMode = false;
		}

		// Taken from PlayState
		FlxG.camera.zoom = FlxMath.lerp(1.05, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
	}

	override public function beatHit() {
		if (curBeat % 4 == 0) FlxG.camera.zoom += 0.05;
	}
}
