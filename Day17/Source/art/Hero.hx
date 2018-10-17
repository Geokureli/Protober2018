package art;

class Hero extends DialAPlatformer {
    
    static inline var TILE_SIZE = 8;
    
    public function new (x:Float = 0, y:Float = 0) {
        super(x, y);
        
        makeGraphic(7, 12, 0xFFD95763);
        
        setupJump(TILE_SIZE * 3.5, .35);//, 2);
        setupSpeed(TILE_SIZE * 5, .125);
    }
}