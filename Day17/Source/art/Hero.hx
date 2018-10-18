package art;

class Hero extends DialAPlatformer {
    
    static inline var TILE_SIZE = 8;
    
    public function new (x:Float = 0, y:Float = 0) {
        super(x, y);
        
        makeGraphic(12, 18, 0xFF6ABE30);
        
        setupVariableJump(TILE_SIZE * 3.25, TILE_SIZE * 6.25, .35);
        setupVariableAirJump(TILE_SIZE * 1.25, TILE_SIZE * 3.25);
        setupSpeed(TILE_SIZE * 8, .25);
        coyoteTime = .1;
        numAirJumps = 4;
    }
}