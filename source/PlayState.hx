package;

import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.text.FlxTypeText;
import flixel.addons.util.FlxAsyncLoop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.ChartingState8K;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;
import animateatlas.AtlasFrameMaker;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import Conductor.Rating;

#if (!flash || !html5 || js)
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

// From https://github.com/ShadowMario/FNF-PsychEngine/blob/48b2b2eb3bafb45e5b4ac1d1f4764b75208044f4/source/PlayState.hx#L74
#if (desktop || windows)
#if (hxCodec >= "2.6.1") import hxcodec.VideoHandler as MP4Handler;
#elseif (hxCodec == "2.6.0") import VideoHandler as MP4Handler;
#else import vlc.MP4Handler; #end
#end

using StringTools;

class PlayState extends MusicBeatState
{
	//public var pad:FlxVirtualPad; That's stupid

	// Dialogue Stuffs
	public static var dialogueList:Array<String> = [
		"Test 1",
		"Test 2",
		"Test 3"
	];

	var coolDialogueText:FlxTypeText;
	var dBox:FlxSprite = new FlxSprite(0, 400);
	var dPortrait:FlxSprite = new FlxSprite(0, 300);
	
	var skipCount:Int = 0;
	//var maxLines:Int = dialogueList.length-1; ok

	public var missed:Bool = false;
	public var canDie:Bool = true;
	public static var startLocked:Bool = false; // Toggles 8K if true
	public static var tankerKrakenTransformed:Bool = false;

	public static var stageSuffix:String = ''; // The sound suffix based on the current stage

	public static var weekEnded:Bool = false;
	public static var isPostDialogue:Bool = false;
	
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var momMap:Map<String, Character> = new Map();
	public var picoMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var momMap:Map<String, Character> = new Map<String, Character>();
	public var picoMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	public var modchartTexts:Map<String, ModchartText> = new Map();
	public var modchartSaves:Map<String, FlxSave> = new Map();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var MOM_X:Float = 250;
	public var MOM_Y:Float = 50;
	public var PICO_X:Float = 400;
	public var PICO_Y:Float = 0;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var momGroup:FlxSpriteGroup;
	public var picoGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;

	public var dad:Character = null;
	public var mom:Character = null;
	public var pico:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;
	public var noMechanics:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var dadbattleBlack:BGSprite;
	var dadbattleLight:BGSprite;
	var dadbattleSmokes:FlxSpriteGroup;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:FlxSprite;
	var phillyWindowEvent:BGSprite;
	var trainSound:FlxSound;

	var phillyGlowGradient:PhillyGlow.PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlow.PhillyGlowParticle>;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var foregroundSprites:FlxTypedGroup<BGSprite>;

	var particle:Particle;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	public var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	//private var controlArray:Array<String>;

	var precacheList:Map<String, String> = new Map<String, String>();
	
	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	public static var shader:FlxSprite; // Shader base

	public static var modchartInitialized:Bool = false;

	public static var modchartType1:Bool = false;
	public static var modchartType2:Bool = false;
	public static var modchartType3:Bool = false;
	public static var modchartType4:Bool = false;
	public static var modchartType5:Bool = false;

	static var modchartTypeCustom:Bool = false;

	override public function create()
	{
		// Story Mode Events Stuff (SCRAPPED)
		/* switch (SONG.song) {
			case "Car Tires":
				modchartInitialized = false;
				startLocked = false;
				dialogueList = [
					"HEUEHUH! How are you doing today?",
					"I'm not doing well. Anyway, what are those noises that you are making?",
					"That heuheuh that he makes when he's rich, I guess?",
					"YEAH! I see!",
					"HEUHEUHH, HEUHEUHH, Are you ready to sing??",
					"Actually, We are singers!",
					"You're the lucky one, tanker!",
					"So let's do it!",
					"Make those heuheuh sounds again, and we're not singing.",
					"I'll do it for you, boyfriend!"
				];
			case "Uncease":
				modchartInitialized = false;
				startLocked = false;
				///*if (ratingPercent < 0.75 && isStoryMode && !chartingMode) {
					dialogueList = [
						"Heuheuh?",
						"NO!",
						"Did I win?",
						"No you didn't.",
						"Why?",
						"Because you never rap battled in your entire life.",
						"Aw, sucks.",
						"HEUHEUUUUUUUUUUUHHHHHHHHHHHHHHHHH-",
						"SHUT UUUUUUP!!",
						"Boyfriend, calm down.",
						"YOU HAVE TO STOP MAKING THOSE AWFUL NOISES, NOW!",
						"Heuheuh, I don't care.",
						"Well I don't recall making those noises either.",
						"HEUHEUHHH, HEUHEUHH! Yeah!",
						"Heuheuuuuhhhhhhhhhh YEAH!",
						"Did you just rob the bank again?",
						"Yes.",
						"YOU LITTLE-",
						"Boyfriend! You are scaring me.",
						"YEAH, BECAUSE TANKER KRAKEN JUST ROBBED THE BANK AGAIN!",
						"Uh oh, that's bad.",
						"BAD TANKER!",
						"Now should we do another rap battle?",
						"NO!",
						"I AM LEAVING!",
						"Me too."
					];
					weekEnded = true;
				} else {//
				dialogueList = [
					"Heuheuh?",
					"NO!",
					"Did I win?",
					"No you didn't.",
					"Why?",
					"Because you never rap battled in your entire life.",
					"Aw, sucks.",
				//	"HEUHEUUUUUUUUUUUHHHHHHHHHHHHHHHHH-",
					"HEUHEUH! HEUHEUH!",
				//	"SHUT UUUUUUP!!",
				//	"Boyfriend, calm down.",
					"YOU HAVE TO STOP MAKING THOSE AWFUL NOISES, NOW!",
					"Heuheuh, I don't care.",
					"Well I don't recall making those noises either.",
					"HEUHEUHHH, HEUHEUHH! Yeah!",
					"Heuheuuuuhhhhhhhhhh YEAH!",
					"Did you just rob the bank again?",
					"Yes.",
					"YOU LITTLE-",
					"Boyfriend! You are scaring me.",
					"Look, Tanker kraken just robbed a bank again.",
					"And he is SUCH AN IDIOT!",
					"Do you want to know what medicine I take?",
					"Is it a pill?",
					"Even better...",
					"DIAZEPAM!",
					"Ew. I don't want that.",
					"Calm down boyfriend, just calm down. We'll do another rap battle!",
					"A Slow one!",
				//	"Fine.",
					"Boyfriend, don't get mad if tanker does another crime, ok?",
					"You sounded like a psychopath!",
					"Yeah! I don't want to talk about it.",
					"Let's get started with the second song.",
					"(I made the first one in groovepad.)",
					"GROOVEPAD?! WHY WOULD YOU USE THAT, JUST TO MAKE YOUR OWN SONGS!?",
					"Link in the description.",
					"SHUT UP!",
					"Tanker, let's just get this over with.",
				//	"HEUEUUUUUUUUHHHH!",
				//	"OOWWWW! You're hurting my ears.",
					"Ok."
				];
				//}
			case "Ceased":
				modchartInitialized = false;
				startLocked = false;
			case "Diazepam":
				modchartInitialized = false;
				startLocked = false;
			case "Stadium Rave":
				modchartInitialized = false;
				startLocked = false;
			case "Homeless" | "The Cool Contest" | "Challenge":
				if (SONG.song == "Homeless") {
					startLocked = true;
					if (!isPostDialogue) {
						dialogueList = [
							"...",
							"eh...",
							"I...",
							"I LOST EVERYTHING!! *crying*",
							"There you go. That's what you get for robbing things.",
							"I... *sobs*",
							"I told you this would happen. Did you notice that you lost everyone in the city's homes because of that FAKE 100 Million dollars!?",
							"No...",
							"Me and Girlfriend lost everything because of you.",
							"You should've thought of that before you got that fake 100 million dollars.",
							"What about my house?",
							"You lost everything, Listing as your clothes, your shoes, all your food, your TV, your lambourghini that you stole, and your money.",
							"I... *crying* Should have thought of that before I caused the bank to lose all its money...",
							"I'm sorry, Girlfriend. I'll miss you...",
							"It's alright, Tanker Kraken. We're still here.",
							"Now let's settle this out by singing so that we can get our home back.",
							"Alright. If you do good, I'll reverse what I did before I lost everything. Got it?",
							"Yes! I will!",
							"Now let's sing a poor song...",
							"Nah, we'll do a rich song.",
							"Okay."
						];
						weekEnded = false;
					} else {
						dialogueList = [
							"Heuheuh. I'll upgrade my shop stand after you reverse what I did before.",
							"I will.",
							"Cool. Just, Please do it the right way.",
							"I always do it right! I just used my magic, by singing.",
							"I almost blacked out whenever you used it. The flashing really got me brain hemorrhages.",
							"Oh no. We should call the ambulance.",
							"YOU REALLY HAVE BRAIN HEMORRHAGES!?",
							"JUNE FOOLS!",
							"I actually didn't.",
							"You mean april fools? It's not April 1st anymore.",
							"*sigh* At least I learned my lesson. Don't fool the government.",
							"NOW DON'T DO IT AGAIN!!"
						];
						weekEnded = true;
					}
				}
				
				if (SONG.song == "The Cool Contest") {
					dialogueList = [
						"Welcome to the interrogation room.",
						"Where are we!?",
						"Take off your blindfold and see what happens...",
						"...",
						"WHAT IS THIS PLACE!?",
						"The Interrogation room.",
						"It's where I dicuss both of you something you did to me that is wrong.",
						"What's after that?",
						"I'M GOING TO KILL BOTH OF YOU!",
						"*gasp* Why!?",
						"Because I cannot lose to some child who has rapping skills...",
						"I cannot lose, because the king cannot lose.",
						"Call me the king, from now on...",
						"PLEASE.",
						"Alright, the king. What do I have here?",
						"You've been sent here because I hit both of your heads...",
						"(With a mallet)",
						"The King, I can't breathe......",
						"I'M DYING!",
						"AUUUEEH HEUHEUH! TOO BAD!",
						"YOU ARE TRYING TO KILL ME, AREN'T YOU!",
						"Yes.",
						"*coughs* I can't live like this...",
						"I... want to breate again...",
						"I also kidnapped pico, your ex...",
						"Thank god. He was the one who was trying to shoot me in the early days, that's why.",
						"So you came here to teach pico a lesson?",
						"No, I'm going to kill him...",
						"YOU WHAT!?!?",
						"DON'T DO THIS TO PICO, PLEASE! WE'RE SORRY FOR OUR ACTIONS, JUST LET US GO!!",
						"No... It's too late...",
						"*coughs*",
						"If you want to be able to breathe again, take this impossible quiz I made.",
						"*cough* How am I able to??",
						"Answer one wrong question, then I will kill both of you...",
						"No you're not gonna kill us.",
						"I'm going to reverse the action that you've done, RIGHT NOW!",
						"DON'T... PLEASE...",
						"Don't isn't gonna work.",
						"Ready tanker?",
						"No... Please...",
						"No please isn't gonna work either, so no more talking.",
						"...",
						"*cough* Okay? Did it work?",
						"Yes, boyfriend.",
						"I can finally breathe again...",
						"THANK YOU GIRLFRIEND!",
						"BUT TANKER, YOU ARE GOING TO SEND US BACK TO THE MUSIC CONTEST BUILDING TO FINISH UP THE SHOW, OR ELSE I'M GONNA RAP BATTLE YOU.",
						"Either that, or get ready.",
						"Okay.",
						"Please.",
						"Just let that all go...",
						"I also bought my pal here.",
						"Her name is bakii.",
						"She's from FestivalV.\nhttps://youtube.com/playlist?list=PL9u5bjJISNKysncZD9-uxQxgL6PiP0Prw",
						"Who are you??",
						"My name is Tanker Kraken Tanker Kraken... And I'm going to kill bakii, because she's been a crybaby since.",
						"WHAT!?!",
						"Don't worry, bakii. We're gonna settle this out.",
						"Okay, but I'm gonna sing too.",
						"Alright then!",
						"Get prepared... Please.",
						"We're all prepared.",
						"What year is it?",
						"It's " + Date.now().getFullYear() + ".",
						Date.now().getFullYear() + "!? I didn't know that!",
						"Yeah, because the cell has a clock. DUH!",
						"Let's settle this out before I destroy everything you have."
					];
					weekEnded = false;
					startLocked = true;
				}
				if (SONG.song == "Challenge") {
					dialogueList = [
						"Hehhehh...",
						"I'm going to kill you two...",
						"RIGHT NOW!",
						"Wh- Where are we?!?",
						"I brang both of you to my basement, to kill you.",
						"BECAUSE I AM TIRED OF LOSING, AND THE KING CANNOT LOSE!",
						"Call me the king of krakens.",
						"...",
						"AAAARRGHHH! I'VE BEEN MISPRONOUNCING KRAKEN FOREVER... *sobs*",
						"It's ok, Tanker.",
						"I'M STILL GOING TO KILL YOU THO!",
						"It won't work unless you have a knife.",
						"I HAVE A KNIFE!",
						"AAAAAAAAAAAAAAAAAAAAHHHH! TANKER HAS A KNIFE! GIRLFRIEND, BRING A KNIFE!",
						"That was the only knife in my house...",
						"Let's settle this out so that we can get out of here!",
						"You can't get out of there... I locked every door before you both woke up...",
						"WOW! YOU HAD TO LOCK EVERY DOOR, HUH!? WHAT ABOUT THE DOOR BEHIND ME?!",
						"You can't touch it, or else Ima kill you both.",
						"Now Let's settle this out like you said.",
						"Okay...",
						"I hope there's a way to get out of here."
					];
					weekEnded = false;
					startLocked = true;
				}
			default:
				modchartInitialized = false;
				startLocked = false;
		} */

		//Paths.clearStoredMemory();

		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		if (!startLocked) {
			keysArray = [
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
			];
			/*controlArray = [
				'NOTE_LEFT',
				'NOTE_DOWN',
				'NOTE_UP',
				'NOTE_RIGHT'
			];*/
		} else { // 8 keys
			keysArray = [
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note1_left8k')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note1_down8k')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note1_up8k')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note1_right8k')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note2_left8k')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note2_down8k')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note2_up8k')),
				ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note2_right8k'))
			];
			/*controlArray = [
				'NOTE_LEFT',
				'NOTE_DOWN',
				'NOTE_UP',
				'NOTE_RIGHT',
				'NOTE_LEFT',
				'NOTE_DOWN',
				'NOTE_UP',
				'NOTE_RIGHT'
			];*/
		}

		// Ratings
		ratingsData.push(new Rating('sick')); // Default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.75;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.5;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0.25;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length) keysPressed.push(false);

		if (FlxG.sound.music != null) FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);
		noMechanics = ClientPrefs.getGameplaySetting('mechanics', true);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera(0, 0, FlxG.width, FlxG.height, defaultCamZoom);
		camHUD = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		camOther = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null) SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		//trace('stage is: ' + curStage);
		if(SONG.stage == null || SONG.stage.length < 1) {
			switch (songName)
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					curStage = 'tank';
				case 'car-tires' | 'uncease':
					curStage = 'city-streets';
				case 'ceased' | 'diazepam':
					curStage = 'music-contest-podium';
				case 'homeless':
					curStage = 'back-alley';
				case 'the-cool-contest':
					curStage = 'interrigatee';
				case 'stadium-rave' | 'good-ending-song-2-teaser':
					curStage = 'stadium';
				default:
					curStage = 'stage';
			}
		}
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null) opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null) girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		momGroup = new FlxSpriteGroup(MOM_X, MOM_Y);
		picoGroup = new FlxSpriteGroup(PICO_X, PICO_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			// Stages for the mod

			case 'city-streets': // Tanker Kraken's Rap Song - Car Tires, Unceased
				GameOverSubstate.loopSoundName = 'gameOver-tankerKrakenRapSong';
				GameOverSubstate.endSoundName = 'gameOverEnd-tankerKrakenRapSong';

				var bg:BGSprite = new BGSprite('bg/City-Streets', -600, -600, 1, 1);
				add(bg);

				// PRECACHE CAR SOUNDS
				precacheList.set('cars-passing-by', 'sound');
				precacheList.set('slow-cars', 'sound');
				precacheList.set('car-beeping', 'sound');

			case 'music-contest-podium': // Tanker Kraken's Rap Song - Ceased, Diazepam/Tsarevna
				GameOverSubstate.loopSoundName = 'gameOver-tankerKrakenRapSong';
				GameOverSubstate.endSoundName = 'gameOverEnd-tankerKrakenRapSong';
				var bg:BGSprite = new BGSprite('bg/Music-Contest-Podium', -600, -600, 1, 1);
				add(bg);

				stageSuffix = 'podium-crowd';

				// THIS WAS A SHADER TEST
				//var glitchEffect = new FlxGlitchEffect(16,2,0,FlxGlitchDirection.HORIZONTAL);
				//var glitchSprite = new FlxEffectSprite(bg, [glitchEffect]);
				//shader = glitchSprite;
				//add(shader);

				// PRECACHE CROWD SOUNDS
				precacheList.set('podium-crowd/clapping', 'sound');
				precacheList.set('podium-crowd/clapping', 'sound');
				precacheList.set('podium-crowd/booing', 'sound');

			case 'stadium': // Tanker Kraken's Rap Song - Stadium Rave
				GameOverSubstate.loopSoundName = 'gameOver-tankerKrakenRapSong';
				GameOverSubstate.endSoundName = 'gameOverEnd-tankerKrakenRapSong';

				if (!ClientPrefs.lowQuality) {
					var front:BGSprite = new BGSprite('bg/Stadium/Front', -600, -600, 1, 1);
					add(front);
					particle = new Particle();
					add(particle);
					var back:BGSprite = new BGSprite('bg/Stadium/Back', -600, -600, 1, 1);
					add(back);
				} else {
					var bg:BGSprite = new BGSprite('bg/Stadium_Low_Quality', -600, -600, 1, 1);
					add(bg);
				}

				stageSuffix = 'stadium-crowd';

				// PRECACHE CROWD SOUNDS
				precacheList.set('stadium-crowd/cheering', 'sound');
				precacheList.set('stadium-crowd/clapping', 'sound');
				precacheList.set('stadium-crowd/booing', 'sound');

			case 'basement':
				GameOverSubstate.loopSoundName = 'gameOver-tankerKrakenRapSong_Slow';
				GameOverSubstate.endSoundName = 'gameOverEnd-tankerKrakenRapSong_Slow';
				var bg:BGSprite = new BGSprite('bg/Basement', -600, -600, 1, 1);
				add(bg);

				stageSuffix = 'basement';

				// PRECACHE BASEMENT VENT SOUND
				precacheList.set('basement/vent', 'sound');

			case 'interrogatee':
				GameOverSubstate.loopSoundName = 'gameOver-tankerKrakenRapSong_Slow';
				GameOverSubstate.endSoundName = 'gameOverEnd-tankerKrakenRapSong_Slow';
				var bg:BGSprite = new BGSprite('bg/Interrogatee', -600, -600, 1, 1);
				add(bg);

				stageSuffix = 'jail';

				// PRECACHE STUFF
				precacheList.set('jail/jail-sounds/0', 'sound');
				precacheList.set('jail/jail-sounds/1', 'sound');
				precacheList.set('jail/jail-sounds/2', 'sound');
				precacheList.set('jail/jail-sounds/3', 'sound');
				precacheList.set('jail/jail-sounds/4', 'sound');
				precacheList.set('jail/guard-passingby', 'sound');

			// BASE GAME
			case 'stage': // Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
				dadbattleSmokes = new FlxSpriteGroup(); //troll'd

			case 'spooky': //Week 2
				if(!ClientPrefs.lowQuality) {
					halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
				} else {
					halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
				}
				add(halloweenBG);

				halloweenWhite = new BGSprite(null, -800, -400, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				// PRECACHE SOUNDS
				precacheList.set('thunder_1', 'sound');
				precacheList.set('thunder_2', 'sound');

			case 'philly': // Week 3
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
					add(bg);
				}

				var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
				phillyWindow = new BGSprite('philly/window', city.x, city.y, 0.3, 0.3);
				phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
				phillyWindow.updateHitbox();
				add(phillyWindow);
				phillyWindow.alpha = 0;

				if(!ClientPrefs.lowQuality) {
					var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
					add(streetBehind);
				}

				phillyTrain = new BGSprite('philly/train', 2000, 360);
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				phillyStreet = new BGSprite('philly/street', -40, 50);
				add(phillyStreet);

			case 'limo': // Week 4
				var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
				add(skyBG);

				if(!ClientPrefs.lowQuality) {
					limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
					add(limoMetalPole);

					bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(bgLimo);

					limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 170, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					// PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					// PRECACHE SOUND
					precacheList.set('dancerdeath', 'sound');
				}

				limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);

				fastCar = new BGSprite('limo/fastCarLol', -300, 160);
				fastCar.active = true;
				limoKillingState = 0;

			case 'mall': // Week 5 - Cocoa, Eggnog
				var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality) {
					upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}

				var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
				add(tree);

				bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
				add(fgSnow);

				santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
				add(santa);
				precacheList.set('Lights_Shut_off', 'sound');

			case 'mallEvil': // Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
				add(evilSnow);

			case 'school': // Week 6 - Senpai, Roses
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
				add(bgSky);
				bgSky.antialiasing = false;

				var repositionShit = -200;

				var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
				add(bgSchool);
				bgSchool.antialiasing = false;

				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
				add(bgStreet);
				bgStreet.antialiasing = false;

				var widShit = Std.int(bgSky.width * 6);
				if(!ClientPrefs.lowQuality) {
					var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
					fgTrees.antialiasing = false;
				}

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
				bgTrees.antialiasing = false;

				if(!ClientPrefs.lowQuality) {
					var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					add(treeLeaves);
					treeLeaves.antialiasing = false;
				}

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));

				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();

				if(!ClientPrefs.lowQuality) {
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}

			case 'schoolEvil': //Week 6 - Thorns
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
				var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

				var posX = 400;
				var posY = 200;
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);

					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				} else {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);
				}

			case 'tank': //Week 7 - Ugh, Guns, Stress
				var sky:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
				add(sky);

				if(!ClientPrefs.lowQuality)
				{
					var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
					clouds.active = true;
					clouds.velocity.x = FlxG.random.float(5, 15);
					add(clouds);

					var mountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
					mountains.setGraphicSize(Std.int(1.2 * mountains.width));
					mountains.updateHitbox();
					add(mountains);

					var buildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.3, 0.3);
					buildings.setGraphicSize(Std.int(1.1 * buildings.width));
					buildings.updateHitbox();
					add(buildings);
				}

				var ruins:BGSprite = new BGSprite('tankRuins',-200,0,.35,.35);
				ruins.setGraphicSize(Std.int(1.1 * ruins.width));
				ruins.updateHitbox();
				add(ruins);

				if(!ClientPrefs.lowQuality)
				{
					var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
					add(smokeLeft);
					var smokeRight:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
					add(smokeRight);

					tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
					add(tankWatchtower);
				}

				tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5,['BG tank w lighting'], true);
				add(tankGround);

				tankmanRun = new FlxTypedGroup<TankmenBG>();
				add(tankmanRun);

				var ground:BGSprite = new BGSprite('tankGround', -420, -150);
				ground.setGraphicSize(Std.int(1.15 * ground.width));
				ground.updateHitbox();
				add(ground);
				moveTank();

				foregroundSprites = new FlxTypedGroup<BGSprite>();
				foregroundSprites.add(new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']));
				foregroundSprites.add(new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']));
				foregroundSprites.add(new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']));
		}

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'stress':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup); //Needed for blammed lights

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(picoGroup);
		add(momGroup);
		add(dadGroup);
		add(boyfriendGroup);

		switch(curStage)
		{
			case 'spooky':
				add(halloweenWhite);
			case 'tank':
				add(foregroundSprites);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		startLuasOnFolder('stages/' + curStage + '.lua');
		#end

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
				default:
					gfVersion = 'gf';
			}

			switch(Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			if (gfVersion != null) gfGroup.add(gf); // Checks if gf is valid
			startCharacterLua(gf.curCharacter);

			if(gfVersion == 'pico-speaker')
			{
				if(!ClientPrefs.lowQuality)
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 600, true);
					firstTank.strumTime = 10;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length)
					{
						if(FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
				}
			}
		}

		pico = new Character(0, 0, SONG.player4);
		startCharacterPos(pico, true);
		if (SONG.player4 != null) picoGroup.add(pico); // Checks if player 3 is valid
		startCharacterLua(pico.curCharacter);

		mom = new Character(0, 0, SONG.player3);
		startCharacterPos(mom, true);
		if (SONG.player3 != null) momGroup.add(mom); // Checks if player 3 is valid
		startCharacterLua(mom.curCharacter);

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		if (SONG.player2 != null) dadGroup.add(dad); // Checks if player 2 is valid
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		if (SONG.player1 != null) boyfriendGroup.add(boyfriend); // Checks if player 1 is valid
		startCharacterLua(boyfriend.curCharacter);

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null) gf.visible = false;
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				addBehindGF(fastCar);

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				addBehindDad(evilTrail);
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000 / Conductor.songPosition;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		healthBarBG = new AttachedSprite('healthBar');
		if (tankerKrakenTransformed) healthBarBG = new AttachedSprite('healthBarEvolved');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.hudAlpha;
		add(healthBar);
		add(healthBarBG);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.hudAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.hudAlpha;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.alpha = ClientPrefs.hudAlpha;
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.alpha = ClientPrefs.hudAlpha;
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		doof.cameras = [camOther];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			startLuasOnFolder('custom_notetypes/' + notetype + '.lua');
		}
		for (event in eventPushedMap.keys())
		{
			startLuasOnFolder('custom_events/' + event + '.lua');
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		if(eventNotes.length > 1)
		{
			for (event in eventNotes) event.strumTime -= eventNoteEarlyTrigger(event);
			eventNotes.sort(sortByTime);
		}

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/data/' + Paths.formatToSongPath(SONG.song) + '/' ));// using push instead of insert because these should run after everything else
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if(gf != null) gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapCamFollowToPos(400, -2050);
					FlxG.camera.focusOn(camFollow);
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				case 'senpai' | 'roses' | 'thorns':
					if(daSong == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

				//case 'car-tires' | 'uncease' | 'ceased' | 'diazepam':
					//coolIntro(dialogueList);

				//case 'homeless' | 'the-cool-contest' | 'challenge':
					//epicIntro(dialogueList);

				case 'ugh' | 'guns' | 'stress':
					tankIntro();

				default:
					startCountdown();
			}
			seenCutscene = true;
		} else {
			startCountdown();
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		precacheList.set('alphabet', 'image');
	
		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		if(!ClientPrefs.controllerMode) {
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		callOnLuas('onCreatePost', []);

		super.create();

		// VS Sustain notes
		notes.forEachAlive(function(note:Note) if (note.isSustainNote) note.noAnimation = true);

		cacheCountdown();
		cachePopUpScore();
		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'shared_image':
					Paths.image(key, 'shared');
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
				case 'inst':
					Paths.inst(key);
				case 'voices':
					Paths.voices(key);
				case 'json':
					Paths.json(key);
			}
		}
		Paths.clearUnusedMemory();
		
		CustomFadeTransition.nextCamera = camOther;
		if(eventNotes.length < 1) checkEventNote();
	}

	#if (!flash && sys || !html5)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys || !html5)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.shaders) return false;

		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			FlxG.sound.music.pitch = value;
		}
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		trace('Anim speed: ' + FlxAnimationController.globalSpeed);
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		setOnLuas('playbackRate', playbackRate);
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
				
			case 3:
				if(!momMap.exists(newCharacter)) {
					var newMom:Character = new Character(0, 0, newCharacter);
					momMap.set(newCharacter, newMom);
					momGroup.add(newMom);
					startCharacterPos(newMom, true);
					newMom.alpha = 0.00001;
					startCharacterLua(newMom.curCharacter);
				}
			
			case 4:
				if(!picoMap.exists(newCharacter)) {
					var newPico:Character = new Character(0, 0, newCharacter);
					picoMap.set(newCharacter, newPico);
					picoGroup.add(newPico);
					startCharacterPos(newPico, true);
					newPico.alpha = 0.00001;
					startCharacterLua(newPico.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		#else
		luaFile = Paths.getPreloadPath(luaFile);
		if(Assets.exists(luaFile)) {
			doPush = true;
		}
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys if(!FileSystem.exists(filepath)) #else if(!OpenFlAssets.exists(filepath)) #end {
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		#if (desktop || windows)
		var video:MP4Handler = new MP4Handler();
		video.playVideo(filepath);
		video.finishCallback = function() {
			startAndEnd();
			return;
		}
		#end

		#else

		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd() {
		if(endingSong) {
			endSong();
		} else {
			startCountdown();
		}
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function tankIntro()
	{
		var cutsceneHandler:CutsceneHandler = new CutsceneHandler();

		var songName:String = Paths.formatToSongPath(SONG.song);
		dadGroup.alpha = 0.00001;
		camHUD.visible = false;
		//inCutscene = true; //this would stop the camera movement, oops

		var tankman:FlxSprite = new FlxSprite(-20, 320);
		tankman.frames = Paths.getSparrowAtlas('cutscenes/' + songName);
		tankman.antialiasing = ClientPrefs.globalAntialiasing;
		addBehindDad(tankman);
		cutsceneHandler.push(tankman);

		var tankman2:FlxSprite = new FlxSprite(16, 312);
		tankman2.antialiasing = ClientPrefs.globalAntialiasing;
		tankman2.alpha = 0.000001;
		cutsceneHandler.push(tankman2);
		var gfDance:FlxSprite = new FlxSprite(gf.x - 107, gf.y + 140);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfDance);
		var gfCutscene:FlxSprite = new FlxSprite(gf.x - 104, gf.y + 122);
		gfCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(gfCutscene);
		var picoCutscene:FlxSprite = new FlxSprite(gf.x - 849, gf.y - 264);
		picoCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(picoCutscene);
		var boyfriendCutscene:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
		boyfriendCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		cutsceneHandler.push(boyfriendCutscene);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			moveCamera(true);
			startCountdown();

			dadGroup.alpha = 1;
			camHUD.visible = true;
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
		};

		camFollow.set(dad.x + 280, dad.y + 170);
		switch(songName)
		{
			case 'ugh':
				cutsceneHandler.endTime = 12;
				cutsceneHandler.music = 'DISTORTO';
				precacheList.set('wellWellWell', 'sound');
				precacheList.set('killYou', 'sound');
				precacheList.set('bfBeep', 'sound');

				var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
				FlxG.sound.list.add(wellWellWell);

				tankman.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
				tankman.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
				tankman.animation.play('wellWell', true);
				FlxG.camera.zoom *= 1.2;

				// Well well well, what do we got here?
				cutsceneHandler.timer(0.1, function()
				{
					wellWellWell.play(true);
				});

				// Move camera to BF
				cutsceneHandler.timer(3, function()
				{
					camFollow.x += 750;
					camFollow.y += 100;
				});

				// Beep!
				cutsceneHandler.timer(4.5, function()
				{
					boyfriend.playAnim('singUP', true);
					boyfriend.specialAnim = true;
					FlxG.sound.play(Paths.sound('bfBeep'));
				});

				// Move camera to Tankman
				cutsceneHandler.timer(6, function()
				{
					camFollow.x -= 750;
					camFollow.y -= 100;

					// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
					tankman.animation.play('killYou', true);
					FlxG.sound.play(Paths.sound('killYou'));
				});

			case 'guns':
				cutsceneHandler.endTime = 11.5;
				cutsceneHandler.music = 'DISTORTO';
				tankman.x += 40;
				tankman.y += 10;
				precacheList.set('tankSong2', 'sound');

				var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
				FlxG.sound.list.add(tightBars);

				tankman.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
				tankman.animation.play('tightBars', true);
				boyfriend.animation.curAnim.finish();

				cutsceneHandler.onStart = function()
				{
					tightBars.play(true);
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
				};

				cutsceneHandler.timer(4, function()
				{
					gf.playAnim('sad', true);
					gf.animation.finishCallback = function(name:String)
					{
						gf.playAnim('sad', true);
					};
				});

			case 'stress':
				cutsceneHandler.endTime = 35.5;
				tankman.x -= 54;
				tankman.y -= 14;
				gfGroup.alpha = 0.00001;
				boyfriendGroup.alpha = 0.00001;
				camFollow.set(dad.x + 400, dad.y + 170);
				FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.y += 100;
				});
				precacheList.set('stressCutscene', 'sound');

				tankman2.frames = Paths.getSparrowAtlas('cutscenes/stress2');
				addBehindDad(tankman2);

				if (!ClientPrefs.lowQuality)
				{
					gfDance.frames = Paths.getSparrowAtlas('characters/gfTankmen');
					gfDance.animation.addByPrefix('dance', 'GF Dancing at Gunpoint', 24, true);
					gfDance.animation.play('dance', true);
					addBehindGF(gfDance);
				}

				gfCutscene.frames = Paths.getSparrowAtlas('cutscenes/stressGF');
				gfCutscene.animation.addByPrefix('dieBitch', 'GF STARTS TO TURN PART 1', 24, false);
				gfCutscene.animation.addByPrefix('getRektLmao', 'GF STARTS TO TURN PART 2', 24, false);
				gfCutscene.animation.play('dieBitch', true);
				gfCutscene.animation.pause();
				addBehindGF(gfCutscene);
				if (!ClientPrefs.lowQuality)
				{
					gfCutscene.alpha = 0.00001;
				}

				picoCutscene.frames = AtlasFrameMaker.construct('cutscenes/stressPico');
				picoCutscene.animation.addByPrefix('anim', 'Pico Badass', 24, false);
				addBehindGF(picoCutscene);
				picoCutscene.alpha = 0.00001;

				boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
				boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
				boyfriendCutscene.animation.play('idle', true);
				boyfriendCutscene.animation.curAnim.finish();
				addBehindBF(boyfriendCutscene);

				var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
				FlxG.sound.list.add(cutsceneSnd);

				tankman.animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
				tankman.animation.play('godEffingDamnIt', true);

				var calledTimes:Int = 0;
				var zoomBack:Void->Void = function()
				{
					var camPosX:Float = 630;
					var camPosY:Float = 425;
					camFollow.set(camPosX, camPosY);
					camFollowPos.setPosition(camPosX, camPosY);
					FlxG.camera.zoom = 0.8;
					cameraSpeed = 1;

					calledTimes++;
					if (calledTimes > 1)
					{
						foregroundSprites.forEach(function(spr:BGSprite)
						{
							spr.y -= 100;
						});
					}
				}

				cutsceneHandler.onStart = function()
				{
					cutsceneSnd.play(true);
				};

				cutsceneHandler.timer(15.2, function()
				{
					FlxTween.tween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});

					gfDance.visible = false;
					gfCutscene.alpha = 1;
					gfCutscene.animation.play('dieBitch', true);
					gfCutscene.animation.finishCallback = function(name:String)
					{
						if(name == 'dieBitch') //Next part
						{
							gfCutscene.animation.play('getRektLmao', true);
							gfCutscene.offset.set(224, 445);
						}
						else
						{
							gfCutscene.visible = false;
							picoCutscene.alpha = 1;
							picoCutscene.animation.play('anim', true);

							boyfriendGroup.alpha = 1;
							boyfriendCutscene.visible = false;
							boyfriend.playAnim('bfCatch', true);
							boyfriend.animation.finishCallback = function(name:String)
							{
								if(name != 'idle')
								{
									boyfriend.playAnim('idle', true);
									boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
								}
							};

							picoCutscene.animation.finishCallback = function(name:String)
							{
								picoCutscene.visible = false;
								gfGroup.alpha = 1;
								picoCutscene.animation.finishCallback = null;
							};
							gfCutscene.animation.finishCallback = null;
						}
					};
				});

				cutsceneHandler.timer(17.5, function()
				{
					zoomBack();
				});

				cutsceneHandler.timer(19.5, function()
				{
					tankman2.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
					tankman2.animation.play('lookWhoItIs', true);
					tankman2.alpha = 1;
					tankman.visible = false;
				});

				cutsceneHandler.timer(20, function()
				{
					camFollow.set(dad.x + 500, dad.y + 170);
				});

				cutsceneHandler.timer(31.2, function()
				{
					boyfriend.playAnim('singUPmiss', true);
					boyfriend.animation.finishCallback = function(name:String)
					{
						if (name == 'singUPmiss')
						{
							boyfriend.playAnim('idle', true);
							boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
						}
					};

					camFollow.set(boyfriend.x + 280, boyfriend.y + 200);
					cameraSpeed = 12;
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
				});
			cutsceneHandler.timer(32.2, function() {
				zoomBack();
			});
		}
	}

	var talkingLeft:Bool = false;
	var bg:FlxSprite;

	// New dialogue system :O
	/*function coolIntro(dList:Array<String>):Void {
		skipCount = 0;

		// PRECACHE STUFF
		precacheList.set('dialogueStuffs/clickText', 'sound');
		precacheList.set('dialogueStuffs/dialogue', 'sound');
		precacheList.set('Results \'115', 'music');

		//inCutscene = true;

		var expression:Array<String> = [
			'normal',
			'happy',
			'sad',
			'angry',
			'mad',
			'crying',
			'gloomy',
			'scared',
			'sighing',
			'cool',
			'epic',
			'excited',
			'shocked',
			'surprised'
		];

		dPortrait = new FlxSprite(600, 100).loadGraphic(Paths.image('dialogueStuffs/portraits/placeholder-' + expression[0]));
		dPortrait.alpha = 0;
		dPortrait.cameras = [camOther];
		dPortrait.flipX = talkingLeft;
		dPortrait.x = talkingLeft ? 200 : 600;
		
		dBox.frames = Paths.getSparrowAtlas('dialogueStuffs/dBox');
		dBox.antialiasing = true;
		dBox.animation.addByPrefix('spawn', 'dBox spawn', 24, false); // placeholder: 12
		dBox.animation.add('loop', [5, 6, 7, 8, 9]);
		dBox.animation.addByPrefix('idle', 'dBox idle', 0, false); // placeholder: 0
		dBox.animation.addByPrefix('close', 'dBox close', 24, false); // placeholder: 22
		dBox.screenCenter(X);
		dBox.alpha = 0;
		dBox.cameras = [camOther];

		var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width,FlxG.width,FlxColor.BLACK);
		if (isPostDialogue) black.alpha = 0;
		bg = new FlxSprite().makeGraphic(FlxG.width,FlxG.width,0xFF64FFFF); //loadGraphic(Paths.image("dialogueStuffs/dialogueBG"));
		bg.alpha = 0;
		//bg.blend = SUBTRACT;
		bg.cameras = [camOther];
		black.cameras = [camOther];
		add(black);
		add(bg);
		add(dPortrait);
		add(dBox);

		coolDialogueText = new FlxTypeText(300, 470, Std.int(FlxG.width * 0.5), "", 24, true);
		coolDialogueText.color = 0xFF001932;
		coolDialogueText.font = Paths.font('coolText.ttf');
		coolDialogueText.cameras = [camOther];
		coolDialogueText.sounds = [FlxG.sound.load(Paths.sound('dialogueStuffs/dialogue'))];
		add(coolDialogueText);

		//coolDialogueText.text = dList[skipCount];

		var finished:Bool = false;

		FlxTween.tween(bg,{alpha: 0.125},0.5,{
			startDelay: SONG.song != "Car Tires" ? 0.25 : 1.5,
			onComplete: function(twn:FlxTween) {
				dBox.alpha = 1;
				dPortrait.alpha = 1;
				FlxG.sound.play(Paths.sound('dialogueStuffs/clickText'));
				coolDialogueText.prefix = "BF: ";
				coolDialogueText.start(0.035, true);
				coolDialogueText.resetText(dList[skipCount]);
				if (!finished) {
					coolDialogueText.resetText(dList[skipCount]);
					dBox.animation.play('spawn', false);
					finished = true;
				}
				dBox.animation.play('loop', true);
			}
		});

		if (SONG.song == "Car Tires" && !startedCountdown) {
			if (!isPostDialogue) {
				FlxTween.tween(black, {alpha: 0}, 1.5);
			}
		}
	}

	function epicIntro(dList:Array<String>):Void {
		skipCount = 0;

		// PRECACHE STUFF
		precacheList.set('dialogueStuffs/clickText', 'sound');
		precacheList.set('dialogueStuffs/dialogue', 'sound');
		precacheList.set('Results \'115', 'music');

		//inCutscene = true;

		var talkingLeft:Bool = true;
		var expression:Array<String> = [
			'normal',
			'happy',
			'sad',
			'angry',
			'mad',
			'crying',
			'gloomy',
			'scared',
			'sighing',
			'cool',
			'epic',
			'excited',
			'shocked',
			'surprised'
		];

		dPortrait = new FlxSprite(600, 100).loadGraphic(Paths.image('dialogueStuffs/portraits/placeholder-' + expression[0]));
		dPortrait.alpha = 0;
		dPortrait.cameras = [camOther];
		dPortrait.flipX = talkingLeft;
		dPortrait.x = talkingLeft ? 200 : 600;
		
		dBox.frames = Paths.getSparrowAtlas('dialogueStuffs/dBox');
		dBox.antialiasing = true;
		dBox.animation.addByPrefix('spawn', 'dBox spawn', 24, false); // placeholder: 12
		dBox.animation.add('loop', [5, 6, 7, 8, 9]);
		dBox.animation.addByPrefix('idle', 'dBox idle', 0, false); // placeholder: 0
		dBox.animation.addByPrefix('close', 'dBox close', 24, false); // placeholder: 22
		dBox.screenCenter(X);
		dBox.alpha = 0;
		dBox.cameras = [camOther];
		dBox.color = FlxColor.fromRGB(255,255,0);

		var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width,FlxG.width,FlxColor.BLACK);
		if (isPostDialogue) black.alpha = 0;
		bg = new FlxSprite().makeGraphic(FlxG.width,FlxG.width,0xFFFFFF64); //loadGraphic(Paths.image("dialogueStuffs/dialogueBG"));
		bg.alpha = 0;
		//bg.blend = SUBTRACT;
		bg.cameras = [camOther];
		black.cameras = [camOther];
		add(black);
		add(bg);
		add(dPortrait);
		add(dBox);

		coolDialogueText = new FlxTypeText(300, 470, Std.int(FlxG.width * 0.5), "", 24, true);
		coolDialogueText.color = 0xFF321900;
		coolDialogueText.font = Paths.font('epicText.ttf');
		coolDialogueText.cameras = [camOther];
		coolDialogueText.sounds = [FlxG.sound.load(Paths.sound('dialogueStuffs/dialogue'))];
		add(coolDialogueText);

		//coolDialogueText.text = dList[skipCount];

		var finished:Bool = false;

		FlxTween.tween(bg,{alpha: 0.125},0.5,{
			startDelay: SONG.song != "Car Tires" ? 0.25 : 1.5,
			onComplete: function(twn:FlxTween) {
				dBox.alpha = 1;
				dPortrait.alpha = 1;
				FlxG.sound.play(Paths.sound('dialogueStuffs/clickText'));
				coolDialogueText.prefix = "BF: ";
				if (!finished) {
					coolDialogueText.resetText(dList[skipCount]);
					coolDialogueText.resetText(dList[skipCount]);
					coolDialogueText.resetText(dList[skipCount]);
					coolDialogueText.start(0.035, true);
					dBox.animation.play('spawn', false);
					finished = true;
				}
				dBox.animation.play('loop', true);
			}
		});

		if (SONG.song == "Car Tires" && !startedCountdown) {
			if (!isPostDialogue) {
				FlxTween.tween(black, {alpha: 0}, 1.5);
			} else {
				FlxTween.tween(black, {alpha: 0}, 0.0000001);
			}
		}
	}*/

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

		var introAlts:Array<String> = introAssets.get('default');
		if (isPixelStage) introAlts = introAssets.get('pixel');
		
		for (asset in introAlts)
			Paths.image(asset);
		
		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', [], false);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if(startOnTime < 0) startOnTime = 0;

			if (skipCountdown) return;

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer) {
				// GIRLFRIEND
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned) {
					gf.dance();
				}
				// PLAYER 1
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned) {
					boyfriend.dance();
				}
				// PLAYER 2
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned) {
					dad.dance();
				}
				// PLAYER 3
				if (tmr.loopsLeft % mom.danceEveryNumBeats == 0 && mom.animation.curAnim != null && !mom.animation.curAnim.name.startsWith('sing') && !mom.stunned) {
					mom.dance();
				}
				// PLAYER 4
				if (tmr.loopsLeft % pico.danceEveryNumBeats == 0 && pico.animation.curAnim != null && !pico.animation.curAnim.name.startsWith('sing') && !pico.stunned) {
					pico.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);

					bottomBoppers.dance(true);
					santa.dance(true);
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
					case 1:
						countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownReady.cameras = [camOther];
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						insert(members.indexOf(notes), countdownReady);
						FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 2:
						countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownSet.cameras = [camOther];
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						insert(members.indexOf(notes), countdownSet);
						FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 3:
						countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						countdownGo.cameras = [camOther];
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						insert(members.indexOf(notes), countdownGo);
						FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
					FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(ClientPrefs.middleScroll && !note.mustPress) {
							note.alpha *= 0.35;
						}
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}

	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}

	public function addBehindDad(obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function addBehindMom(obj:FlxObject)
	{
		insert(members.indexOf(momGroup), obj);
	}

	public function addBehindPico(obj:FlxObject)
	{
		insert(members.indexOf(picoGroup), obj);
	}
	
	public function clearNotesBefore(time:Float) // Thought it would be good to remove the "- 350"
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function updateScore(missed:Bool = false)
	{
		if (!tankerKrakenTransformed) {
			scoreTxt.text = 'Score: ' + songScore
			+ ' | Misses: ' + songMisses
			+ ' | Rating: ' + ratingName
			+ (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC'/* + " | " + ratingPercent + "%" */: '');
		} else {
			scoreTxt.text = 'Score: ' + songScore
			+ ' | Misses: ' + songMisses
			+ ' | Rating: ' + ratingName
			+ (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC'/* + " | " + ratingPercent + "%" */: '');
		}

		if (ClientPrefs.scoreZoom && !missed && !cpuControlled) {
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				ease: FlxEase.expoOut,
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
		callOnLuas('onUpdateScore', [missed]);
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxTween.tween(FlxG.sound.music, {time: time}, 0.0000125, {ease: FlxEase.expoOut}); // Better
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		clearNotesBefore(time); // Clears notes before

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = playbackRate;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();

		if(startOnTime > 0) setSongTime(startOnTime - 500);
		startOnTime = 0;

		if(paused) {
			// trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: ClientPrefs.hudAlpha}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: ClientPrefs.hudAlpha}, 0.5, {ease: FlxEase.circOut});

		switch(curStage) {
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		var fpsSpeed:Float = (ClientPrefs.framerate/ClientPrefs.framerate)*SONG.speed;

		switch(songSpeedType) {
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
				/* if (SONG.song == "Ceased") {
					if (ratingPercent < 0.95) {
						songSpeed = 4;
					} else {
						songSpeed = 3.2;
					}
				} */
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
				/* if (SONG.song == "Ceased") {
					if (ratingPercent < 0.95) {
						songSpeed = 4;
					} else {
						songSpeed = 3.2;
					}
				} */
			case "fps":
				songSpeed = fpsSpeed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
				/* if (SONG.song == "Ceased") {
					if (ratingPercent < 0.95) {
						songSpeed = 4;
					} else {
						songSpeed = 3.2;
					}
				} */
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) // Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				if (startLocked) daNoteData = Std.int(songNotes[1] % 8);

				var gottaHitNote:Bool = section.mustHitSection;

				if (!startLocked) {
					if (songNotes[1] > 3)
					{
						gottaHitNote = !section.mustHitSection;
					}
				} else {
					if (songNotes[1] > 7)
					{
						gottaHitNote = !section.mustHitSection;
					}
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				if (startLocked) swagNote.gfNote = (section.gfSection && (songNotes[1]<8));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; // Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData % 8, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						if (startLocked) sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) // Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) // Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) // Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByTime);
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Dadbattle Spotlight':
				dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.25;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BGSprite('spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;

				dadbattleSmokes.alpha = 0.7;
				dadbattleSmokes.blend = ADD;
				dadbattleSmokes.visible = false;
				add(dadbattleLight);
				add(dadbattleSmokes);

				var offsetX = 200;
				var smoke:BGSprite = new BGSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(15, 22);
				smoke.active = true;
				dadbattleSmokes.add(smoke);
				var smoke:BGSprite = new BGSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(-15, -22);
				smoke.active = true;
				smoke.flipX = true;
				dadbattleSmokes.add(smoke);


			case 'Philly Glow':
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				insert(members.indexOf(phillyStreet), blammedLightsBlack);

				phillyWindowEvent = new BGSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);


				phillyGlowGradient = new PhillyGlow.PhillyGlowGradient(-400, 225); // This shit was refusing to properly load FlxGradient so fuck it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);
				if(!ClientPrefs.flashing) phillyGlowGradient.intendedAlpha = 0.7;

				precacheList.set('philly/particle', 'image'); // precache particle image
				phillyGlowParticles = new FlxTypedGroup<PhillyGlow.PhillyGlowParticle>();
				phillyGlowParticles.visible = false;
				insert(members.indexOf(phillyGlowGradient) + 1, phillyGlowParticles);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Null<Float> = callOnLuas('eventEarlyTrigger', [event.event, event.value1, event.value2, event.strumTime], [], [0]);
		if(returnedValue != null && returnedValue != 0 && returnedValue != FunkinLua.Function_Continue) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': // Better timing so that the kill sound matches the beat intended
				return 280; // Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; // for lua
	private function generateStaticArrows(player:Int):Void {
		if (!startLocked) {
			for (i in 0...4) {
				// FlxG.log.add(i);
				var targetAlpha:Float = ClientPrefs.hudAlpha;
				if (player < 1) if(!ClientPrefs.opponentStrums || ClientPrefs.middleScroll) targetAlpha = 0;

				var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
				babyArrow.downScroll = ClientPrefs.downScroll;
				if (!skipArrowStartTween) {
					babyArrow.y -= 10;
					babyArrow.alpha = 0;
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.25 + (0.1 * i)});
				} else {
					babyArrow.alpha = targetAlpha;
				}

				if (player == 1) {
					playerStrums.add(babyArrow);
				} else {
					if(ClientPrefs.middleScroll) {
						babyArrow.x += 310;
						if(i > 1) { // Up and Right
							babyArrow.x += FlxG.width / 2 + 25;
						}
					}
					opponentStrums.add(babyArrow);
				}

				strumLineNotes.add(babyArrow);
				babyArrow.postAddedToGroup();
			}
		} else { // 8 keys
			for (i in 0...8) {
				// FlxG.log.add(i);
				var targetAlpha:Float = ClientPrefs.hudAlpha;
				if (player < 1) if(!ClientPrefs.opponentStrums || ClientPrefs.middleScroll) targetAlpha = 0;

				var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
				babyArrow.downScroll = ClientPrefs.downScroll;
				if (!skipArrowStartTween) {
					babyArrow.y -= 10;
					babyArrow.alpha = 0;
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.25 + (0.1 * i)});
				} else {
					babyArrow.alpha = targetAlpha;
				}

				if (player == 1) {
					playerStrums.add(babyArrow);
				} else {
					if(ClientPrefs.middleScroll) {
						babyArrow.x += 310;
						if(i > 3) { // Up and Right
							babyArrow.x += FlxG.width / 2 + 25;
						}
					}
					opponentStrums.add(babyArrow);
				}

				strumLineNotes.add(babyArrow);
				babyArrow.postAddedToGroup();
			}
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);

		FlxG.sound.music.pause();
		vocals.pause();
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		vocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	public static function preloadSong(canPreload:Bool = false) {
		var songName:String = Paths.formatToSongPath(SONG.song);
		if (canPreload) {
			Paths.image("NOTE_assets", "shared");
			//precacheList.set('NOTE_assets', 'shared_image');

			if (CoolUtil.difficultyString().toLowerCase() != 'normal') {
				Paths.json(songName + "/" + songName + CoolUtil.getDifficultyFilePath());
			} else {
				Paths.json(songName + "/" + songName);
				trace('No difficulty found, it is either null or normal');
			}

			Paths.inst(songName);
			Paths.voices(songName);
			
			if (CoolUtil.difficultyString().toLowerCase() != 'normal') {
				trace(Paths.json(songName + "/" + songName + CoolUtil.getDifficultyFilePath()));
			} else {
				trace(Paths.json(songName + "/" + songName));
			}

			trace(Paths.inst(songName));
			trace(Paths.voices(songName));

			Paths.sound('hitsound');
		} else {
			if (songName == null) {
				throw "file_contents:./"+Paths.json(songName + "/" + songName);
				Sys.exit(1);
			} else {
				trace('Nothing was preloaded');
			}
		}
	}

	// Fades to black before we teleport to the results screen
	public function rollWeekBefore() {
		var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width,FlxG.width,FlxColor.BLACK);
		black.alpha = 0;
		black.cameras = [camOther];
		add(black);
		FlxTween.tween(black, {alpha: 1}, 0.75, {
			onComplete: function(twn:FlxTween) {
				openSubState(new ResultsSubState());
			}
		});
	}

	override public function update(elapsed:Float)
	{
		callOnLuas('onUpdate', [elapsed]);

		// Just a check
		// trace(isPostDialogue);

		// Story stuff (SCRAPPED)
		/*switch(SONG.song) {
			case "Car Tires":
				if (isPostDialogue) {
					dialogueList = [
						"HEUHEUH, HEUHEUH!",
						"I finally won. Now, All I have to do is get my 100 million dollars by buying an entire company.",
						"*sigh* We're leaving.",
						"Why?",
						"Tomorrow, when you don't have a Job, there is always a reason to open up a place.",
						"Tanker, Money isn't everything. You have other stuff that you love, like your shop!",
						"My shop stand is wonderful.",
						"Go check out our shop!",
						"NO!",
						"Why?",
						"I bet your items have garbage prices, so too bad.",
						"*sigh* I guess I won't get the money then.",
						"Also, Your garbage shop stand needs more work, because there is a reason to fix up the prices too.",
						"Oh yeah. I could do that.",
						"I'll help!",
						"Thanks for rap battling me though!",
						"You're welcome.",
						"And I don't want to see you ever again."
					];
					weekEnded = true;
				}
				if (FlxG.save.data.fakeBillFound) SONG = Song.loadFromJson('plenitudinous-savant', 'plenitudinous');
				if (ratingPercent <= 0.75 && ratingName != '?') isPostDialogue = true;
			case "Uncease":
				if (isPostDialogue) {
					dialogueList = [
						"I AM LEAVING!",
						"Me too.",
						"WAIT! Don't leave! I just wanted to show you something.",
						"What is it?",
						"Mr. wonk.",
						"WHO is Mr. wonk?",
						"*wheezes* You got me! Mr. wonk doesn't exist!",
						"Lame.",
						"Why LAME!?",
						"Because your jokes are not funny at all.",
						"Let's go home.",
						"You can't go home. I own it now, because I bought it",
						"NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO!!"
					];
					weekEnded = true;
				}
				weekEnded = false;
				if (ratingPercent < 0.75 && ratingName != '?') isPostDialogue = true;
			case "Ceased":
				if (ratingPercent < 0.75 && ratingName != '?' && isStoryMode && !chartingMode) {
					dialogueList = [
						"Heuheuhhhhh! I just saw a building!",
						"I know.",
						"*gasp* Boyfriend, We MUST go there, immediately!",
						"No way!",
						"WE COULD WIN 100 MILLION DOLLARS IN A GRAND ROUND!",
						"I can't wait! HEUHEUH!",
						"If you win, we're leaving.",
						"Heh, sure!",
						"You're giving me a headache all of a sudden because of your heuheuh sounds.",
						"I know.",
						"Heuh, HEUUUUUUUUUUUU",
						"OW! MY HEAD!",
						"Let's go.",
						"Before we go, can I have your microphone Tanker?",
						"NO! HEUHEUUUUUUUUU",
						"AAAAAGHHH!",
						"CHILL OUT WITH THAT NOISE! NOW!",
						"(Boyfriend and girlfriend are walking up to Music contest inc. What's next?)",
						"We should go to the rap song category!",
						"Good idea!",
						"(Tanker then makes a noise once again.)",
						"Hello, fella peasents! My name is Tanker Kraken Tanker Kraken.",
						"I mean, Tanker. And today, we're gonna be rap battling these two guests, boyfriend and girlfriend.",
						"Mhm.",
						"And we're gonna be doing a 9 minute song.",
						"9 MINUTES!?! That's crazy!",
						"I know. Now let's get going!"
					];
					weekEnded = true;
				} else {
					dialogueList = [
						"Heuheuhhhhh! I just saw a building!",
						"I know.",
						"*gasp* Boyfriend, We MUST go there, immediately!",
						"No way!",
						"WE COULD WIN 100 MILLION DOLLARS IN A GRAND ROUND!",
						"I can't wait! HEUHEUH!",
						"If you win, we're leaving.",
						"Heh, sure!",
						"You're giving me a headache all of a sudden because of your heuheuh sounds.",
						"I know.",
						"Heuh, HEUUUUUUUUUUUU",
						"OW! MY HEAD!",
						"Let's go.",
						"Before we go, can I have your microphone Tanker?",
						"NO! HEUHEUUUUUUUUU",
						"AAAAAGHHH!",
						"CHILL OUT WITH THAT NOISE! NOW!",
						"(Boyfriend and girlfriend are walking up to Music contest inc. What's next?)",
						"We should go to the rap song category!",
						"No. Let's go to the DNB song category.",
						"Why?",
						"Because you won at your 2 songs, and I don't want to beat you at the contest anymore.",
						"Let's just go ourselves.",
						"Fine then. I'll just go to the rap song category myself."
					];
					if (weekEnded) health = 0; // Kills you if the accuracy is under 75%
				}
				if (ratingPercent < 0.95 && ratingName != '?' && isStoryMode && !chartingMode) weekEnded = false;
			case "Diazepam":
				if (ratingPercent < 0.95 && ratingName != '?') {
					dialogueList = [
						"WHY!",
						"WHY WOULD YOU KILL 2 COPS IN A ROW!?",
						"Because HEUHEUH! I don't care.",
						"And I LOVE Money, and I want to recover my new show, Tanker Kraken Entertainment!",
						"So That I can continue airing it!",
						"You're not scamming people again. Are you!?",
						"Yes.",
						"I just scammed ~$5000 for my lambourghini!",
						"AAAAAAAAAAAAARRRGHHH! YOU ARE DRIVING ME CRAZY!",
						"Here, take this diazepam. Ok?",
						"I don't want to take that stupid diazepam.",
						"HOW DO YOU EVEN SURVIVE DRINKING THAT STUFF!?",
						"Because I'm a middle-aged adult, and you are just a little tiny kid.",
						"Just, a little itty bitty tiny child...",
						"I'm 26!",
						"AND I'M 19!! I'M SHORT BECAUSE I HAVE A DISABILITY, OBVIOUSLY.",
						"Tanker, don't make fun of boyfriend's height. It's not very nice.",
						"Now who wants to start the second song?",
						"Us!",
						"Okay then.",
						"I was born in July 19th, 2003.",
						"Happy birthda-",
						"IT'S NOT MY BIRTHDAY!!",
						"CAN WE START THIS SONG ALREADY!?",
						"Yes we can.",
						"What about the cops tho?",
						"Heuheuh! I'm going to sell them for millions of dollars!",
						"But, humans are only worth $40000 or something.",
						"Even better...",
						"$7235000000000!",
						"That's insane! That would be 14.4 Trillion for 2 people!",
						"I learned it from my school in 11th grade.",
						"That is human life, not human body.",
						"A dead one is $550000 and the one alive is $45000000",
						"That's not true, boyfriend.",
						"*sigh* Let's just get this over with and stop talking. We don't wanna waste time here, Ok?"
					];
					weekEnded = false;
				} else {
					dialogueList = [
						"WHY!",
						"WHY WOULD YOU KILL 2 COPS IN A ROW!?",
						"Because HEUHEUH! I don't care.",
						"And I LOVE Money, and I want to recover my new show, Tanker Kraken Entertainment!",
						"So That I can continue airing it!",
						"You're not scamming people again. Are you!?",
						"Yes.",
						"I just scammed ~$5000 for my lambourghini!",
						"AAAAAAAAAAAAARRRGHHH! YOU ARE DRIVING ME CRAZY!",
						"Here, take this diazepam. Ok?",
						"I don't want to take that stupid diazepam.",
						"HOW DO YOU EVEN SURVIVE DRINKING THAT STUFF!?",
						"Because I'm a middle-aged adult, and you are just a little tiny kid.",
						"I'm 26!",
						"AND I'M 19!! I'M SHORT BECAUSE I HAVE A DISABILITY, OBVIOUSLY.",
						"Tanker, don't make fun of boyfriend's height. It's not very nice.",
						"Now who wants to start the second song?",
						"Us!",
						"Okay then.",
						"I was born in July 19th, 2003.",
						"Happy birthd-",
						"IT'S NOT MY BIRTHDAY!!",
						"CAN WE START THIS SONG ALREADY!?",
						"We're out.",
						"Yeah, I don't feel like singing again. I'm afraid that Tanker's gonna steal our stuff...",
						"I agree! Let's go home.",
						"(BF & GF leave the building and walk back home.)",
						"(Tanker then gets very upset, because he won.)",
						"...",
						"I guess I won't get the money then."
					];
					weekEnded = true;
				}
				if (isPostDialogue) {
					dialogueList = [
						"WHY!",
						"WHY WOULD YOU KILL 2 COPS IN A ROW!?",
						"Because HEUHEUH! I don't care.",
						"And I LOVE Money, and I want to recover my new show, Tanker Kraken Entertainment!",
						"So That I can continue airing it!",
						"You're not scamming people again. Are you!?",
						"No.",
						"Well, you usually scam people. What happened to you?",
						"I changed my mind. I ain't doing crimes anymore. They're over.",
						"Well I'm glad.",
						"That's because I wanted to make 100 million dollars, and you said I killed two cops and a dog.",
						"I'M SUCH A MURDERER!! WHY DID I DO THIS!?",
						"Because you're insane! Why did you do that anyway?",
						"Tina figured out a way to undo my brain activity after I killed 2 cops and a dog, so yeah, no more doing crimes.",
						"I will NOW make actual money, and You'll find out when I have 100 million dollars.",
						"So, You will come back after a couple years?",
						"YEAH! HEUHEUH!"
					];
					weekEnded = true;
				}
				if (ratingPercent <= 0.75 && ratingName != '?') {
					if (endingSong) fadeAndEndSong('savant', 'the-cool-contest');
				} else {
					if (endingSong) fadeAndEndSong('hard', 'the-cool-contest');
				}
				if (ratingPercent < 0.95 && ratingName != '?') {
					isPostDialogue = true;
					weekEnded = false;
					if (endingSong) fadeAndEndSong('', 'stadium-rave');
				}
			case "Stadium Rave":
				if (ratingPercent > 0.75 && ratingName != '?' && isStoryMode && !chartingMode) weekEnded = true;
		}*/

		// Dialogue stuff
		/*if (!startedCountdown) { // Just an if condintion when countdown didn't start yet
			// next
			if (controls.ACCEPT && skipCount != dialogueList.length) {
				//trace(skipCount);
				skipCount++;
				FlxG.sound.play(Paths.sound('dialogueStuffs/clickText'));
				coolDialogueText.resetText(dialogueList[skipCount]);
				//coolDialogueText.skip();
				coolDialogueText.start(0.035, true);
			}
			// end
			if (skipCount == dialogueList.length && controls.ACCEPT) { // Don't change this.
				var finished:Bool = false;
				remove(coolDialogueText);
				if (!finished) {
					skipCount = 0;
					//FlxG.sound.play(Paths.sound('dialogueStuffs/clickText'));
					dBox.animation.play('close');
					finished = true;
				} else {
					finished = true;
				}
				FlxTween.tween(dPortrait, {alpha: 0}, 0.5);
				FlxTween.tween(bg, {alpha: 0}, 0.5, {
					onComplete: function(twn:FlxTween) {
						remove(dBox);
						remove(dPortrait);
						if (!weekEnded) {
							startCountdown();
						} else {
							if (weekEnded && SONG.song != "Diazepam") rollWeekBefore();
							if (SONG.song == "Diazepam") fadeAndEndSong('', 'stadium-rave');
						}
					}
				});
			}
		}*/

		/*switch(curDCharacter) {
			case "bf" | "gf":
				flipPortrait = false;
			case "tanker" | "tanker-insane" | "cop-1" | "cop-2":
				flipPortrait = true;
		}*/

		// Modchart Stuff
		if (!startLocked) {
			for (i in 0...8) {
				if (modchartInitialized && !startingSong) {
					if (modchartType1) strumLineNotes.members[i].y = strumLineNotes.members[i].y + Math.sin(FlxG.game.ticks / 1000 + (350 * i)) / (8 - (i / 4));
					if (modchartType2) {
						strumLineNotes.members[i].x = strumLineNotes.members[i].x - Math.sin(FlxG.game.ticks / 150 + (60 * i) - i) / 3;
						strumLineNotes.members[i].y = strumLineNotes.members[i].y - Math.cos(FlxG.game.ticks / 150 + (5 + i) * i) / 6;
					}
					if (modchartType3) {
						strumLineNotes.members[i].x = strumLineNotes.members[i].x - Math.sin(FlxG.game.ticks / 350) * (1+i / 8);
						strumLineNotes.members[i].y = strumLineNotes.members[i].y - Math.sin(FlxG.game.ticks / 350 * (1+i / 4)) * (1+i / 2);
					}
				}
			}
		} else {
			for (i in 0...16) {
				if (modchartInitialized && !startingSong) {
					if (modchartType1) strumLineNotes.members[i].y = strumLineNotes.members[i].y + Math.sin(FlxG.game.ticks / 1000 + (350 * i)) / (8 - (i / 8));
					if (modchartType2) {
						strumLineNotes.members[i].x = strumLineNotes.members[i].x - Math.sin(FlxG.game.ticks / 150 + (60 * i) - i) / 6;
						strumLineNotes.members[i].y = strumLineNotes.members[i].y - Math.cos(FlxG.game.ticks / 150 + (5 + i) * i) / 12;
					}
					if (modchartType3) {
						strumLineNotes.members[i].x = strumLineNotes.members[i].x - Math.sin(FlxG.game.ticks / 350) * (1+i / 16);
						strumLineNotes.members[i].y = strumLineNotes.members[i].y - Math.sin(FlxG.game.ticks / 350 * (1+i / 8)) * (1+i / 2);
					}
				}
			}
		}

		if (SONG.song == "The Cool Contest") {
			if (health < 0 && canDie && missed) {
				health = 0;
			}
		}

		switch (curStage)
		{
			case 'tank':
				moveTank(elapsed);
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;

				if(phillyGlowParticles != null)
				{
					var i:Int = phillyGlowParticles.members.length-1;
					while (i > 0)
					{
						var particle = phillyGlowParticles.members[i];
						if(particle.alpha < 0)
						{
							particle.kill();
							phillyGlowParticles.remove(particle, true);
							particle.destroy();
						}
						--i;
					}
				}
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 170) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		#if FLX_NO_DEBUG
		if (controls.PAUSE && startedCountdown && canPause && !modchartInitialized)
		{
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if(ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}
		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene && !modchartInitialized) {
			cancelMusicFadeTween();
			openChartEditor();
		}
		#else
		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if(ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}
		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene) {
			cancelMusicFadeTween();
			openChartEditor();
		}
		#end

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		final iconOffset:Int = 22;

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP1.scale.set(mult, mult);
		//iconP2.updateHitbox();
		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
		iconP1.y = healthBar.y - (75 / iconP1.scale.y);
		iconP2.y = healthBar.y - (75 / iconP2.scale.y);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene && !modchartInitialized) {
			persistentUpdate = false;
			paused = true;

			if (FlxG.keys.pressed.SHIFT)
			MusicBeatState.switchState(new CharacterEditorState(SONG.player1));
			else
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}
		
		if (startedCountdown) {
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
		}

		if (startingSong) {
			if (startedCountdown && Conductor.songPosition >= 0) startSong();
			else if(!startedCountdown) Conductor.songPosition = -Conductor.crochet * 5;
		} else {
			if (!paused) {
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition) {
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name') timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming) {
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		FlxG.watch.addQuick("Elapsed", FlxG.elapsed);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong && canDie) {
			health = 0;
			missed = true;
			trace("RESET = True");
		}
		if (missed) doDeathCheck();

		if (unspawnNotes[0] != null) {
			var time:Float = spawnTime;
			//if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time) {
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned = true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if(!inCutscene)
			{
				if(!cpuControlled) {
					keyShit();
				} else if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
					boyfriend.dance();
					//boyfriend.animation.curAnim.finish();
				}

				if(startedCountdown)
				{
					var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
					notes.forEachAlive(function(daNote:Note)
					{
						var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
						if(!daNote.mustPress) strumGroup = opponentStrums;

						var strumX:Float = strumGroup.members[daNote.noteData].x;
						var strumY:Float = strumGroup.members[daNote.noteData].y;
						var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
						var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
						var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
						var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

						strumX += daNote.offsetX;
						strumY += daNote.offsetY;
						strumAngle += daNote.offsetAngle;
						strumAlpha *= daNote.multAlpha;

						if (strumScroll) //Downscroll
						{
							//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
							daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
						}
						else //Upscroll
						{
							//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
							daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
						}

						var angleDir = strumDirection * Math.PI / 180;
						if (daNote.copyAngle)
							daNote.angle = strumDirection - 90 + strumAngle;

						if(daNote.copyAlpha)
							daNote.alpha = strumAlpha;

						if(daNote.copyX)
							daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

						if(daNote.copyY) {
							daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

							//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
							if(strumScroll && daNote.isSustainNote)
							{
								if (daNote.animation.curAnim.name.endsWith('end')) {
									daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
									daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
									if(PlayState.isPixelStage) {
										daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
									} else {
										daNote.y -= 19;
									}
								}
								daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
								daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
							}
						}

						//var noteDiff = Math.abs(daNote.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
						if (daNote.strumTime < Conductor.songPosition && !daNote.mustPress && (!daNote.hitByOpponent && !daNote.ignoreNote)) {
							opponentNoteHit(daNote);
						}

						if(!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit) {
							if(daNote.isSustainNote) {
								if(daNote.canBeHit) {
									goodNoteHit(daNote);
								}
							} else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote) {
								goodNoteHit(daNote);
							}
						}

						var center:Float = strumY + Note.swagWidth / 2;
						if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
							(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							if (strumScroll)
							{
								if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
								{
									var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
									swagRect.height = (center - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
								{
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (center - daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
						}

						// Kill extremely late notes and cause misses
						if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
						{
							if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
								noteMiss(daNote);
							}

							daNote.active = false;
							daNote.visible = false;

							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					});
				}
				else
				{
					notes.forEachAlive(function(daNote:Note)
					{
						daNote.canBeHit = false;
						daNote.wasGoodHit = false;
					});
				}
			}
			checkEventNote();
		}

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			cancelMusicFadeTween();
			MusicBeatState.switchState(new GitarooPause());
		}
		else {*/
		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		//}

		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();

		if (!startLocked)
		MusicBeatState.switchState(new ChartingState());
		else
		MusicBeatState.switchState(new ChartingState8K());

		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead && canDie && missed)
		{
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				return;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Dadbattle Spotlight':
				var val:Null<Int> = Std.parseInt(value1);
				if(val == null) val = 0;

				switch(Std.parseInt(value1))
				{
					case 1, 2, 3: //enable and target dad
						if(val == 1) //enable
						{
							dadbattleBlack.visible = true;
							dadbattleLight.visible = true;
							dadbattleSmokes.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if(val > 2) who = boyfriend;
						//2 only targets dad
						dadbattleLight.alpha = 0;
						new FlxTimer().start(0.12, function(tmr:FlxTimer) {
							dadbattleLight.alpha = 0.375;
						});
						dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);

					default:
						dadbattleBlack.visible = false;
						dadbattleLight.visible = false;
						defaultCamZoom -= 0.12;
						FlxTween.tween(dadbattleSmokes, {alpha: 0}, 1, {onComplete: function(twn:FlxTween)
						{
							dadbattleSmokes.visible = false;
						}});
				}

			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Philly Glow':
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				var doFlash:Void->Void = function() {
					var color:FlxColor = FlxColor.WHITE;
					if(!ClientPrefs.flashing) color.alphaFloat = 0.5;

					FlxG.camera.flash(color, 0.15, null, true);
				};

				var chars:Array<Character> = [boyfriend, gf, dad];
				switch(lightId)
				{
					case 0:
						if(phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = false;
							phillyWindowEvent.visible = false;
							phillyGlowGradient.visible = false;
							phillyGlowParticles.visible = false;
							curLightEvent = -1;

							for (who in chars)
							{
								who.color = FlxColor.WHITE;
							}
							phillyStreet.color = FlxColor.WHITE;
						}

					case 1: //turn on
						curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);
						var color:FlxColor = phillyLightsColors[curLightEvent];

						if(!phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = true;
							blammedLightsBlack.alpha = 1;
							phillyWindowEvent.visible = true;
							phillyGlowGradient.visible = true;
							phillyGlowParticles.visible = true;
						}
						else if(ClientPrefs.flashing)
						{
							var colorButLower:FlxColor = color;
							colorButLower.alphaFloat = 0.25;
							FlxG.camera.flash(colorButLower, 0.5, null, true);
						}

						var charColor:FlxColor = color;
						if(!ClientPrefs.flashing) charColor.saturation *= 0.5;
						else charColor.saturation *= 0.75;

						for (who in chars)
						{
							who.color = charColor;
						}
						phillyGlowParticles.forEachAlive(function(particle:PhillyGlow.PhillyGlowParticle)
						{
							particle.color = color;
						});
						phillyGlowGradient.color = color;
						phillyWindowEvent.color = color;

						color.brightness *= 0.5;
						phillyStreet.color = color;

					case 2: // spawn particles
						if(!ClientPrefs.lowQuality)
						{
							var particlesNum:Int = FlxG.random.int(8, 12);
							var width:Float = (2000 / particlesNum);
							var color:FlxColor = phillyLightsColors[curLightEvent];
							for (j in 0...3)
							{
								for (i in 0...particlesNum)
								{
									var particle:PhillyGlow.PhillyGlowParticle = new PhillyGlow.PhillyGlowParticle(-400 + width * i + FlxG.random.float(-width / 5, width / 5), phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40), color);
									phillyGlowParticles.add(particle);
								}
							}
						}
						phillyGlowGradient.bop();
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;

					isCameraOnForcedPos = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();

			case 'BG Freaks Expression':
				if(bgGirls != null) bgGirls.swapDanceType();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / playbackRate, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong;

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}

	public var transitioning = false;
	public function endSong():Void
	{
		// For post dialogue (SCRAPPED)
		/*if (isPostDialogue && isStoryMode) {
			var finished:Bool = false;
			timeTxt.text = '0:00';
			if (!finished) {
				FlxTween.tween(camHUD, {alpha: 0}, 0.75, {onComplete: function(twn:FlxTween) {
					coolIntro(dialogueList);
				}});
				campaignScore += songScore;
				campaignMisses += songMisses;
				finished = true;
			} else {
				finished = true;
			}
			startedCountdown = false;
		}*/

		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			/*var achieve:String = checkForAchievement(['week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss',
				'week5_nomiss', 'week6_nomiss', 'week7_nomiss', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);*/
			var achieve:String = checkForAchievement(['tkrapsong_beaten', 'tkrapsong_beaten_hard', 'tkrapsong_beaten_truehero', 'tkrapsong_thecoolcontestcompleted', 'tkrapsong_demilunecompleted', 'tkrapsong_firstfakebill']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		var ret:Dynamic = callOnLuas('onEndSong', [], false);
		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode) {
				if (!isPostDialogue) {
					campaignScore += songScore;
					campaignMisses += songMisses;
				}

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0) {
					WeekData.loadTheFirstEnabledMod();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
						if (SONG.validScore) Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				} else {
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('HEHE...');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext) {
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;
						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					if (!isPostDialogue) PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			} else {
				trace('WENT BACK TO FREEPLAY??');
				WeekData.loadTheFirstEnabledMod();
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	public function fadeAndEndSong(difficulty:String, jsonInput:String) {
		var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width,FlxG.width,FlxColor.BLACK);
		black.alpha = 0;
		black.cameras = [camOther];
		add(black);
		FlxTween.tween(black, {alpha: 1}, 0.75, {onComplete: function(twn:FlxTween) {
			if (difficulty != '' || difficulty != 'normal') {
				PlayState.SONG = Song.loadFromJson(jsonInput, jsonInput + "-" + difficulty.toLowerCase());
			} else {
				PlayState.SONG = Song.loadFromJson(jsonInput, jsonInput);
			}
			LoadingState.loadAndSwitchState(new PlayState());
		}});
	}

	// This was a thing :skull:
	/* public function completeSong() {
		FlxTween.tween(camHUD, {alpha: 0}, 0.65, {ease: FlxEase.cubeInOut, startDelay: 0.25}); // Camera fade
		var finishCutscene:Void->Void = endSong;
		if (isStoryMode) finishCutscene = schoolIntro;

		switch(SONG.song) {
			case "Ceased":
				notes.forEachAlive(function(note:Note) {
					if (note.ratingMod < 0.75) {
						dialogue = [
							"What's up with all the stolen crap on the floor?!",
							"We found him!",
							"Okay, so let the dog sniff for stolen cash and stuff, so that we can sentence him to prison.",
							"OOOOOOHH, WHAT'S UP!",
							"You're under arrest for robbery.",
							"But I just wanted to be the richest person ever...",
							"Too late, You're done.",
							"YOU'RE SO DONE! You were the most wanted on the criminal list, so Let's go to the police car.",
							"Grrrrrrr... I'll somehow try to find a way to kill you!"
						];
						endSong();
					} else {
						dialogue = [
							"EHEH! WHAT'S UP, BOYFRIEND AND GIRLFRIEND!",
							"Oh, you.",
							"I just killed 2 cops and 1 dog. HEUHEUHEUHEUH!!",
							"GRRAAAAAAHH! You!?!",
							"I'm not kidding or joking, ok? It's real.",
							"I have 1 million dollars.",
							"But you only have 110 grand.",
							"Too late! I just robbed a bank!",
							"YOU WHAT?!!",
							"OOOOOOOOH I get it.",
							"You want me to rap battle you one more time?",
							"YES PLEASE! I don't want to get robbed...",
							"*robs bf and gf* HEUHEUH!",
							"WHYYYYYYYYY!?!?",
							"Now time to rap battle."
						];
					}
				});
			case "Diazepam":
				camGame.zoom == 1;
				notes.forEachAlive(function(note:Note) {
					if (note.ratingMod < 0.75) {
						dialogue = [
							"So, What's up with you? Are you gonna stop robbing things and start making actual money?",
							"Hmm...",
							"...",
							"NAH! HEUHEUH, HAHAHAHAHA! I'M GOING TO BE THE FIRST PERSON TO HAVE A TRILLION DOLLARS!",
							"WHAT!? WHAT THE ACTUAL HELL!?! ARE YOU GONNA ROB EVERYTHING IN MY PURSE!?",
							"Yea, HEUHEUHEUHEUH!",
							"NOOOOOOO! THIS ISN'T HAPPENING! BWAHAHAAAAAAAAAAAAAA!",
							"*sobs*",
							"Boyfriend, it will be alright. Tanker kraken will soon be sorry for that.",
							"I want it to be now...",
							"Come on, let's just leave.",
							"Wait, what are you going!? The crowd's the boo at me more- EUUUUUUUUUUUHH",
							"At least I killed 2 cops and 1 police dog. HEUHEUH! Time to make more money!!"
						];
						camGame.fade(FlxColor.BLACK, 0.75);
						schoolIntro(new DialogueBox(false, [
							"Welcome back, boyfriend and girlfriend... *evil laugh*",
							"TIME TO KILL YOU!",
							"...",
							"WHERE AM I!?!",
							"I sent both of you to the interrigatee, because I'm GOING TO KILL YOU.",
							"Why did you send me here? I did nothing wrong...",
							"Too late! You did something wrong.",
							"What was the wrong tho?",
							"CALLING THE COPS ON ME!",
							"Luckily, I killed 2 of those and a cop dog, so that they won't find out about it.",
							"They will see it!",
							"Is it, Actually the fact that you took my money?",
							"Yes I did, because YOU STOLE IT FROM ME!",
							"OOOOOH you got it.",
							"I can't do this anymore, I just want to GO HOME!",
							"Nope, there is no way to go home.",
							"HEUHEUHEUHEUUUUUUUUHHH!",
							"Oh, You get it.",
							"I AM PISSED OFF AT BOTH OF YOU BECAUSE, YOU THOUGHT I WAS A SCAMMER.",
							"You know what you're talking about."
						]));
					} else {
						dialogue = [
							"So, What's up with you? Are you gonna stop robbing things and start making actual money?",
							"Hmm...",
							"...",
							"Yea, I'm sorry.",
							"Really??",
							"Yes. I realized that robbing things is a crime, so don't worry about my wrongdoings and let's just settle this out.",
							"Oh, so you are gonna start making actual money?",
							"OF COURSE!",
							"Money isn't everything, Tanker. You HAVE to stop robbing things or else the cops will come back.",
							"I KILLED THE COPS...",
							"HOW AM I GONNA BRING THEM BACK??",
							"*sigh* So You obviously stole like 600 credit cards, right?",
							"I'm gonna give them back to the owners anyway",
							"BUT, THAT'S GONNA TAKE A WHOLE WEEK! That would be like being a nonstop worker, right?",
							"Uhuh.",
							"If you give me back my credit card, I will let you join the next contest.",
							"Here it is.",
							"OMG, Thank you so much Tanker for giving us back our credit cards!",
							"And Your driver's licenses.",
							"Absolutely!",
							"Your welcome. Now, can I go in the next contest now?",
							"Sure, just don't rob stuff anymore, because that's wrong.",
							"Alright, I won't.",
							"Wait, what about my purse you stole from me?",
							"Oh, I forgot!",
							"Thank you, Tanker! You are the best of all, yet very rich people in the world.",
							"You're absolutely welcome.",
							"One more thing before we go. Where's my money!?",
							"Oops, it's mixed in.",
							"IDIOT! *bawls*"
						];
						camGame.fade(FlxColor.BLACK, 0.75);
					}
				});
			case "The Cool Contest":
				camGame.zoom == 0.75;
				notes.forEachAlive(function(note:Note) {
					if (note.ratingMod < 0.75) {
						dialogue = ["What's up?", "I'm out."];
					}
				});
		}

		camGame.zoom *= 0.75;

		new FlxTimer().start(1, function(tmr:FlxTimer) {
			finishCutscene();
		});
	} */

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}

	function achievementEnd():Void {
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showRating:Bool = true;

	private function cachePopUpScore() {
		var ratingPath1:String = '';
		var ratingPath2:String = '';
		if (isPixelStage) {
			ratingPath1 = 'pixelUI/';
			ratingPath2 = '-pixel';
		}

		Paths.image(ratingPath1 + "sick" + ratingPath2);
		Paths.image(ratingPath1 + "good" + ratingPath2);
		Paths.image(ratingPath1 + "bad" + ratingPath2);
		Paths.image(ratingPath1 + "shit" + ratingPath2);
		Paths.image(ratingPath1 + "combo" + ratingPath2);
		
		for (i in 0...10) {
			Paths.image(ratingPath1 + 'num' + i + ratingPath2);
		}
	}

	private function popUpScore(note:Note = null):Void {
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(note, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.increase();
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashDisabled) spawnNoteSplashOnNote(note);

		if(!practiceMode) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		var ratingPath1:String = "";
		var ratingPath2:String = '';

		if (PlayState.isPixelStage) {
			ratingPath1 = 'pixelUI/';
			ratingPath2 = '-pixel';
		}

		if (SONG.song == "Car Tires" || SONG.song == "Uncease" || SONG.song == "Ceased" || SONG.song == "Diazepam") {
			ratingPath1 = 'numberspr/cool/';
			ratingPath2 = '-cool';
		}
		if (SONG.song == "Homeless" || SONG.song == "Stadium Rave" || SONG.song == "The Cool Contest") {
			ratingPath1 = 'numberspr/epic/';
			ratingPath2 = '-epic';
		}

		rating.loadGraphic(Paths.image(daRating.image + ratingPath2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 20;
		rating.velocity.y -= 20;
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('combo' + ratingPath2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 20;
		comboSpr.velocity.y -= 20;
		comboSpr.visible = !ClientPrefs.hideHud;
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];
		comboSpr.y += 60;
		comboSpr.velocity.x += 2;

		insert(members.indexOf(strumLineNotes), rating);
		
		if (!ClientPrefs.comboStacking) {
			if (lastRating != null) lastRating.kill();
			lastRating = rating;
		}

		if (!PlayState.isPixelStage) {
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		} else {
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		insert(members.indexOf(strumLineNotes), comboSpr);

		if (!ClientPrefs.comboStacking) {
			if (lastCombo != null) lastCombo.kill();
			lastCombo = comboSpr;
		}

		if (lastScore != null) {
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}
		for (i in seperatedScore) {
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(ratingPath1 + 'num' + Std.int(i) + ratingPath2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];
			
			if (!ClientPrefs.comboStacking)
				lastScore.push(numScore);

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = 20;
			numScore.velocity.y -= 20;
			numScore.visible = !ClientPrefs.hideHud;

			insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.25 / playbackRate, {
				ease: FlxEase.quintIn,
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: 0.3
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		coolText.text = Std.string(seperatedScore);
		//add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.25 / playbackRate, {ease: FlxEase.quintIn, startDelay: 0.25});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.25 / playbackRate, {
			ease: FlxEase.quintIn,
			onComplete: function(tween:FlxTween) {
				coolText.destroy();
				comboSpr.destroy();
				rating.destroy();
			},
			startDelay: 0.35
		});
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (strumsBlocked[daNote.noteData] != true && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else{
					callOnLuas('onGhostTap', [key]);
					if (canMiss) {
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int {
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// New Input System (Real)
	private function keyShit():Void { // Original: https://github.com/MeguminBOT/PsychEngine-TheFatAssModCompilation/blob/main/source/PlayState.hx#L3807
		// HOLDING
		var controlHoldArray:Array<Bool> = [
			controls.NOTE_LEFT,
			controls.NOTE_DOWN,
			controls.NOTE_UP,
			controls.NOTE_RIGHT
		];

		if (startLocked) controlHoldArray = [ // 8K Controls
			controls.NOTE_LEFT1,
			controls.NOTE_DOWN1,
			controls.NOTE_UP1,
			controls.NOTE_RIGHT1,
			controls.NOTE_LEFT2,
			controls.NOTE_DOWN2,
			controls.NOTE_UP2,
			controls.NOTE_RIGHT2
		];
		
		if(ClientPrefs.controllerMode) // Controller Input
		{
			var controlArray:Array<Bool> = [
				controls.NOTE_LEFT_P,
				controls.NOTE_DOWN_P,
				controls.NOTE_UP_P,
				controls.NOTE_RIGHT_P
			];

			if (startLocked) controlArray = [ // 8K Controls
				controls.NOTE_LEFT_P1,
				controls.NOTE_DOWN_P1,
				controls.NOTE_UP_P1,
				controls.NOTE_RIGHT_P1,
				controls.NOTE_LEFT_P2,
				controls.NOTE_DOWN_P2,
				controls.NOTE_UP_P2,
				controls.NOTE_RIGHT_P2
			];

			if(controlArray.contains(true)) {
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		var char:Character = boyfriend;
		if (!char.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit 
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			} else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss') || boyfriend.holdTimer > Conductor.stepCrochet * 0.002 
			* boyfriend.singDuration)
				boyfriend.dance();

			if (controlHoldArray.contains(true) && !endingSong) {} else if (dad.holdTimer > Conductor.stepCrochet * 0.001 * dad.singDuration && dad.animation.curAnim.name.startsWith('sing')
			&& !dad.animation.curAnim.name.endsWith('miss'))
				dad.dance();

			if (controlHoldArray.contains(true) && !endingSong) {} else if (mom.holdTimer > Conductor.stepCrochet * 0.001 * mom.singDuration && mom.animation.curAnim.name.startsWith('sing')
				&& !mom.animation.curAnim.name.endsWith('miss'))
					mom.dance();

			if (controlHoldArray.contains(true) && !endingSong) {} else if (pico.holdTimer > Conductor.stepCrochet * 0.001 * pico.singDuration && pico.animation.curAnim.name.startsWith('sing')
				&& !pico.animation.curAnim.name.endsWith('miss'))
					pico.dance();
		}

		if(ClientPrefs.controllerMode) // Controller Input
		{
			var controlArray:Array<Bool> = [
				controls.NOTE_LEFT_R,
				controls.NOTE_DOWN_R,
				controls.NOTE_UP_R,
				controls.NOTE_RIGHT_R
			];

			if (startLocked) controlArray = [ // 8K Controls
				controls.NOTE_LEFT_R1,
				controls.NOTE_DOWN_R1,
				controls.NOTE_UP_R1,
				controls.NOTE_RIGHT_R1,
				controls.NOTE_LEFT_R2,
				controls.NOTE_DOWN_R2,
				controls.NOTE_UP_R2,
				controls.NOTE_RIGHT_R2
			];

			if(controlArray.contains(true)) {
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	// Old code :skull:
	/*private function keyShit():Void
	{
		var parsedHoldArray:Array<Bool> = parseKeys();

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var parsedArray:Array<Bool> = parseKeys('_P');
			if(parsedArray.contains(true))
			{
				for (i in 0...720)
				{
					if(parsedArray[i] && strumsBlocked[i] != true)
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note) {
				// hold note functions
				if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && parsedHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) goodNoteHit(daNote);
				}
			);

			if (parsedHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode || strumsBlocked.contains(true))
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] || strumsBlocked[i] == true)
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}
		return ret;
	}*/

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		health -= daNote.missHealth * healthLoss;
		missed = true;
		
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating(true);

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData % 8))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void { // You pressed a key when there was no notes to press for this key
		if(ClientPrefs.ghostTapping) return; //fuck it

		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played miss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
		callOnLuas('noteMissPress', [direction]);
	}

	function opponentNoteHit(note:Note):Void {
		if (Paths.formatToSongPath(SONG.song) != 'tutorial') camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if (!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			missed = false;

			var pico:Character = pico; // Player 4
			var mom:Character = mom; // Player 3
			var char:Character = dad;

			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData % 8))] + altAnim;
			
			if(note.gfNote) {
				char = gf;
			}

			if (SONG.song == "Test" && !noMechanics) if (!note.isSustainNote) {
				songScore -= 250;
				updateScore(true);
				health -= note.missHealth * healthLoss;
			}

			if(note.noteType != 'Player 3 Sing' && note.noteType != 'Player 4 Sing' && char != null) {
				if (!note.isSustainNote) char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}

			if(note.noteType == 'Player 3 Sing' && mom != null) { // Player 3 notes
				if (!note.isSustainNote) mom.playAnim(animToPlay, true);
				mom.holdTimer = 0;
			}

			if(note.noteType == 'Player 4 Sing' && pico != null) { // Player 4 notes
				if (!note.isSustainNote) pico.playAnim(animToPlay, true);
				pico.holdTimer = 0;
			}
		}

		if (SONG.needsVoices) vocals.volume = 1;

		var time:Float = 0.135;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.135;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void {
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			missed = false;

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				if(!note.noMissAnimation)
				{
					switch(note.noteType) {
						case 'Hurt Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				if(combo > 9999) combo = 9999;
				health += note.hitHealth * healthGain;
				popUpScore(note);
			}

			if(!note.noAnimation) {
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData % 8))];

				if(note.gfNote)
				{
					if(gf != null)
					{
						if (!note.isSustainNote) gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					if (!note.isSustainNote) boyfriend.playAnim(animToPlay + note.animSuffix, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.135;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.135;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)), time);
			} else {
				var spr = playerStrums.members[note.noteData % 8];
				if(spr != null)
				{
					if(!note.isSustainNote) spr.playAnim('confirm', true);
				}
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData % 8));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData % 8];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;
		if (data > -1 && data < ClientPrefs.arrowHSV.length)
		{
			hue = ClientPrefs.arrowHSV[data][0] / 360;
			sat = ClientPrefs.arrowHSV[data][1] / 100;
			brt = ClientPrefs.arrowHSV[data][2] / 100;
			if(note != null) {
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if (gf != null)
			{
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if(gf != null) {
			gf.danced = false; //Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	var tankX:Float = 400;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0):Void {
		if(!inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	override function destroy() {
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];
		#if hscript
		if(FunkinLua.hscript != null) FunkinLua.hscript = null;
		#end
		if(!ClientPrefs.controllerMode) {
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		FlxAnimationController.globalSpeed = 1;
		FlxG.sound.music.pitch = 1;
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function iconBop() {
		FlxTween.cancelTweensOf(iconP1, ['scale.x', 'scale.y']);
		FlxTween.cancelTweensOf(iconP2, ['scale.x', 'scale.y']);

		// Tweens
		iconP1.scale.set(1.25, 1.25);
		iconP2.scale.set(1.25, 1.25);
		FlxTween.tween(iconP1, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / (1050 / playbackRate), {ease: FlxEase.circOut});
		FlxTween.tween(iconP2, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / (1050 / playbackRate), {ease: FlxEase.circOut});
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate))) {
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		// HEAT VENT SOUND
		if (curStage == 'basement') if (curStep % 6 == FlxG.random.int(0, 6)) FlxG.sound.play(Paths.sound(stageSuffix + '/vent'), 0.005); // Put it at a very low volume so it doesn't get way too loud (Normally basements sound like that but some houses have a loud basement)

		if (ClientPrefs.shaders) {
			if (SONG.song == "Stadium Rave" && curStage == 'stadium' && curStep < 768 || curStep > 1280) {
				boyfriend.color == 0x44000044;
				dad.color == 0x44000044;
				mom.color == 0x44000044;
				pico.color == 0x44000044;
				gf.color == 0x44000044;
			} else {
				boyfriend.color == 0xFFFFFFFF;
				dad.color == 0xFFFFFFFF;
				mom.color == 0xFFFFFFFF;
				pico.color == 0xFFFFFFFF;
				gf.color == 0xFFFFFFFF;
			}
		}


		switch(curStep) {
			case 3:
				//setSongTime(77550);
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (modchartInitialized) {
			if (curBeat % 2 == 0) {
				// Why
			}
		}



		if (SONG.song == 'Challenge') {
			if (!noMechanics) modchartInitialized = true;
			switch(curBeat) {
				case 1:
					modchartType1 = false;
					modchartType2 = false;
					modchartType3 = false;
				case 128:
					modchartType1 = true;
					modchartType2 = false;
					modchartType3 = false;
				case 192:
					modchartType1 = false;
					modchartType2 = true;
					modchartType3 = false;
				case 256:
					modchartType1 = true;
					modchartType2 = false;
					modchartType3 = false;
				case 352:
					modchartType1 = false;
					modchartType2 = false;
					modchartType3 = false;
				case 380:
					modchartType1 = true;
					modchartType2 = false;
					modchartType3 = false;
				case 384:
					modchartType1 = false;
					modchartType2 = false;
					modchartType3 = true;
			}
		}

		if (generatedMusic) notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

		// CROWD SOUNDS STUFF
		switch (curStage) { // I used random because normally the crowd cheers randomly when a concert or stadium is on or a movie theater has ended
			case 'music-contest-podium':
				if (curBeat % 128 == FlxG.random.int(72, 24)) FlxG.sound.play(Paths.sound(stageSuffix + '/clapping'), 0.35);
				if (curBeat % 128 == FlxG.random.int(56, 12)) FlxG.sound.play(Paths.sound(stageSuffix + '/booing'), 0.25);
			case 'stadium':
				if (ratingPercent < 0.95) if (curBeat % 128 == FlxG.random.int(96, 24)) FlxG.sound.play(Paths.sound(stageSuffix + '/cheering'), 0.65);
				if (curBeat % 128 == FlxG.random.int(64, 96)) FlxG.sound.play(Paths.sound(stageSuffix + '/clapping'), 0.35);
				if (curBeat % 128 == FlxG.random.int(36, 72)) FlxG.sound.play(Paths.sound(stageSuffix + '/booing'), 0.25);
			case 'basement':
				// Normally basements sound like that lol
				if (curStep % 6 == FlxG.random.int(0, 6)) FlxG.sound.play(Paths.sound(stageSuffix + '/vent'), 0.05);
			case 'interrogatee':
				// Volume random float because jail doors normally sound louder when closer to the cell someone is in
				if (curBeat % 128 == FlxG.random.int(16, 128)) FlxG.sound.play(Paths.sound(stageSuffix + '/jail-sounds/' + FlxG.random.int(0, 4)), FlxG.random.float(0.1, 0.5));
				if (curBeat % 128 == FlxG.random.int(72, 24)) FlxG.sound.play(Paths.sound(stageSuffix + '/guard-passingby'), 0.25);
			default:
				// Nothing, what do you expect?
		}

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		// GF
		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned) {
			gf.dance();
		}
		// PLAYER 1
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned) {
			boyfriend.dance();
		}
		// PLAYER 2
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned) {
			dad.dance();
		}
		// PLAYER 3
		if (curBeat % mom.danceEveryNumBeats == 0 && mom.animation.curAnim != null && !mom.animation.curAnim.name.startsWith('sing') && !mom.stunned) {
			mom.dance();
		}
		// PLAYER 4 (real)
		if (curBeat % pico.danceEveryNumBeats == 0 && pico.animation.curAnim != null && !pico.animation.curAnim.name.startsWith('sing') && !pico.stunned) {
			pico.dance();
		}

		switch (curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});

			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0) {
					curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
					phillyWindow.color = phillyLightsColors[curLight];
					phillyWindow.alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8) {
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset) {
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);

		var animatedIcon:Bool = false;

		if(!ClientPrefs.hideHud) { // Showdown funk icon bop in Tanker's Rap Song (REAL!?!?)
			iconBop();
			/* iconP1.scale.set(1.15, 1.15);
			iconP1.y += 7;
			if(!animatedIcon) iconP2.scale.set(1.15, 1.15);
			if(!animatedIcon) iconP2.y += 7;
			FlxTween.tween(iconP1, {'scale.x': 1, 'scale.y': 1, y: iconP1.y - 7}, Conductor.crochet / (18*ClientPrefs.framerate) / playbackRate / gfSpeed, {ease: FlxEase.circOut});
			if(!animatedIcon) FlxTween.tween(iconP2, {'scale.x': 1, 'scale.y': 1, y: iconP1.y - 7}, Conductor.crochet / (18*ClientPrefs.framerate) / playbackRate / gfSpeed, {ease: FlxEase.circOut}); */
		}

		//iconP1.updateHitbox();
		//iconP2.updateHitbox();
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null) {
			if (generatedMusic && !endingSong && !isCameraOnForcedPos) {
				moveCameraSection();
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms) {
				if (!isPostDialogue && !startedCountdown) {
					FlxG.camera.zoom += 0.015 * camZoomingMult;
					camHUD.zoom += 0.03 * camZoomingMult;
				}
			}

			if (SONG.notes[curSection].changeBPM) {
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}
		
		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
	}

	#if LUA_ALLOWED
	public function startLuasOnFolder(luaFile:String)
	{
		for (script in luaArray)
		{
			if(script.scriptName == luaFile) return false;
		}

		#if MODS_ALLOWED
		var luaToLoad:String = Paths.modFolders(luaFile);
		if(FileSystem.exists(luaToLoad))
		{
			luaArray.push(new FunkinLua(luaToLoad));
			return true;
		}
		else
		{
			luaToLoad = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
				return true;
			}
		}
		#elseif sys
		var luaToLoad:String = Paths.getPreloadPath(luaFile);
		if(OpenFlAssets.exists(luaToLoad))
		{
			luaArray.push(new FunkinLua(luaToLoad));
			return true;
		}
		#end
		return false;
	}
	#end

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [];

		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var myValue = script.call(event, args);
			if(myValue == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			if(myValue != null && myValue != FunkinLua.Function_Continue) {
				returnVal = myValue;
			}
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			notes.forEachAlive(function(note:Note) if(!note.isSustainNote) spr.playAnim('confirm', true));
			spr.resetAnim = time;
		}
	}

	// For ending screen
	public static var accuracy:Float;

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) { //Prevent divide by 0
				ratingName = '?';
			} else {
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				accuracy = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1) {
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				} else {
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}

				if(accuracy >= 1) {
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				} else {
					for (i in 0...ratingStuff.length-1)
					{
						if(accuracy < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				
				if (achievementName.contains(WeekData.getWeekFileName()) && achievementName.endsWith('nomiss')) { // any FC achievements, name should be "weekFileName_nomiss", e.g: "weekd_nomiss";
					if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD'
						&& storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						unlock = true;
				}
				switch(achievementName) {
					// Tanker Kraken's Rap Song Achievements
					case 'tkrapsong_beaten':
						if(Paths.formatToSongPath(SONG.song) == 'diazepam' && isStoryMode && !changedDifficulty && !cpuControlled
							&& !usedPractice && CoolUtil.difficultyString() == 'NORMAL' || CoolUtil.difficultyString() == 'EASY') {
							unlock = true;
						}
					case 'tkrapsong_beaten_hard':
						if(Paths.formatToSongPath(SONG.song) == 'diazepam' && isStoryMode && !changedDifficulty && !cpuControlled
							&& campaignMisses + songMisses < 5 && !usedPractice && CoolUtil.difficultyString() == 'HARD') {
							unlock = true;
						}
					case 'tkrapsong_beaten_truehero':
						if(Paths.formatToSongPath(SONG.song) == 'homeless' || Paths.formatToSongPath(SONG.song) == 'plenitudinous' && isStoryMode && !changedDifficulty && !cpuControlled
							&& campaignMisses + songMisses < 25 && !usedPractice && CoolUtil.difficultyString() == 'HARD') {
							unlock = true;
						}
					case 'tkrapsong_demilunecompleted':
						if(Paths.formatToSongPath(SONG.song) == 'demilune' && isStoryMode && !changedDifficulty && !cpuControlled
							&& !usedPractice && CoolUtil.difficultyString() == 'HARD') {
							unlock = true;
						}
					case 'tkrapsong_thecoolcontestcompleted':
						if(Paths.formatToSongPath(SONG.song) == 'the-cool-contest' && isStoryMode && !changedDifficulty && !cpuControlled
							&& !usedPractice && !noMechanics) {
							unlock = true;
						}
					case 'tkrapsong_firstfakebill':
						if(Paths.formatToSongPath(SONG.song) == 'plenitudinous' && isStoryMode && !changedDifficulty && !cpuControlled
							&& campaignMisses + songMisses < 1 && !usedPractice && !noMechanics) {
							unlock = true;
						}

					// Regular Psych Achievements
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(ClientPrefs.framerate <= 60 && !ClientPrefs.shaders && ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	var curLight:Int = -1;
	var curLightEvent:Int = -1;

	// Stole all this from https://github.com/TheMattMoney/Friday-Night-Bladin-Final/blob/main/source/PlayState.hx#L1423
	
	var checkpoint1:Int = 0;
	var checkpoint2:Int = 0;
	var checkpoint3:Int = 0;
	var checkpoint4:Int = 0;

	public var curSave = 0;

	var savedFirst = false;
	var savedSecond = false;
	var savedThird = false;
	var savedFinale = false;

	public function setStatsToStorage() {
		songScore = Storage.songScore[curSave];
		songMisses = Storage.songMisses[curSave];
		ratingName = Storage.ratingName[curSave];
		ratingPercent = Storage.ratingPercent[curSave];
	}

	public function resetStats() {
		Storage.startingTime=0;
		Storage.songScore = [0,0,0];
		Storage.songMisses = [0,0,0];
		Storage.ratingName =["?","?","?"];
		Storage.ratingPercent= [0.0,0.0,0.0];
		curSave=0;
		savedFirst=false;
		savedSecond=false;
		savedThird=false;
		savedFinale=false;
	}

	function saveOnes(n:Bool=false) {
		if(!n) {
			Storage.songScore[curSave]=songScore;
			Storage.songMisses[curSave]=songMisses;
			Storage.ratingName[curSave]=ratingName;
			Storage.ratingPercent[curSave]=ratingPercent;
			curSave++; 
			n=true;
		}
	}

	function checkPointCheck() {
		if(checkpoint1<FlxG.sound.music.time&&FlxG.sound.music.time<checkpoint2) {
			Storage.startingTime=checkpoint1;
			saveOnes(savedFirst);
		}

		if(checkpoint2<FlxG.sound.music.time&&FlxG.sound.music.time<checkpoint3) {
			Storage.startingTime=checkpoint2;
			saveOnes(savedSecond);
		}

		if(checkpoint3<FlxG.sound.music.time&&FlxG.sound.music.time<checkpoint4) {
			Storage.startingTime=checkpoint3;
			saveOnes(savedThird);
		}

		if(checkpoint4<FlxG.sound.music.time) {
			Storage.startingTime=checkpoint4;
			saveOnes(savedFinale);
		}
	}
}