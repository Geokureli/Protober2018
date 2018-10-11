package art;

import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;

class Hero extends DialAPlatformer {
    
    static inline var TILE_SIZE = 8;
    static inline var RESPAWN_TIME = 1.0;
    
    var _spawnPoint = FlxPoint.get();
    
    public function new (isPlayer1:Bool, isPvp:Bool = false) {
        super(0, 0, "assets/hero.png");
        
        x = isPlayer1 ? 40 : FlxG.width - 40 - width;
        y = FlxG.height - height - 16;
        getPosition(_spawnPoint);
        
        setupJump(TILE_SIZE * 4.5, .35);
        setupSpeed(TILE_SIZE * 5, .125);
        if (isPlayer1){
            
            if (isPvp)
                setKeys([FlxKey.A], [FlxKey.D], [FlxKey.W]);
            else
                setKeys([FlxKey.A, FlxKey.LEFT], [FlxKey.D, FlxKey.RIGHT], [FlxKey.W, FlxKey.UP]);
            
        } else
            setKeys([FlxKey.LEFT], [FlxKey.RIGHT], [FlxKey.UP]);
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (y + height > FlxG.height && moves)
            respawn();
    }
    
    public function respawn():Void {
        
        moves = false;
        
        FlxFlicker.flicker
            ( this
            , RESPAWN_TIME
            , 0.04
            , true
            , true
            , (_) -> {
                    
                    moves = true;
                    x = _spawnPoint.x;
                    y = _spawnPoint.y;
                }
            );
    }
}

class Enemy extends Hero {
    
    inline static var LEVEL_SIZE = 20;
    inline static var TILE_SIZE = Hero.TILE_SIZE;
    inline static var LEFT   = 24.0 * TILE_SIZE;
    inline static var RIGHT  = 27.0 * TILE_SIZE;
    inline static var EDGE  = 30.0 * TILE_SIZE;
    static var heights:Array<Float> =
        [ (LEVEL_SIZE - 1 ) * TILE_SIZE
        , (LEVEL_SIZE - 4 ) * TILE_SIZE
        , (LEVEL_SIZE - 8 ) * TILE_SIZE
        , (LEVEL_SIZE - 12) * TILE_SIZE
        , (LEVEL_SIZE - 16) * TILE_SIZE
        ];
    static var sides:Array<Float> = 
        [ EDGE
        , RIGHT
        , LEFT
        , RIGHT
        , RIGHT
        ];
    
    var _section:Int = -1;
    var _debugObj:FlxObject;
    var _ball:FlxObject;
    
    public function new (ball:FlxObject, debugObj:FlxSprite = null) {
        super(false);
        
        _ball = ball;
        
        if (debugObj != null) {
            
            _debugObj = debugObj;
            debugObj.makeGraphic(Std.int(width), Std.int(height), 0x40FF0000);
        }
        _npcMode = true;
    }
    
    override function update(elapsed:Float) {
        
        if (isTouching(FlxObject.DOWN)) {
            
            _section = 4 - Std.int(y / FlxG.height * 6);
        }
        
        var targetSection = _ball.velocity.x > 0 ? getNearestSection(_ball.y) : 2;
        
        if (_debugObj != null) {
            
            var targetPos = getTargetPos(targetSection);
            _debugObj.setPosition(targetPos.x, targetPos.y);
            targetPos.put();
        }
        
        var goingUp = false;
        if(targetSection != 0) {// accessible anywhere
            
            if (_section < targetSection){
                
                targetSection = _section + 1;
                goingUp = true;
                
            } else if (_section > targetSection)
                targetSection = _section - 1;
        }
        
        var nextPos = getTargetPos(targetSection);
        
        _keyStates["jump"] = goingUp;
        _keyStates["right"] = nextPos.x > x;
        _keyStates["left"] = nextPos.x < x;
        nextPos.put();
        
        super.update(elapsed);
    }
    
    function getTargetPos(index:Int):FlxPoint {
        return FlxPoint.get
            ( sides[index] - width
            , heights[index] - height
            );
    }
    
    function getNearestSection(y:Float):Int {
        
        var i = 0;
        while(heights[i] > y)
            i++;
        return i - 1;
    }
}