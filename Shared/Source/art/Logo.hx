package art;

import flixel.util.FlxTimer;
import flixel.FlxG;

class Logo extends flixel.FlxSprite {
    
    public function new (callback:Void->Void):Void {
        super();
        
        loadGraphic("sharedAssets/logo-animated.png", true, 36);
        animation.add("idleStart", [0]);
        animation.add("main", [1,1,1,2,2,2,3,3,4,4,4,4,5,5,5,5], 8, false);
        animation.add("idleEnd", [5]);
        animation.play("idleStart");
        
        x = (FlxG.width  - width ) / 2;
        y = (FlxG.height - height) / 2;
        
        new FlxTimer().start(0.5,
            (_) -> {
                animation.play("main");
                FlxG.sound.play("sharedAssets/GeoKureli.mp3", .25);
                new FlxTimer().start(3.0, (_) -> { callback(); });
            }
        );
    }
}