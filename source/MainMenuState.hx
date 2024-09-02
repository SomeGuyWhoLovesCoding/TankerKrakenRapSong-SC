package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.3'; // moment
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'play',
		'freeplay',
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'options'
	];

	var magenta:FlxSprite;
	var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 0.75));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 0.75));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 40 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 175)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 16);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 16);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			var time = Date.now();
			if (time.getHours() >= 16 || time.getHours() <= 6) {
				menuItem.color = 0x66666666;
				bg.loadGraphic(Paths.image('menuBG_night'));
			} else {
				menuItem.color = FlxColor.fromHSB(255, 0, 125);
			}
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		/*var versionShit:FlxText = new FlxText(4, FlxG.height - 64, 0, "Tanker Kraken's Rap Song [V1]", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(4, FlxG.height - 44, 0, "Psych Engine [v" + psychEngineVersion + "]", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(4, FlxG.height - 24, 0, "Friday Night Funkin' [v" + Application.current.meta.get('version') + "]", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);*/

		changeItem();
		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		Application.current.window.title = "Tanker's Rap Song";
		FlxWindow.tankerKrakenWindow(); // TANKER KRAKEN COLOOOOOOOR!!!

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				FlxG.sound.music.fadeIn(2, 1, 0);
				FlxG.camera.flash(FlxColor.WHITE, 0.25);
				if (optionShit[curSelected] == 'donate') {
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				} else {
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('play'));

					FlxG.camera.flash(FlxColor.WHITE, 0.75);
					bg.x = 2000;

					menuItems.forEach(function(spr:FlxSprite)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.00001, {
							ease: FlxEase.expoOut,
							onComplete: function(twn:FlxTween) {
								spr.kill();
							}
						});
						var daChoice:String = optionShit[curSelected];

						new FlxTimer().start(3.5, function(tmr:FlxTimer)
						{
							switch (daChoice)
							{
								case 'play':
									//MusicBeatState.switchState(new cutscenes.Cutscene1State());
									MusicBeatState.switchState(new StoryMenuState());
								
									PlayState.SONG = Song.loadFromJson('car-tires', 'car-tires');
									PlayState.campaignScore = 0;
									PlayState.campaignMisses = 0;
								new FlxTimer().start(1.8, function(tmr:FlxTimer)
								{
									LoadingState.loadAndSwitchState(new PlayState(), true);
									FreeplayState.destroyFreeplayVocals();
								});
								
								case 'freeplay':
									MusicBeatState.switchState(new FreeplayCategoryState());
								#if MODS_ALLOWED
								case 'mods':
									MusicBeatState.switchState(new ModsMenuState());
								#end
								case 'awards':
									MusicBeatState.switchState(new AchievementsMenuState());
								case 'credits':
									MusicBeatState.switchState(new CreditsState());
								case 'options':
									LoadingState.loadAndSwitchState(new options.OptionsState());
							}
						});
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys)) {
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end

			if (FlxG.keys.justPressed.SEVEN) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new Shop());
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
