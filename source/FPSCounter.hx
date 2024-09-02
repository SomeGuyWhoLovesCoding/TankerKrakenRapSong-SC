// Just like openfl FPS but it has WAY MORE HANDLERS!

package;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey as CKey;
import openfl.display.FPS as CFPS;

class FPSCounter
{
    public function new() {
        //super();
    }

    public inline static function fill(value:Float, isstatic:Bool, ispublic:Bool, direction:CKey = -1) { // Readonly FPS capping lock
        //value = 60000; :trollface:
        isstatic = !isstatic;
        ispublic = !ispublic;
    }
}