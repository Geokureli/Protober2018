package art;

class Hero extends DialAPlatformer {
    
    static inline var TILE_SIZE = 8;
    
    public function new (x:Float = 0, y:Float = 0) {
        super(x, y);
        
        makeGraphic(12, 18, 0xFF6ABE30);
        
        setupVariableJump(TILE_SIZE * 3.5, TILE_SIZE * 6.5, .35);
        // setupAirJump(TILE_SIZE * 1.5);
        setupVariableAirJump(TILE_SIZE * 1.5, TILE_SIZE * 3.5);
        setupSpeed(TILE_SIZE * 8, .125);
        coyoteTime = .1;
        numAirJumps = 4;
    }
}