package art;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxSprite;

class WrapSprite extends FlxSprite {
    
    public function new (x:Float = 0, y:Float = 0, ?graphic:FlxGraphicAsset) {
        super(x, y, graphic);
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (x > FlxG.camera.scroll.x + FlxG.camera.width ) x -= FlxG.camera.width + width;
        else if (x < FlxG.camera.scroll.x - width        ) x += FlxG.camera.width + width;
        if (y > FlxG.camera.scroll.y + FlxG.camera.height) y -= FlxG.camera.height + height;
        else if (y < FlxG.camera.scroll.y - height        ) y += FlxG.camera.height + height;
    }
    
    inline public function setToEdge():Void {
        
        if (Math.random() > 0.5) {
            
            x = Math.round(Math.random());
            y = Math.random();
            
        } else {
            
            x = Math.random();
            y = Math.round(Math.random());
        }
        
        x = FlxG.camera.scroll.x + x * (FlxG.camera.width  + width  + 1) - width;
        y = FlxG.camera.scroll.x + y * (FlxG.camera.height + height + 1) - height;
    }
}

class Star extends WrapSprite {
    
    public function new () {
        super(Math.random() * FlxG.camera.width, Math.random() * FlxG.camera.height);
        
        makeGraphic(1,1, 0xFFFFFFFF, false, "star");
    }
}