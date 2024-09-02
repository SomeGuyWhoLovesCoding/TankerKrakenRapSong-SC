package;

import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class FreeplayCategoryState extends MusicBeatState {
    public var categoriesList:Array<String> = ['base game', 'tankers-rap-song', 'coming soon...'];
    public var categoryNamesList:Array<String> = ['vanilla', 'tanker kraken\'s rap song', 'coming soon...'];
    public var categoryColors:Array<FlxColor> = [0xFFAB6BBF, FlxColor.fromRGB(49, 144, 73), 0xFF222222];

    /* Version 2 Stuff
    public var categoriesList:Array<String> = ['base game', 'festivalv', 'festivalv2', 'extras'];
    public var categoryNamesList:Array<String> = ['vanilla', 'festivalv (season 1)', 'festivalv (season 2)', 'extras'];
    public var categoryColors:Array<FlxColor> = [0xFFAB6BBF, 0xFFFFFF00, 0xFF060666, 0xFF999099]; */

    public static var curSelected:Int = 0;

    public var bg:FlxSprite;
    public var categorySpr:FlxSprite;
    public var alphabetText:Alphabet;

    public var camOther:FlxCamera;

    var blackBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    var lightingBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF777777);

    var selectedSomethin:Bool = true;
    override public function create() {
        camOther = new FlxCamera();
        camOther.bgColor.alpha = 0;
		FlxG.cameras.add(camOther, false);

        bg = new FlxSprite(0, 0).loadGraphic(Paths.image('menuDesat'));
        bg.color = categoryColors[curSelected];
        add(bg);

        categorySpr = new FlxSprite().loadGraphic(Paths.image('categories/' + categoriesList[curSelected]));
        categorySpr.screenCenter();
        categorySpr.alpha = 0;
        categorySpr.x += 60;
        add(categorySpr);

        alphabetText = new Alphabet(0, FlxG.height - 200, categoryNamesList[curSelected], true);
        alphabetText.x = categorySpr.width / 3;
        alphabetText.alpha = 0;
        alphabetText.x -= 60;
        add(alphabetText);

        //blackBG.cameras = [camOther];
        //add(blackBG);

        lightingBG.cameras = [camOther];
        lightingBG.blend = ADD;
        lightingBG.alpha = 0;
        add(lightingBG);

        //FlxTween.tween(blackBG, {alpha: 0}, 0.5, {ease: FlxEase.smootherStepOut});
        FlxTween.tween(categorySpr, {alpha: 1, x: categorySpr.x - 60}, 0.5, {ease: FlxEase.smoothStepOut, startDelay: 0.15});
        FlxTween.tween(alphabetText, {alpha: 1, x: alphabetText.x + 60}, 0.5, {ease: FlxEase.smoothStepOut, startDelay: 0.15, onComplete: function(twm:FlxTween) {
            selectedSomethin = false;
        }});

        var creditText = new FlxText(2, FlxG.height - 22, 0, 'From FestivalV X FNF by SomeGuyWhoLikesFNF and Squawkers', 16);
        creditText.alpha = 0.35;
        add(creditText);

        super.create();
        CustomFadeTransition.nextCamera = camOther;
    }

    override public function update(elapsed:Float) {
        if (!selectedSomethin) {
            if (controls.UI_LEFT_P) 
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                changeSelection(-1);
            }

            if (controls.UI_RIGHT_P) 
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                changeSelection(1);
            }

            if (controls.ACCEPT)
                if (curSelected != 2)
                    selectCategory();
                else
                    FlxG.sound.play(Paths.sound('cancelMenu'));

            if (controls.BACK)
            {
                selectedSomethin = true;
                FlxG.sound.play(Paths.sound('cancelMenu'));
                MusicBeatState.switchState(new MainMenuState());
            }
        }

        if (curSelected < 0) curSelected = categoriesList.length-1;
        if (curSelected > categoriesList.length-1) curSelected = 0;

        if (!selectedSomethin) {
            categorySpr.loadGraphic(Paths.image('categories/' + categoriesList[curSelected]));
            alphabetText.text = categoryNamesList[curSelected];
            alphabetText.x = categorySpr.width / 3;
            bg.color = categoryColors[curSelected];
            categorySpr.screenCenter();
        }
        else categorySpr.screenCenter(Y);
    }

    public function changeSelection(change:Int = 1) {
        curSelected += change;
        if (curSelected < 0) curSelected = categoriesList.length-1;
        if (curSelected > categoriesList.length-1) curSelected = 0;
    }

    public function selectCategory() {
        lightingBG.alpha = 1;
        selectedSomethin = true;
        FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
        FlxFlicker.flicker(categorySpr, 1.5, 0.05, false);
        FlxTween.tween(lightingBG, {alpha: 0}, 0.5, {ease: FlxEase.smootherStepOut});
        FlxTween.tween(alphabetText, {alpha: 0, x: alphabetText.x - 24}, 1, {ease: FlxEase.smoothStepOut});
        FlxTween.tween(categorySpr, {alpha: 0}, 0.75, {ease: FlxEase.smoothStepOut, startDelay: 0.75});
        new FlxTimer().start(1.5, function(tmr:FlxTimer) {
            FreeplayState.curCategory = categoriesList[curSelected];
            if (FreeplayState.curCategory == 'base game') FreeplayState.curCategory = '';
            LoadingState.loadAndSwitchState(new FreeplayState());
        });
    }
}