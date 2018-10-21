package art;

class Hero extends DialAPlatformer {
    
    static inline var TILE_SIZE = 8;
    
    var _startY = 0.0;
    
    public function new (x:Float = 0, y:Float = 0) {
        super(x, y);
        
        makeGraphic(12, 18, 0xFF6ABE30);
        
        // setupVariableJump(TILE_SIZE * 3.25, TILE_SIZE * 6.25, .35);
        setupJump(TILE_SIZE * 3.25, .35);
        setupVariableAirJump(TILE_SIZE * 1, TILE_SIZE * 3);
        setupSpeed(TILE_SIZE * 8, .25);
        //setupWallJump(TILE_SIZE * 3.25, TILE_SIZE * 3);
        setupSkidJump(TILE_SIZE * 7.25);
        coyoteTime = .1;
        jumpDirectionChange = true;
        airJumpDirectionChange = true;
        numAirJumps = 1;
        autoApexAirJump = true;
        skidDrag = false;
    }
    
    public function resetParams():Void {
        
        _numAirJumpsLeft = 0;
        _airJumpVelocity = 0.0;
        _airJumpTime = 0.0;
        
        _skidJumpVelocity = 0.0;
        _skidJumpTime = 0.0;
        
        _wallJumpVelocity = 0.0;
        _wallJumpTime = 0.0;
        _wallJumpXTime = -1.0;
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (velocity.y >= 0) {
            
            if (y + 1 < _startY)
                trace('height:${_startY - y}');
            
            _startY = y;
        }
    }
    
    override function jump(justPressed:Bool) {
        
        super.jump(justPressed);
        
        if(justPressed)
            _startY = y;
    }
}