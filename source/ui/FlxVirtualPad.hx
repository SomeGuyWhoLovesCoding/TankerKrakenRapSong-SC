package ui;

import flixel.FlxG;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.util.FlxDestroyUtil;
import flixel.ui.FlxButton;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.display.BitmapData;
import flixel.graphics.FlxGraphic;
import openfl.utils.ByteArray;

class FlxVirtualPad extends FlxSpriteGroup
{
	public var buttonA:FlxButton;
	public var buttonB:FlxButton;
	public var buttonY:FlxButton;
	public var buttonX:FlxButton;
	public var buttonZ:FlxButton;
	public var buttonLeft:FlxButton;
	public var buttonUp:FlxButton;
	public var buttonRight:FlxButton;
	public var buttonDown:FlxButton;

    public var buttonLeft1:FlxButton;
	public var buttonUp1:FlxButton;
	public var buttonRight1:FlxButton;
	public var buttonDown1:FlxButton;
    public var buttonLeft2:FlxButton;
	public var buttonUp2:FlxButton;
	public var buttonRight2:FlxButton;
	public var buttonDown2:FlxButton;

	public var dPad:FlxSpriteGroup;
	public var actions:FlxSpriteGroup;

	public function new(?DPad:FlxDPadMode, ?Action:FlxActionMode) {
		super();
		scrollFactor.set();

		if (DPad == null) DPad = FULL;
		if (Action == null) Action = A_B_C;

		dPad = new FlxSpriteGroup();
		dPad.scrollFactor.set();

		actions = new FlxSpriteGroup();
		actions.scrollFactor.set();

		switch (DPad) {
			case FULL:
				dPad.add(add(buttonLeft = createButton(96, FlxG.height - 60 * 3, 44 * 3, 45 * 3, "left")));
                dPad.add(add(buttonDown = createButton(192, FlxG.height - 60 * 3, 44 * 3, 45 * 3, "down")));
                dPad.add(add(buttonUp = createButton(FlxG.width - 192, FlxG.height - 60 * 3, 44 * 3, 45 * 3, "up")));
				dPad.add(add(buttonRight = createButton(FlxG.width - 96, FlxG.height - 60 * 3, 44 * 3, 45 * 3, "right")));
			case MANIA:
                dPad.add(add(buttonLeft1 = createButton(96, FlxG.height - 60 * 3, 44 * 3, 45 * 3, "left")));
                dPad.add(add(buttonDown1 = createButton(128, FlxG.height - 60 * 3, 44 * 3, 45 * 3, "down")));
                dPad.add(add(buttonUp1 = createButton(192, FlxG.height - 60 * 3, 44 * 3, 45 * 3, "up")));
				dPad.add(add(buttonRight1 = createButton(256, FlxG.height - 60 * 3, 44 * 3, 45 * 3, "right")));
                dPad.add(add(buttonLeft2 = createButton(FlxG.width - 256, FlxG.height - 60 * 3, 44 * 3, 45 * 3, "left")));
                dPad.add(add(buttonDown2 = createButton(FlxG.width - 192, FlxG.height - 60 * 3, 44 * 3, 45 * 3, "down")));
                dPad.add(add(buttonUp2 = createButton(FlxG.width - 128, FlxG.height - 60 * 3, 44 * 3, 45 * 3, "up")));
				dPad.add(add(buttonRight2 = createButton(FlxG.width - 96, FlxG.height - 60 * 3, 44 * 3, 45 * 3, "right")));
			case NONE: // do nothing
		}

		switch (Action)
		{
			case A:
				actions.add(add(buttonA = createButton(FlxG.width - 44 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "a")));
            case B:
				actions.add(add(buttonB = createButton(FlxG.width - 44 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "b")));
			case A_B:
				actions.add(add(buttonA = createButton(FlxG.width - 44 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "a")));
				actions.add(add(buttonB = createButton(FlxG.width - 86 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "b"))); 
 			case A_B_X_Y:
				actions.add(add(buttonY = createButton(FlxG.width - 86 * 3, FlxG.height - 85 * 3, 44 * 3, 45 * 3, "y")));
				actions.add(add(buttonX = createButton(FlxG.width - 44 * 3, FlxG.height - 85 * 3, 44 * 3, 45 * 3, "x")));
				actions.add(add(buttonB = createButton(FlxG.width - 86 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "b")));
				actions.add(add(buttonA = createButton(FlxG.width - 44 * 3, FlxG.height - 45 * 3, 44 * 3, 45 * 3, "a")));
			case NONE: // do nothing
		}
	}

	override public function destroy():Void
	{
		super.destroy();

		dPad = FlxDestroyUtil.destroy(dPad);
		actions = FlxDestroyUtil.destroy(actions);

		dPad = null;
		actions = null;
		buttonA = null;
		buttonB = null;
		buttonY = null;
		buttonX = null;
		buttonZ	= null;	
		buttonLeft = null;
		buttonUp = null;
		buttonDown = null;
		buttonRight = null;

        buttonLeft1 = null;
		buttonUp1 = null;
		buttonDown1 = null;
		buttonRight1 = null;
        buttonLeft2 = null;
		buttonUp2 = null;
		buttonDown2 = null;
		buttonRight2 = null;
	}

	public function createButton(X:Float, Y:Float, Width:Int, Height:Int, Graphic:String, ?OnClick:Void->Void):FlxButton
	{
		var button = new FlxButton(X, Y);
		var frame = getVirtualInputFrames().getByName(Graphic);
		button.frames = FlxTileFrames.fromFrame(frame, FlxPoint.get(Width, Height));
		button.resetSizeFromFrame();
		button.solid = false;
		button.immovable = true;
		button.scrollFactor.set();

	    #if FLX_DEBUG
		button.ignoreDrawDebug = true;
		#end

		if (OnClick != null)
			button.onDown.callback = OnClick;

		return button;
	}

	public static function getVirtualInputFrames():FlxAtlasFrames
	{
		return Paths.getPackerAtlas('virtualpad');
	}
}

enum FlxDPadMode
{
	NONE;
	FULL;
    MANIA;
}

enum FlxActionMode
{
	NONE;
	A;
    B;
	A_B;
	A_B_X_Y;
}