package art;

import flixel.util.FlxTimer;
import flixel.FlxG;

class Logo extends flixel.FlxSprite {
    
    public function new ():Void {
        super();
        
        loadGraphic("sharedAssets/logo-animated.png", true, 37);
        
        animation.add("idleStart", [0]);
        animation.add("main", [0,1,1,0,2,3,4,5,6,6,7,8,9,9,10,11,12,12,12,12,13,14,15,16,17,17,17,17,18,19], 16, false);
        animation.add("idleEnd", [19]);
        
        animation.play("idleStart");
        visible = false;
        scale.x = scale.y = 8.0 / FlxG.stage.stageWidth * FlxG.width;
        trace('swf:${FlxG.stage.stageWidth} flx:${FlxG.width}');
        x = (FlxG.width  - width ) / 2;
        y = (FlxG.height - height) / 2;
    }
    
    public function start(callback:Void->Void):Void {
        
        animation.play("idleStart");
        visible = false;
        
        new FlxTimer().start(1.0,
            (_) -> {
                visible = true;
                FlxG.sound.play("sharedAssets/GeoKureli.mp3", .25);
                animation.play("main");
                new FlxTimer().start(5.0, (_) -> { callback(); });
            }
        );
    }
}