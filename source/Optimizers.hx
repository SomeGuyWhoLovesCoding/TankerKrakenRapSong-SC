package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import lime.app.Application;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

// CLASSES
class Optimizers extends FlxState
{
    var path = '';
    var file = FileSystem.absolutePath(path);
    var amount = FlxG.state.length;

    function new(persistentDraw:Bool = FlxG.state.persistentDraw, persistentDraw:Bool = FlxG.state.persistentUpdate, fps:Int = 60) {
        FlxG.updateFramerate = fps;
        FlxG.vcr.startRecording(false);
        FlxG.state.switchTo(new PlayState());
    }
}