package;

import flixel.addons.util.FlxAsyncLoop;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.utils.AssetCache;
import openfl.utils.IAssetCache;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

//import Cache.PostCache;

/**
 * FlxAsyncLoop : https://github.com/HaxeFlixel/flixel-demos/blob/dev/Other/FlxAsyncLoop/source/MenuState.hx
 */

class LoadingSubState extends FlxState
{
	var bg:FlxSprite;
	var progress:FlxGroup;
	var finished:FlxGroup;
	var loop:FlxAsyncLoop;
	var bytes:Int = 100;
	var loadingBar:FlxBar;
	var loadingBarText:FlxText;

	public var imagesArray = [
		"shared:assets/shared/images/characters/BOYFRIEND.png",
		"shared:assets/shared/images/characters/BOYFRIEND.xml",
		"shared:assets/shared/images/characters/BOYFRIEND_REMIX.png",
		"shared:assets/shared/images/characters/BOYFRIEND_REMIX.xml",
		"shared:assets/shared/images/characters/TANKER.png",
		"shared:assets/shared/images/characters/TANKER.xml",
		"shared:assets/shared/images/characters/TANKER_OG.png",
		"shared:assets/shared/images/characters/TANKER_OG.xml",
		"assets/weekTanker/images/bg/City-Streets.png",
		"assets/weekTanker/images/bg/Music-Contest-Podium.png",
		"assets/weekTanker/images/bg/Stadium-front.png",
		"assets/weekTanker/images/bg/Stadium-back.png",
		"assets/weekTanker/images/bg/Jail.png",
		"assets/weekTanker/images/bg/Volcano.png",
		"assets/weekTanker/images/bg/Stage-Tanker-Entertainment.png",
		"assets/weekTanker/images/bg/Stage-OG.png",
		"assets/weekTanker/images/bg/Stage-Gold.png",
		"assets/weekTanker/images/bg/Stage-Base.png",
		"assets/weekTanker/images/cop-1.png",
		"assets/weekTanker/images/cop-1.xml",
		"assets/weekTanker/images/cop-2.png",
		"assets/weekTanker/images/cop-2.xml",
		"assets/weekTanker/images/cop-1.png"
	];

	static var count:Int = -1;

	override public function create():Void {
		bg = new FlxSprite().loadGraphic(Paths.image('loadingBG'));
		add(bg);

		Assets.cache.enabled = true;
		//Cache.instance.startCaching();
		
		progress = new FlxGroup();
		finished = new FlxGroup(bytes);

		loop = new FlxAsyncLoop(bytes, updateBytes, 1);

		loadingBar = new FlxBar(0, FlxG.height - 50, LEFT_TO_RIGHT, FlxG.width - 25, 25, null, "", 0, bytes, true);
		loadingBar.value = 0;
		loadingBar.screenCenter(X);
		progress.add(loadingBar);

		loadingBarText = new FlxText(0, FlxG.height - 50, FlxG.width, "Loading... (0% / " + bytes + "%)");
		loadingBarText.setFormat(null, 24, FlxColor.WHITE, CENTER, OUTLINE);
		loadingBarText.screenCenter(X);
		progress.add(loadingBarText);

		//finished.visible = false;
		//finished.active = false;

		add(progress);
		add(finished);

		add(loop);

		super.create();
	}

	public function updateBytes():Void {
		var data:BitmapData = BitmapData.fromFile(imagesArray[count]);
		//var image = new FlxSprite(FlxG.random.int(0, FlxG.width), FlxG.random.int(0, FlxG.height)).loadGraphic("shared:assets/shared/images/characters/BOYFRIEND_REMIX");
		var byte = new FlxSprite(FlxG.random.int(0, FlxG.width), FlxG.random.int(0, FlxG.height));
		byte.makeGraphic(1280, 720, 0x00000000);
		sys.thread.Thread.create(() -> {
			finished.add(byte);
			AssetCache.instance.setBitmapData(imagesArray[count],data);
			AssetCache.set("songs:assets/songs/" + Paths.formatToSongPath(PlayState.SONG.song) + "/Inst.ogg");
			AssetCache.set("songs:assets/songs/" + Paths.formatToSongPath(PlayState.SONG.song) + "/Voices.ogg");
			count++;
			//finished.add(image);
		});

        loadingBar.value = (finished.members.length / bytes) * bytes;
		loadingBarText.text = "Loading... (" + finished.members.length + "% / " + bytes + "%)";

		// if (finished.members.length == loop.finished) loop.finished = true;
	}

	override public function update(elapsed:Float):Void {
		bg.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		//CacheManager.set(imagesArray[count]);
		//count++;
		if (!loop.started) {
			loop.start();
		} else {
			if (loop.finished) {
				bg.visible = false;
				//finished.visible = true;
				progress.visible = false;
				//finished.active = true;
				progress.active = false;

				loop.kill();
				loop.destroy();

				// CACHES THE CURRENT SONG
				//sys.thread.Thread.create(() -> FlxG.sound.cache("songs:assets/songs/" + Paths.formatToSongPath(PlayState.SONG.song) + "/Inst" + PostCache.fileSuffix));

				/*if (CoolUtil.difficultyString().toLowerCase() != 'normal') {
					Paths.json(Paths.formatToSongPath(PlayState.SONG.song) + "/" + Paths.formatToSongPath(PlayState.SONG.song) + CoolUtil.getDifficultyFilePath());
				} else {
					Paths.json(Paths.formatToSongPath(PlayState.SONG.song) + "/" + Paths.formatToSongPath(PlayState.SONG.song));
					trace('No difficulty found, it is either null or normal');
				}
				Paths.inst(Paths.formatToSongPath(PlayState.SONG.song));
				Paths.voices(Paths.formatToSongPath(PlayState.SONG.song));
				
				if (CoolUtil.difficultyString().toLowerCase() != 'normal') {
					trace(Paths.json(Paths.formatToSongPath(PlayState.SONG.song) + "/" + Paths.formatToSongPath(PlayState.SONG.song) + CoolUtil.getDifficultyFilePath()));
				} else {
					trace(Paths.json(Paths.formatToSongPath(PlayState.SONG.song) + "/" + Paths.formatToSongPath(PlayState.SONG.song)));
				}
				trace(Std.string(Paths.inst(Paths.formatToSongPath(PlayState.SONG.song))));
				trace(Std.string(Paths.voices(Paths.formatToSongPath(PlayState.SONG.song))));*/

				if (FlxG.save.data.cacheCompleted) sys.thread.Thread.create(() -> FlxG.switchState(new PlayState()));
			}
		}

		super.update(elapsed);
	}
}