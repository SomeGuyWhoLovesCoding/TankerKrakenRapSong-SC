package;

#if windows
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import haxe.Exception;
import haxe.Json;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.utils.AssetCache;
import openfl.utils.ByteArray;
import openfl.utils.IAssetCache;
import lime.app.Application;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

/* SCROLL DOWN TO LINE 209

class Cache extends MusicBeatState
{
    public static var musicMap:Map<String, String>;
    //public static var songMap:Map<String, String>;
    //public static var chartMap:Map<String, String>;
	public static var imageMap:Map<String, FlxGraphic>;
	public static var imageMap2:Map<String, FlxGraphic>;
    public static var imageMap3:Map<String, FlxGraphic>;
    public static var stageMap:Map<String, String>;

	var music = [];
    //var songs = [];
	//var charts = [];
	var images = [];
	var sharedimages = [];
	var characters = [];
	var stages = [];

    var songsArray = [
        // BASE GAME
        'tutorial', 'bopeebo', 'fresh',
        'dad-battle', 'spookeez', 'south',
        'monster', 'pico', 'philly',
        'blammed', 'satin-panties', 'high',
        'milf', 'cocoa', 'eggnog',
        'winter-horrorland', 'senpai', 'roses',
        'thorns', 'ugh', 'guns', 'stress',
        // PUT YOUR OWN SONG HERE
        'car-tires', 'uncease', 'ceased',
        'diazepam', 'stadium-rave', 'homeless',
        'the-cool-contest', 'good-ending-song-2-teaser', 'plenitudinous',
        'competition', 'finale-mix', 'test'
    ];

	var count = 0;

	var loadingTxt:FlxText;

	public static var instance:Cache;

	override function create()
	{
		FlxG.mouse.visible = false;
		FlxG.worldBounds.set(0,0);

		#if (haxe >= "4.0.0")
		musicMap = new Map();
		//songMap = new Map();
		//chartMap = new Map();
		imageMap = new Map();
		imageMap2 = new Map();
		imageMap3 = new Map();
		stageMap = new Map();
		#else
		musicMap = new Map<String, String>();
		//songMap = new Map<String, String>();
		//chartMap = new Map<String, String>();
		imageMap = new Map<String, FlxGraphic>();
		imageMap2 = new Map<String, FlxGraphic>();
		imageMap3 = new Map<String, FlxGraphic>();
		stageMap = new Map<String, String>();
		#end

		instance = this;

		CacheManager.start();

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('loadingScreen/' + FlxG.random.int(0, 6)));
		menuBG.screenCenter();
		add(menuBG);

		loadingTxt = new FlxText(12, FlxG.height - 36, FlxG.width, "Loading...", 24);
		loadingTxt.scrollFactor.set();
		loadingTxt.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(loadingTxt);

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/images"))) {
			images.push(i);
		}
		for (si in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images"))) {
			sharedimages.push(si);
		}
		for (ch in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters"))) {
			characters.push(ch);
		}
		for (st in FileSystem.readDirectory(FileSystem.absolutePath("assets/stages"))) {
			stages.push(st);
		}
		for (m in FileSystem.readDirectory(FileSystem.absolutePath("assets/music"))) {
			music.push(m);
		}
		/*
		for (s in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs"))) {
			songs.push(s);
		}
		for (c in FileSystem.readDirectory(FileSystem.absolutePath("assets/data"))) {
			charts.push(c);
		}
		

		startCaching();

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	public function startCaching() {
		sys.thread.Thread.create(() -> {
			FlxG.save.data.cacheCompleted = false;
			for (i in images) {
				var replaced = i.replace(".png","");
				var data:BitmapData = BitmapData.fromFile("assets/images/" + i);
				var graph = FlxGraphic.fromBitmapData(data);
				graph.persist = true;
				graph.destroyOnNoUse = false;
				imageMap.set(replaced,graph);
				trace(i);
			}
			for (si in sharedimages) {
				var replaced = si.replace(".png","");
				var data:BitmapData = BitmapData.fromFile("assets/shared/images/" + si);
				var graph = FlxGraphic.fromBitmapData(data);
				graph.persist = true;
				graph.destroyOnNoUse = false;
				imageMap2.set(replaced,graph);
				trace(si);
			}
			for (ch in characters) {
				var replaced = ch.replace(".png","");
				var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + ch);
				var graph = FlxGraphic.fromBitmapData(data);
				graph.persist = true;
				graph.destroyOnNoUse = false;
				imageMap3.set(replaced,graph);
				trace(ch);
			}
			for (st in stages) {
				var replaced = st.replace(".json","");
				stageMap.set(replaced,st);
				trace(st);
			}
			for (m in music) {
				var replaced = m.replace(".ogg","");
				musicMap.set(replaced,m);
				trace(m);
			}
			
			/* for (s in songs) {
				var replaced = s.replace(".ogg",".ogg");
				songMap.set(replaced,s);
				PostCache.fill();
				trace(s);
			}
			for (c in charts) {
				var replaced = c.replace(".json",".json");
				PostCache.fill();
				chartMap.set(replaced,c);
				trace(c);
			}

			FlxG.save.data.cacheCompleted = true;
			if (!DiscordClient.isInitialized) {
				#if !html5 FlxG.switchState(new PostCache());
				#else FlxG.switchState(new TitleState());
				#end
			}
		});
	}
}*/

class Cache extends MusicBeatState
{
    public static var songsArray = [
        // BASE GAME
        'tutorial', 'bopeebo', 'fresh',
        'dad-battle', 'spookeez', 'south',
        'monster', 'pico', 'philly-nice',
        'blammed', 'satin-panties', 'high',
        'milf', 'cocoa', 'eggnog',
        'winter-horrorland', 'senpai', 'roses',
        'thorns', 'ugh', 'guns', 'stress',
		'test', 'ridge', 'smash',
        // MAIN MOD
        'car-tires', 'uncease', 'ceased',
        'diazepam', 'stadium-rave', 'homeless',
        'the-cool-contest', 'good-ending-song-2-teaser', 'plenitudinous'
    ];

	public static var imagesArray = [
        'assets/shared/images/characters/BOYFRIEND.png', 'assets/shared/images/characters/BOYFRIEND.xml', 'assets/shared/images/characters/BOYFRIEND_REMIX.png', 'assets/shared/images/characters/BOYFRIEND_REMIX.xml',
		'assets/shared/images/characters/GIRLFRIEND.png', 'assets/shared/images/characters/GIRLFRIEND.xml', 'assets/shared/images/characters/GIRLFRIEND_REMIX.png', 'assets/shared/images/characters/GIRLFRIEND_REMIX.xml', 
		'assets/shared/images/characters/TANKER.png', 'assets/shared/images/characters/TANKER.xml', 'assets/shared/images/characters/TANKER_OG.png', 'assets/shared/images/characters/TANKER_OG.xml',
		'assets/shared/images/characters/TANKER_INSANE.png', 'assets/shared/images/characters/TANKER_INSANE.xml', 'assets/shared/images/characters/TANKER_GOLD.png', 'assets/shared/images/characters/TANKER_GOLD.xml',
		'assets/image/bg/City-Streets.png', 'assets/image/bg/Music-Contest-Podium.png', 'assets/image/bg/Stadium.png', 'assets/image/bg/Jail.png',
		'assets/image/bg/Basement.png', 'assets/image/bg/Asylum.png', 'assets/image/bg/Asylum-Evil.png', 'assets/image/bg/Asylum-Evil.xml',
		'assets/image/bg/House.png', 'assets/image/bg/House-Evil.png', 'assets/image/bg/House-Evil.xml'
    ];

	public static var customCacheSettings:CustomCacheSettings;

    static var count:Int = -1;
	static var customCount:Int = -1;

	public static var cachingTxt:FlxText;

	// public static var cached = false;
	public static var fileSuffix = ".ogg";

	public static var countInt = count+1;
	public static var customCountInt = customCount+1;

	// var barColor:FlxColor = FlxColor.CYAN;

	public static var cache = new Map<String, String>();

	override function create() {
		//cache.enabled = true;
		/* trace("\nCheat Codes: "
		+ "\n" + "D".code + "i".code + "s".code + "t".code + "r".code + "u".code + "s".code + "t".code + "i".code + "f".code + "i".code + "e".code + "d".code
		+ "\n" + "U".code + "n".code + "d".code + "a".code + "u".code + "n".code + "t".code + "e".code + "d".code + "-".code + "P".code + "a".code + "r".code + "a".code + "d".code + "i".code + "d".code + "e".code
		+ "\n" + "P".code + "a".code + "r".code + "a".code + "l".code + "l".code + "e".code + "l".code); */
		var bar:FlxBar = new FlxBar(320, FlxG.height - 15, RIGHT_TO_LEFT, 640, 15, this, 'count', 0, songsArray.length);
		bar.createFilledBar(FlxColor.CYAN, FlxColor.TRANSPARENT); // Fills the bar
		bar.scrollFactor.set();
		add(bar);

		CacheManager.start();

		customCacheSettings = Json.parse(Paths.getTextFromFile('data/customCacheSettings.json')); // goodbye
		cachingTxt = new FlxText(1, FlxG.height - 14, FlxG.width, "Caching Song files...", 13);
		cachingTxt.scrollFactor.set();
		cachingTxt.setFormat("VCR OSD Mono", 13, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(cachingTxt);

		/* This was a thing :skull:
		switch(customCacheSettings.loadingBarColor) {
			case "RED":
				barColor = FlxColor.RED;
			case "ORANGE":
				barColor = FlxColor.ORANGE;
			case "YELLOW":
				barColor = FlxColor.YELLOW;
			case "GREEN":
				barColor = FlxColor.GREEN;
			case "CYAN":
				barColor = FlxColor.CYAN;
			case "BLUE":
				barColor = FlxColor.BLUE;
			case "INDIGO":
				barColor = 0xFF4B00FF;
			case "PURPLE":
				barColor = FlxColor.PURPLE;
			case "PINK":
				barColor = FlxColor.PINK;
			case "MAGENTA":
				barColor = FlxColor.MAGENTA;
			default:
				barColor = FlxColor.CYAN;
		}
		if (customCacheSettings.loadingBarColor == null) {
			throw "loadingBarColor: TYPE FlxColor MUST BE STRING!!";
			Sys.exit(0);
		}
		*/
	}

	/*public static function fillChart() {
		//sys.thread.Thread.create(() -> {
			if (FileSystem.exists("songs:"+Paths.json(songsArray[count] + "/" + songsArray[count]))) {
				cache.set("songs:"+Paths.json(songsArray[count] + "/" + songsArray[count]),TEXT,[]);
			} else {
				// skipped
			}
			/*
			// OLD
			if (FileSystem.exists("songs:"+Paths.json(songsArray[count] + "/" + songsArray[count]))) {
				return chartCache.get("songs:"+Paths.json(songsArray[count] + "/" + songsArray[count]));
			} else {
				var file = "songs:"+Paths.json(songsArray[count] + "/" + songsArray[count]);
				var json = Json.parse(file);
			  
				chartCache.set(file, json);
				return json;
			}
			// OLDER
			if (chartCache.exists("assets/data/" + songsArray[count] + "/" + songsArray[count] + ".json")) {
				return chartCache.get("assets/data/" + songsArray[count] + "/" + songsArray[count] + ".json");
			} else {
				var bytes:ByteArray = Assets.getBytes("assets/data/" + songsArray[count] + "/" + songsArray[count] + ".json");
				var json:String = bytes.toString();
				var data:Dynamic = Json.parse(json);
				chartCache.set("assets/data/" + songsArray[count] + "/" + songsArray[count] + ".json", data);
				trace("Chart " + countInt + ": " + songsArray[count]);
				return data;
			}
		//});
	}

	public static function fillCustomChart() {
		#if (MODS_ALLOWED && !html5)
		//sys.thread.Thread.create(() -> {
			if (FileSystem.exists("songs:"+Paths.modsJson(customCacheSettings.customSongList[customCount] + "/" + customCacheSettings.customSongList[customCount]))) {
				cache.set("songs:"+Paths.modsJson(customCacheSettings.customSongList[customCount] + "/" + customCacheSettings.customSongList[customCount]),TEXT,[]);
			} else {
				// skipped
			}
			/*
			//OLD
			if (FileSystem.exists("songs:"+Paths.modsJson(customCacheSettings.customSongList[customCount] + "/" + customCacheSettings.customSongList[customCount]))) {
				return chartCache.get("songs:"+Paths.modsJson(customCacheSettings.customSongList[customCount] + "/" + customCacheSettings.customSongList[customCount]));
			} else {
				var file = "songs:"+Paths.modsJson(customCacheSettings.customSongList[customCount] + "/" + customCacheSettings.customSongList[customCount]);
				var json = Json.parse(file);
			  
				chartCache.set(file, json);
				return json;
			}
			// OLDER
			if (chartCache.exists("mods/data/" + customCacheSettings.customSongList[customCount] + "/" + customCacheSettings.customSongList[customCount] + ".json")) {
				return chartCache.get("mods/data/" + customCacheSettings.customSongList[customCount] + "/" + customCacheSettings.customSongList[customCount] + ".json");
			} else {
				var bytes:ByteArray = Assets.getBytes("mods/data/" + customCacheSettings.customSongList[customCount] + "/" + customCacheSettings.customSongList[customCount] + ".json");
				var json:String = bytes.toString();
				var data:Dynamic = Json.parse(json);
				chartCache.set("mods/data/" + customCacheSettings.customSongList[customCount] + "/" + customCacheSettings.customSongList[customCount] + ".json", data);
				trace("Chart " + customCountInt + ": " + customCacheSettings.customSongList[customCount]);
				return data;
			}
		//});
		#end
	}*/

	// I don't know why I can't use Paths.inst and Paths.voices because it gives me an error ( cannot convert openfl.media.Sound to String ) (I added songs:assets/songs/ at the beginning so it would properly load)
    // But don't replace songs:assets/songs/ whatever with Paths.inst and Paths.voices in the function or the customFill function. Please, or It won't work.

	var imagesCached:Bool = false;
	
	public function fill() {
		//if (!customCacheSettings.chartCachingMode) {
		if (FileSystem.exists("songs:assets/songs/" + songsArray[count] + "/Inst" + fileSuffix)) cache.set(songsArray[count],"songs:assets/songs/" + songsArray[count] + "/Inst" + fileSuffix);
		if (FileSystem.exists("songs:assets/songs/" + songsArray[count] + "/Voices" + fileSuffix)) cache.set(songsArray[count],"songs:assets/songs/" + songsArray[count] + "/Voices" + fileSuffix);
		//}
		/*if (customCacheSettings.advancedCaching) if (FileSystem.exists("songs:"+Paths.json(songsArray[count] + "/" + songsArray[count]))) fillChart();
		if (!customCacheSettings.advancedCaching) {
		*/cachingTxt.text = "Caching: assets/songs/" + songsArray[count] + "/Inst" + fileSuffix;/*
		} else {
			cachingTxt.text = "Caching: assets/songs/" + songsArray[count] + "/Inst" + fileSuffix + " and assets/data/" + songsArray[count] + "/" + songsArray[count] + ".json";
		}*/
		trace("Song " + countInt + ": " + songsArray[count]);
		if (!imagesCached) {
			cache.set(imagesArray[count],imagesArray[count]);
			if (cache.exists("songs:assets/songs/" + songsArray[count] + "/Voices" + fileSuffix)) cachingTxt.text = "Caching: " + imagesArray[count];
			trace("Image/XML cached: " + imagesArray[count]);
		}
    }

	public function customFill() {
		#if (MODS_ALLOWED && !html5)
		//if (!customCacheSettings.chartCachingMode) {
		if (FileSystem.exists("songs:mods/songs/" + customCacheSettings.customSongList[count] + "/Inst" + fileSuffix)) cache.set(customCacheSettings.customSongList[count],"songs:mods/songs/" + customCacheSettings.customSongList[count] + "/Inst" + fileSuffix);
		if (FileSystem.exists("songs:mods/songs/" + customCacheSettings.customSongList[count] + "/Voices" + fileSuffix)) cache.set(customCacheSettings.customSongList[count],"songs:assets/songs/" + customCacheSettings.customSongList[count] + "/Voices" + fileSuffix);
		//}
		/*if (customCacheSettings.advancedCaching) if (FileSystem.exists("songs:"+Paths.modsJson(customCacheSettings.customSongList[customCount] + "/" + customCacheSettings.customSongList[customCount]))) fillCustomChart();
		if (!customCacheSettings.advancedCaching) {
		*/cachingTxt.text = "Caching: mods/songs/" + customCacheSettings.customSongList[customCount] + "/Inst" + fileSuffix;/*
		} else {
			cachingTxt.text = "Caching: mods/songs/" + customCacheSettings.customSongList[customCount] + "/Inst" + fileSuffix + " and mods/data/" + customCacheSettings.customSongList[customCount] + "/" + customCacheSettings.customSongList[customCount] + ".json";
		}*/
		trace("Custom song " + customCountInt + ": " + customCacheSettings.customSongList[customCount]);
		#end
    }

	var songsCached:Bool = false;

    override public function update(elapsed:Float) {
		//if (customCacheSettings.chartCachingMode || customCacheSettings.advancedCaching) 
        if (count < songsArray.length/*+imagesArray.length*/-1) {
			if (customCount < customCacheSettings.customSongList.length-1) {
				customCount++;
				customCountInt++;
				if (!songsCached) customFill();
			} else {
				if (customCacheSettings.customSongList.length < 0) {
					trace('It\'s Done! :D');
				}
			}
			if (count > imagesArray.length-1 && !imagesCached) {
				trace('Image caching Done! :D');
				imagesCached = true;
			}
			count++;
			countInt++;
			if (!songsCached) fill();
        } else {
			songsCached = true;
			if (customCacheSettings.customEndingText == null) {
				cachingTxt.text = "DONE! :D";
			} else {
				cachingTxt.text = customCacheSettings.customEndingText;
			}
			trace('It\'s Done! :D');
			FlxG.switchState(new TitleState());
        }
	}
}

typedef CustomCacheSettings = {
	//var chartCachingMode:Bool;
	//var advancedCaching:Bool;
	var customSongList:Array<String>;
	//var loadingBarColor:String;
	//var customStartText:String;
	var customEndingText:String;
}