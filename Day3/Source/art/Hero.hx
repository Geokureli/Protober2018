package art;

import flixel.util.FlxColor;

class Hero extends DialAPlatformer {
    
    static inline var TILE_SIZE = 8;
    
    public function new (x:Float = 0, y:Float = 0) {
        super(x, y);
        
        makeGraphic(7, 12, FlxColor.RED);
        
        setupJump(TILE_SIZE * 3.1, .35);//, 2);
        setupSpeed(TILE_SIZE * 5, .125);
        // setupSpeed(TILE_SIZE * 5, 0);
    }
}