package art;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Bullet extends flixel.FlxSprite {
    
    public function new (graphic:FlxGraphicAsset = null, width:Int = 0, height:Int = 0) {
        super();
        
        loadGraphic(graphic, width > 0, width, height);
    }
    
    public function init(x:Float, y:Float, vX:Float = 0, vY:Float = 0):Void {
        
        this.x = x - width  / 2;
        this.y = y - height / 2;
        velocity.set(vX, vY);
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (y + height > FlxG.height || y < -height)
            kill();
    }
    
    public var centerX(get, never):Float;
    inline function get_centerX():Float { return x + width / 2; }
    public var centerY(get, never):Float;
    inline function get_centerY():Float { return y + height / 2; }
}