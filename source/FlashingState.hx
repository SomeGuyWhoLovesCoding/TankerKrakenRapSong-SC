package;

import flash.display.BlendMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.ui.FlxButton;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	var noticeBox:FlxSprite;

	override function create()
	{
		super.create();
		
		warnText = new FlxText(0, 0, FlxG.width,
			"Please Note!\nThis mod has loud sounds, flashing lights, and gore.\n4149 and Demilune may have bugs.\nProceed?", 24);
		warnText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	function sure()
	{
		ClientPrefs.flashing = false;
		FlxG.save.data.flashing = false;
		FlxG.save.data.newGame = false;
		ClientPrefs.saveSettings();
		FlxG.sound.play(Paths.sound('confirmMenu'), 3);
		FlxTween.tween(warnText, {y: warnText.y + 15, alpha: 0}, 1.1, {ease: FlxEase.quadOut, 
			onComplete: function (twn:FlxTween) {
				MusicBeatState.switchState(new TitleState());
			}
		});
	}

	override function update(elapsed:Float)
	{
		Application.current.window.title = "Tanker's Rap Song: Notice";
		FlxG.mouse.useSystemCursor = true;
		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if(!back) {
					sure();
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxG.save.data.newGame = false;
					FlxTween.tween(warnText, {alpha: 0}, 0.65, {ease: FlxEase.quadOut, 
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
				}
			}
		}
		super.update(elapsed);
	}
}