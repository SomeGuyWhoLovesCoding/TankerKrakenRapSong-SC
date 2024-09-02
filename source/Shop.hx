package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.graphics.FlxGraphic;

class Shop extends MusicBeatState
{
	public static var shopItems:Array<String> = [
		"cereal",
		"microphone",
		"bronze microphone",
		"silver microphone",
		"gold microphone",
		"platinum microphone"
	];

	public static var shopItemsCost:Array<Float> = [1.00, 15.00, 100.00, 200.00, 500.00, 1000.00, 5000.00];

	public static var curSelected:Int = 0;

	// Beta BG
	public var bg_BETA:FlxSprite;

	public static var unlockedItems:Array<String> = ["I don't care"]; //shopItems.length;

	static var text:FlxText;
	static var moneyTxt:FlxText;

	static var collectedItems:Array<Bool> = [];

	override function create() {
		collectedItems = FlxG.save.data.collectedItems;
		shopItems = ["cereal", "microphone"];

		FlxG.save.data.collectedItems = [true, true];
		FlxG.mouse.visible = true;

		bg_BETA = new FlxSprite().loadGraphic(Paths.image('shop/menuBG'));
		//bg_BETA.visible = false;
		add(bg_BETA);

		var bgDay:FlxSprite = new FlxSprite().loadGraphic(Paths.image('shop/menuBG-day'));
		bgDay.visible = false;
		add(bgDay);
		var bgNoon = new FlxSprite().loadGraphic(Paths.image('shop/menuBG-noon'));
		bgNoon.visible = false;
		add(bgNoon);
		var bgEvening = new FlxSprite().loadGraphic(Paths.image('shop/menuBG-evening'));
		bgEvening.visible = false;
		add(bgEvening);
		var bgNight = new FlxSprite().loadGraphic(Paths.image('shop/menuBG-night'));
		bgNight.visible = false;
		add(bgNight);
		var bgClosed = new FlxSprite().loadGraphic(Paths.image('shop/menuBG-closed'));
		bgClosed.visible = false;
		add(bgClosed);

		super.create();

		FlxG.sound.playMusic(Paths.music('breakfast'), 0.75);

		text = new FlxText(0, FlxG.height - 72, FlxG.width, "Welcome to my shop! How can I help you?", 24);
		text.setFormat(Paths.font("cinemaTxt.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.borderSize = 1;
		text.screenCenter(X);
		moneyTxt = new FlxText(-4, -8, FlxG.width, '', 42);
		moneyTxt.setFormat(Paths.font("cinemaTxt.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		moneyTxt.borderSize = 1;

		add(text);
		add(moneyTxt);

		var time = Date.now();
		/*if (time.getHours() > 8 || time.getHours() < 12) {
			text.text = "Welcome to my shop! How can I help you today?";
			bgDay.visible = true;
		} else {
			text.text = "Welcome to my shop! How can I help you?";
		}
		if (time.getHours() > 12 || time.getHours() < 16) {
			text.text = "Welcome to my shop! How can I help you this afternoon?";
			bgNoon.visible = true;
		} else {
			text.text = "Welcome to my shop! How can I help you?";
		}
		if (time.getHours() > 16 || time.getHours() < 20) {
			text.text = "Welcome to my shop! How can I help you this evening?";
			bgEvening.visible = true;
		} else {
			text.text = "Welcome to my shop! How can I help you?";
		}
		if (time.getHours() > 20 || time.getHours() < 0) {
			text.text = "Welcome to my shop! How can I help you tonight?";
			bgNight.visible = true;
		} else {
			text.text = "Welcome to my shop! How can I help you?";
		}
		if (time.getHours() < 8) {
			text.text = "The shop is closed at this time. it is " + time.getHours() + ".
			I am tired today.";
			bgClosed.visible = true;
		} else {
			text.text = "Welcome to my shop! How can I help you?";
		}*/

		var day:String = "NAD";
		if (time.getDay() == 0) day = "Sunday";
		if (time.getDay() == 1) day = "Monday";
		if (time.getDay() == 2) day = "Tuesday";
		if (time.getDay() == 3) day = "Wednesday";
		if (time.getDay() == 4) day = "Thursday";
		if (time.getDay() == 5) day = "Friday";
		if (time.getDay() == 6) day = "Saturday";

		if (time.getDay() > 5 || time.getDay() < 1) {
			text.text = "Sorry, I'm not open at this time. It's currently " + day + ".";
			add(bgClosed);
		}

		moneyTxt.text = text.text != "Sorry, I'm not open at this time. It's currently " + day + "." && text.text != "The shop is closed at this time. it is " +
			time.getHours() + "." ? '$' + FlxG.save.data.money : 'CLOSED!';

		// Unlocked Items
		if (FlxG.save.data.bronzeMicUnlocked ||
			!FlxG.save.data.silverMicUnlocked ||
			!FlxG.save.data.goldMicUnlocked ||
			!FlxG.save.data.platinumMicUnlocked) {
			shopItems = [
				"cereal",
				"microphone",
				"bronze microphone"
			];
			FlxG.save.data.collectedItems = [true, true, true];
		} else if (FlxG.save.data.bronzeMicUnlocked ||
			FlxG.save.data.silverMicUnlocked ||
			!FlxG.save.data.goldMicUnlocked ||
			!FlxG.save.data.platinumMicUnlocked) {
			shopItems = [
				"cereal",
				"microphone",
				"bronze microphone",
				"silver microphone"
			];
			FlxG.save.data.collectedItems = [true, true, true, true];
		} else if (FlxG.save.data.bronzeMicUnlocked ||
			FlxG.save.data.silverMicUnlocked ||
			FlxG.save.data.goldMicUnlocked ||
			!FlxG.save.data.platinumMicUnlocked) {
			shopItems = [
				"cereal",
				"microphone",
				"bronze microphone",
				"silver microphone",
				"gold microphone"
			];
			FlxG.save.data.collectedItems = [true, true, true, true, true];
		} else if (FlxG.save.data.bronzeMicUnlocked ||
			FlxG.save.data.silverMicUnlocked ||
			FlxG.save.data.goldMicUnlocked ||
			FlxG.save.data.platinumMicUnlocked) {
			shopItems = [
				"cereal",
				"microphone",
				"bronze microphone",
				"silver microphone",
				"gold microphone",
				"platinum microphone"
			];
			FlxG.save.data.collectedItems = [true, true, true, true, true, true];
		}
	}

	// Spend money
	function spend(cost:Float) {
		var time = Date.now();
		var day:String = "NAD";
		if (FlxG.save.data.money < shopItemsCost[curSelected] && collectedItems.contains(false)
			&& !shopItems.contains('') && !unlockedItems.contains('')) {
			FlxG.save.data.money -= cost;
			moneyTxt.text = text.text != "Sorry, I'm not open at this time. It's currently " + day + "." && text.text != "The shop is closed at this time. it is " +
				time.getHours() + "." ? '$' + FlxG.save.data.money : 'CLOSED!';
		} else {
			FlxG.sound.play(Paths.sound("shopError"), 1);
			FlxG.camera.shake(0.01, 0.05, function() {
				return;
			});
		}
		if (collectedItems.contains(true)) {
			return;
		}
		if (shopItems.contains('')) return;
		if (unlockedItems.contains('')) return;
	}

	function resetCount() {
		var time = Date.now();
		var day:String = "Nad";
		FlxG.save.data.money = 0.0;
		moneyTxt.text = text.text != "Sorry, I'm not open at this time. It's currently " + day + "." && text.text != "The shop is closed at this time. it is " +
			time.getHours() + "." ? '$' + FlxG.save.data.money : 'CLOSED!';
	}

	// Earn money (For after the week ends)
	function earn(cost:Float) {
		var time = Date.now();
		var day:String = "Nad";
		FlxG.save.data.money += cost;
		moneyTxt.text = text.text != "Sorry, I'm not open at this time. It's currently " + day + "." && text.text != "The shop is closed at this time. it is " +
			time.getHours() + "." ? '$' + FlxG.save.data.money : 'CLOSED!';
	}

	override function update(e:Float) {
		var tg1:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 0, 0xFF777777);
		var tg2:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 0, 0xFFFFFFFF);
		add(tg1);
		add(tg2);

		// Movement
		var time = Date.now();

		var shopItem:FlxSprite = new FlxSprite().loadGraphic(Paths.image("shop/items/1"));
		add(shopItem);

		var day:String = "Nad";
		if (FlxG.mouse.justPressed && text.text != "Sorry, I'm not open at this time. It's currently " + day + "."
			&& text.text != "The shop is closed at this time. it is " + time.getHours() + ".") {
			if (FlxG.mouse.x > shopItem.x
			&& FlxG.mouse.x < shopItem.x + shopItem.width
			&& FlxG.mouse.y > shopItem.y
			&& FlxG.mouse.y < shopItem.y + shopItem.height) {
				spend(shopItemsCost[curSelected]);
			}
			if (FlxG.keys.justPressed.LEFT) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				curSelected--;
			}

			if (FlxG.keys.justPressed.RIGHT) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				curSelected++;
			}
		}

		if (curSelected > shopItems.length-1) curSelected = shopItems.length-1;
			if (curSelected < 1) curSelected = 1;

		// Back
		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxTween.tween(tg1, {y: 0, height: FlxG.width}, 0.75, {ease: FlxEase.expoOut});
			FlxTween.tween(tg2, {y: 0, height: FlxG.width}, 0.75, {ease: FlxEase.expoOut, startDelay: 0.05});
			new FlxTimer().start(0.1, function(tmr:FlxTimer) {
				MusicBeatState.switchState(new MainMenuState());
				FlxG.mouse.visible = false;
			});
		}

		if (FlxG.keys.justPressed.A) earn(0.01);

		// Reset
		if (controls.RESET) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			resetCount();
		}
	}
}