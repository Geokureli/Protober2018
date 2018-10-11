package art;

import flixel.effects.FlxFlicker;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;

class Hero extends flixel.FlxSprite {
    
    inline static var SPEED = Level.SIZE * 12;
    inline static var STOP_TIME = 0.25;
    
    static inline var LEFT   :Int = FlxObject.LEFT;
	static inline var RIGHT  :Int = FlxObject.RIGHT;
	static inline var UP     :Int = FlxObject.UP;
	static inline var DOWN   :Int = FlxObject.DOWN;
	static inline var NONE   :Int = FlxObject.NONE;
	static inline var CEILING:Int = FlxObject.CEILING;
	static inline var FLOOR  :Int = FlxObject.FLOOR;
	static inline var WALL   :Int = FlxObject.WALL;
	static inline var ANY    :Int = FlxObject.ANY;
	static inline var NOTWALL:Int = ANY - WALL;
    
    var _level:Level;
    var _toTile:FlxPoint;
    var _prevDir = FlxObject.NONE;
    var _keys:Map<Int, Array<FlxKey>> = new Map<Int, Array<FlxKey>>();
    var _respawnPos:FlxPoint;
    var _cpuLevel = 0;
    var _stoppedTime = 0.0;
    
    public var drill(default, null):Drill;
    
    public function new (level:Level, playerNum:Int, cpuLevel:Int = 0) {
        super(0, 0, "assets/hero.png");
        
        switch(playerNum) {
            case 1:
                setKeys([FlxKey.A], [FlxKey.D], [FlxKey.W], [FlxKey.S]);
                setPosition(2 * Level.SIZE, 1 * Level.SIZE);
                angle = 0;
                color = 0xAC3232;
            case 2:
                setKeys([FlxKey.LEFT], [FlxKey.RIGHT], [FlxKey.UP], [FlxKey.DOWN]);
                setPosition((level.widthInTiles - 3) * Level.SIZE, 1 * Level.SIZE);
                angle = 180;
                color = 0x6ABE30;
            case 3:
                setKeys([FlxKey.J], [FlxKey.L], [FlxKey.I], [FlxKey.K]);
                setPosition(2 * Level.SIZE, (level.heightInTiles - 2) * Level.SIZE);
                angle = 0;
                color = 0x639BFF;
            case 4:
                setKeys([FlxKey.FOUR], [FlxKey.SIX], [FlxKey.EIGHT], [FlxKey.TWO]);
                setPosition((level.widthInTiles - 3) * Level.SIZE, (level.heightInTiles - 2) * Level.SIZE);
                angle = 180;
                color = 0xFBF236;
        }
        
        _cpuLevel = cpuLevel;
        _respawnPos = FlxPoint.get(x, y);
        width = 8;
        origin.x = 4;
        _toTile = FlxPoint.get(x, y);
        
        _level = level;
        drill = new Drill(this);
    }
    
    
    function setKeys(left:Array<FlxKey>, right:Array<FlxKey>, up:Array<FlxKey>, down:Array<FlxKey>):Void { 
        
        _keys[LEFT ] = left;
        _keys[RIGHT] = right;
        _keys[UP   ] = up;
        _keys[DOWN ] = down;
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (!solid)
            return;
        
        if (_stoppedTime > 0){
            
            _stoppedTime -= elapsed;
            if (_stoppedTime <= 0)
                alpha = 1.0;
            return;
        }
        
        drill.reset
            ( x + (velocity.x / SPEED) * 8 + 2
            , y + (velocity.y / SPEED) * 8 + 2
            );
        drill.solid = velocity.x != 0 || velocity.y != 0;
        
        if (getIsAtNode()){
            
            setPosition(_toTile.x, _toTile.y);
            
            if (x >= FlxG.camera.scroll.x + FlxG.camera.width) {
                
                reset(0, y);
                _toTile.x = Level.SIZE;
                
            } else if (x + width <= FlxG.camera.scroll.x) {
                
                reset(FlxG.camera.scroll.x + FlxG.camera.width, y);
                _toTile.x = (_level.widthInTiles - 2) * Level.SIZE;
            }
            
            var levelDirs = _level.getMoves(x + width / 2, y + height / 2);
            var oldDirs = levelDirs;//debug
            
            //prevent turn-arounds
            if (_prevDir & LEFT  > 0) levelDirs = levelDirs & (ANY - RIGHT);
            if (_prevDir & RIGHT > 0) levelDirs = levelDirs & (ANY - LEFT );
            if (_prevDir & UP    > 0) levelDirs = levelDirs & (ANY - DOWN );
            if (_prevDir & DOWN  > 0) levelDirs = levelDirs & (ANY - UP   );
            
            var dir;
            // check if it's a fork or straight-away
            if (levelDirs == _prevDir) {
                
                dir = levelDirs;
                
            } else {
                
                var keyDirs = getKeyDirs(levelDirs);
                
                if (keyDirs & levelDirs == NONE && levelDirs & _prevDir != NONE)
                    dir = _prevDir;
                else {
                    
                    if (keyDirs & WALL == WALL)
                        keyDirs -= WALL;
                    
                    if (keyDirs & NOTWALL == NOTWALL)
                        keyDirs -= NOTWALL;
                    
                    dir = levelDirs & keyDirs & _prevDir;//maintain direction if possible
                    if (dir == NONE)
                        dir = levelDirs & keyDirs;
                    
                    if (dir != NONE)
                        _prevDir = dir;
                }
            }
            
            setNewDir(dir);
        }
    }
    
    function getKeyDirs(levelDir:Int):Int {
        
        if (_cpuLevel < 2)
            return checkKey(RIGHT) | checkKey(LEFT) | checkKey(UP) | checkKey(DOWN);
        
        // move randomly but but not dumb
        var ran;
        do {
            ran = getRandomDir();
        } while(ran & levelDir == NONE);
        
        return ran;
    }
    
    function checkKey(dir:Int):Int {
        
        if (!solid)
            return NONE;
        
        if (_cpuLevel > 0)
            // move entirely randomly
            return FlxG.random.bool() ? dir : 0;
        
        return FlxG.keys.anyPressed(_keys[dir]) ? dir : 0;
    }
    
    static public function randomDirTest():Void {
        
        for (i in 0 ... 10)
            trace(dirToString(getRandomDir()));
    }
    
    static function getRandomDir():Int {
        
        return 0x1 << (FlxG.random.int(0, 3) * 4);
    }
    
    inline function setNewDir(dir:Int):Void {
        
        switch (dir) {
            case RIGHT: velocity.set( SPEED, 0); _toTile.x += Level.SIZE; angle = 0;
            case LEFT : velocity.set(-SPEED, 0); _toTile.x -= Level.SIZE; angle = 180;
            case UP   : velocity.set(0, -SPEED); _toTile.y -= Level.SIZE; angle =-90;
            case DOWN : velocity.set(0,  SPEED); _toTile.y += Level.SIZE; angle = 90;
            case NONE :
                if (velocity.x != 0 || velocity.y != 0) {
                    
                    _stoppedTime = STOP_TIME;
                    alpha = 0.5;
                    velocity.set();
                }
        }
    }
    
    public function turnAround():Void {
        
        switch (_prevDir) {
            case RIGHT: setNewDir(_prevDir = LEFT );
            case LEFT : setNewDir(_prevDir = RIGHT);
            case UP   : setNewDir(_prevDir = DOWN );
            case DOWN : setNewDir(_prevDir = UP   );
            //case NONE :
        }
    }
    
    inline static function dirToString(dir:Int):String {
        
        var arr:Array<String> = [];
        if (dir & LEFT  > 0) arr.push("left" );
        if (dir & RIGHT > 0) arr.push("right");
        if (dir & UP    > 0) arr.push("up"   );
        if (dir & DOWN  > 0) arr.push("down" );
        
        if (arr.length == 0)
            return "none";
        
        return arr.join("|");
    }
    
    function getIsAtNode():Bool {
        
        return (velocity.x == 0 && velocity.y == 0)
            || velocity.x < 0 && x < _toTile.x
            || velocity.x > 0 && x > _toTile.x
            || velocity.y > 0 && y > _toTile.y
            || velocity.y < 0 && y < _toTile.y;
    }
    
    function isTileEmpty(x:Float, y:Float):Bool {
        
        return _level.getTileIndexByCoords(FlxPoint.weak(x, y)) > 0;
    }
    
    override function kill() {
        // super.kill();
        
        velocity.set();
        drill.kill();
        solid = false;
        FlxFlicker.flicker(this, 1.0, 0.02, false, true, (_) -> { alive = false; exists = false; });
    }
    
    override function revive() {
        super.revive();
        
        drill.revive();
    }
}

class Drill extends FlxObject {
    
    public var hero(default, null):Hero;
    
    public function new (hero:Hero) {
        super(0, 0, 4, 4);
        
        this.hero = hero;
    }
    
    
    override function kill() {
        super.kill();
        
        solid = false;
    }
    
    override function revive() {
        super.revive();
        
        solid = true;
    }
}