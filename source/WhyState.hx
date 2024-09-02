package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.ui.FlxButton;

class WhyState extends MusicBeatState
{
	public static var leftState:Bool = false;

	public var warnText:FlxText;

	override function create()
	{
		warnText = new FlxText(0, 0, FlxG.width,
			"I'M SORRY! You need to enable tanker kraken window in
			order to play the game properly.
			
			DO NOT BYPASS THIS, OR YOUR GAME WILL CRASH.", 24);
		warnText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter();
		add(warnText);

		super.create();

		// Sounds
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.sound('error'), 3);
		FlxG.camera.shake(0.0125, 0.325);
	}

	override function update(elapsed:Float)
	{
		Application.current.window.title = "Tanker Kraken's Rap Song - STOP PLAYING";
		if(!leftState) {
			leftState = true;
			FlxG.save.data.tankerKrakenCompleted = false;
		}

		// What actually happens if you hold enter and space until you get teleported to 4149

		if (FlxG.keys.justPressed.ENTER && FlxG.keys.pressed.SPACE) {
			FlxG.sound.play(Paths.sound('error'), 3);
			if (FlxG.keys.justPressed.ENTER && FlxG.keys.pressed.SPACE) {
				if (FlxG.keys.justPressed.ENTER && FlxG.keys.pressed.SPACE) {
					if (FlxG.keys.justPressed.ENTER && FlxG.keys.pressed.SPACE) {
						if (FlxG.keys.justPressed.ENTER && FlxG.keys.pressed.SPACE) {
							if (FlxG.keys.justPressed.ENTER && FlxG.keys.pressed.SPACE) {
								if (FlxG.keys.justPressed.ENTER && FlxG.keys.pressed.SPACE) {
									if (FlxG.keys.justPressed.ENTER && FlxG.keys.pressed.SPACE) {
										if (FlxG.keys.justPressed.ENTER && FlxG.keys.pressed.ALT) {
											if (FlxG.keys.justPressed.ALT && FlxG.keys.pressed.SPACE) {
												PlayState.SONG = Song.loadFromJson('4149', '4149');
												PlayState.campaignScore = 0;
												PlayState.campaignMisses = 0;
												new FlxTimer().start(0, function(tmr:FlxTimer)
												{
													LoadingState.loadAndSwitchState(new PlayState(), true);
													FreeplayState.destroyFreeplayVocals();
												});
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}

		super.update(elapsed);
	}
}