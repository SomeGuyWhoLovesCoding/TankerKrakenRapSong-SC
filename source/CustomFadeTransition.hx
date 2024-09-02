package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	var transitionSpr:FlxSprite;

	public function new(duration:Float, isTransIn:Bool) {
		super();

		this.isTransIn = isTransIn;
		transitionSpr = new FlxSprite(0, -FlxG.height).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		transitionSpr.scrollFactor.set();
		add(transitionSpr);

		if(isTransIn) {
			transitionSpr.y = 0;
			FlxTween.tween(transitionSpr, {y: FlxG.height}, duration, {
				onComplete: function(twn:FlxTween) {
					close();
				},
			ease: FlxEase.expoOut});
		} else {
			leTween = FlxTween.tween(transitionSpr, {y: 0}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						finishCallback();
					}
				},
			ease: FlxEase.expoOut});
		}

		if(nextCamera != null) transitionSpr.cameras = [nextCamera];
		nextCamera = null;
	}

	override function destroy() {
		if(leTween != null) {
			finishCallback();
			leTween.cancel();
		}
		super.destroy();
	}
}

/* OLD CODE
package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transitionSpr:FlxSprite;

	public function new(duration:Float, isTransIn:Bool) {
		super();

		this.isTransIn = isTransIn;
		var zoom:Float = CoolUtil.boundTo(FlxG.camera.zoom, 0.05, 1);
		var width:Int = Std.int(FlxG.width / zoom);
		var height:Int = Std.int(FlxG.height / zoom);
		transitionSpr = FlxGradient.createGradientFlxSprite(width, height, [0xFF000000, 0xFF000000]);
		transitionSpr.scrollFactor.set();
		add(transitionSpr);

		transBlack = new FlxSprite().makeGraphic(width, height, 0xFF000000);
		transBlack.scrollFactor.set();
		add(transBlack);

		transitionSpr.x -= (width - FlxG.width) / 2;
		transBlack.x = transitionSpr.x;

		if(isTransIn) {
			transitionSpr.y = 0 - height;
			FlxTween.tween(transitionSpr, {y: 0}, duration, {
				onComplete: function(twn:FlxTween) {
					close();
				},
			ease: FlxEase.expoOut});
		} else {
			transBlack.y = transitionSpr.y - transBlack.height;
			leTween = FlxTween.tween(transitionSpr, {y: height}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						finishCallback();
					}
				},
			ease: FlxEase.expoInOut});
		}

		if(nextCamera != null) {
			transBlack.cameras = [nextCamera];
			transitionSpr.cameras = [nextCamera];
		}
		nextCamera = null;
	}

	override function update(elapsed:Float) {
		if(isTransIn) {
			transBlack.y = 0 - height;
		} else {
			transBlack.y = transitionSpr.y + transBlack.height;
		}
		super.update(elapsed);
		if(isTransIn) {
			transBlack.y = transitionSpr.y + transitionSpr.height;
		} else {
			transBlack.y = transitionSpr.y - transBlack.height;
		}
	}

	override function destroy() {
		if(leTween != null) {
			finishCallback();
			leTween.cancel();
		}
		super.destroy();
	}
} */