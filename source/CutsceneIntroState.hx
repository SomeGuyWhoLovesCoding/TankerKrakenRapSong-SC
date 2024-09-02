package;

#if desktop
import Discord.DiscordClient;
#end

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.group.FlxSpriteGroup;
import animateatlas.AtlasFrameMaker;
import flixel.util.FlxSort;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if VIDEOS_ALLOWED
import vlc.MP4Handler;
#end

using StringTools;
class CutsceneIntroState extends MusicBeatState
{
    public var boyfriend:Boyfriend = null;

    public var bg:FlxSprite;
    public var logo:FlxSprite = new FlxSprite();
    public var watermark:FlxSprite;

    override function create()
    {
        Conductor.changeBPM(150);

        FlxG.sound.play(Paths.sound('introCutscene1'), 1.2);

        super.create();
        bg = new FlxSprite().loadGraphic(Paths.image('titleBG'));
        add(bg);

        logo.frames = Paths.getSparrowAtlas('logoBumpin');
        logo.animation.addByPrefix('logo bumpin', 'logo bumpin', 18, true);
		logo.animation.play('logo bumpin', true);
        logo.screenCenter();
        add(logo);

        watermark = new FlxSprite().loadGraphic(Paths.image('cutscenes/credit_text'));
        watermark.x = 0;
        watermark.y = FlxG.height + watermark.width;
        watermark.alpha = 0.25;
        add(watermark);

        FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
    }

    var lastStepHit:Int = -1;
	public static var closedState:Bool = false;

    override function update(elapsed:Float)
    { 
        elapsed += elapsed;

        FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

        /*tanker_1.alpha = 0;
        tanker_2.alpha = 0;
        tanker_3.alpha = 0;
        tanker_4.alpha = 0;
        bf_1.alpha = 0;
        bf_2.alpha = 0;
        duet_1.alpha = 0;
        duet_2.alpha = 0;*/

        super.update(elapsed);
    }

    // Bullshit code

    /*override function stepHit()
    {
        switch (curStep)
        {
            case 17:
                FlxTween.tween(logo, {x: logo.x - 400}, 0.75, {ease: FlxEase.quadOut});
                FlxTween.tween(watermark, {x: watermark.x - 700}, 0.75, {ease: FlxEase.quadOut});
            case 26:
                logo.alpha = 0;
                watermark.alpha = 0;
            case 27:
                FlxTween.tween(logo, {x: logo.x + 200}, 0, {ease: FlxEase.quadOut});
                FlxTween.tween(watermark, {x: watermark.x + 350}, 0, {ease: FlxEase.quadOut});
                logo.alpha = 1;
                watermark.alpha = 1;
            case 28:
                logo.alpha = 0;
                watermark.alpha = 0;
            case 29:
                FlxTween.tween(logo, {x: logo.x + 200}, 0, {ease: FlxEase.quadOut});
                FlxTween.tween(watermark, {x: watermark.x + 700}, 0, {ease: FlxEase.quadOut});
                logo.alpha = 1;
                watermark.alpha = 1;
            case 30:
                logo.alpha = 0;
                watermark.alpha = 0;
            case 31:
                logo.alpha = 1;
                watermark.alpha = 1;
            case 32:
                logo.alpha = 0;
                watermark.alpha = 0;
            case 33:
                //FlxTween.tween(tanker_1, {x: tanker_1.x + 60}, 1.5, {ease: FlxEase.circOut});
            case 61:
                //FlxTween.tween(tanker_1, {alpha: 0}, 0, {ease: FlxEase.circOut});
            case 65:
                //FlxTween.tween(tanker_1, {x: bf_1.x - 60}, 1.5, {ease: FlxEase.circOut});
        }
        super.stepHit();
        if(curStep == lastStepHit) {
            return;
        }
    }*/
}