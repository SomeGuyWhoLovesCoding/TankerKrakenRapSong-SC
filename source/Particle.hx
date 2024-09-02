package;

import Conductor.BPMChangeEvent;
import flixel.*;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxSprite;
import flixel.FlxCamera;
import openfl.*;
import lime.*;
import haxe.Json;

class Particle extends MusicBeatState
{
    public var particleArray:Array<FlxSprite> = new Array<FlxSprite>();
    public var particleMap:Map<FlxSprite, Particle> = new Map<FlxSprite, Particle>();
    public var particleGroup:FlxSpriteGroup = new FlxSpriteGroup(FlxG.random.int(-1000, 1000), 0);
    public var particleGradient:FlxSprite = FlxGradient.createGradientFlxSprite(6600, 2000, [FlxColor.PINK, 0x0]);
    public var particleTimer:FlxTimer;
    public static var instance:Particle;

    override function create() {
        instance = this;
        super.create();
        particleGradient.alpha = 0;
        particleArray = [particleGradient/*, particleDots*/];
        particleGroup.add(particleGradient);
    }

    override public function update(e:Float) {
        super.update(e);
        particleMap.set(particleGradient, instance);
    }
    
    var lastStepHit:Int = -1;
    override function stepHit()
    {
        super.stepHit();

        if(curStep == lastStepHit) {
			return;
		}
        
        if (PlayState.SONG.song == "Stadium Rave" && PlayState.curStage == 'stadium' && curStep < 768 || curStep > 1280) {
            if (curStep % 32 == 0) Jump();
            if (curStep % 32 == 6) Jump();
            if (curStep % 32 == 12) Jump();
            if (curStep % 32 == 20) Jump();
            if (curStep % 32 == 26) Jump();
        }
    }

    function Jump():Void {
        particleGradient.alpha = 1;
        FlxTween.tween(particleGradient, {alpha: 0}, Conductor.crochet / (18/ClientPrefs.getGameplaySetting('songspeed', 1)), {ease: FlxEase.quartOut});
    }
}