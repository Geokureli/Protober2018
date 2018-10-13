package utils;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.FlxObject;

class Dir {
    
    inline static public var LEFT   :Int = FlxObject.LEFT;
    inline static public var RIGHT  :Int = FlxObject.RIGHT;
    inline static public var UP     :Int = FlxObject.UP;
    inline static public var DOWN   :Int = FlxObject.DOWN;
    inline static public var NONE   :Int = FlxObject.NONE;
    inline static public var CEILING:Int = FlxObject.CEILING;
    inline static public var FLOOR  :Int = FlxObject.FLOOR;
    inline static public var WALL   :Int = FlxObject.WALL;
    inline static public var ANY    :Int = FlxObject.ANY;
    inline static public var NOTWALL:Int = ANY - WALL;
    
    inline static public function toString(dir:Int):String {
        
        var arr:Array<String> = [];
        if (dir & LEFT  > 0) arr.push("left" );
        if (dir & RIGHT > 0) arr.push("right");
        if (dir & UP    > 0) arr.push("up"   );
        if (dir & DOWN  > 0) arr.push("down" );
        
        if (arr.length == 0)
            return "none";
        
        return arr.join("|");
    }
    
    
    inline static public function getRandomDir():Int {
        
        return 0x1 << (FlxG.random.int(0, 3) * 4);
    }
    
    inline static public function getKeyDirs
        ( left :Array<FlxKey>
        , right:Array<FlxKey>
        , up   :Array<FlxKey>
        , down :Array<FlxKey>
        , negateOpposing:Bool = true
        ):Int {
        
        var keyDirs 
            = (FlxG.keys.anyPressed(left ) ? LEFT : 0)
            | (FlxG.keys.anyPressed(right) ? RIGHT: 0)
            | (FlxG.keys.anyPressed(up   ) ? UP   : 0)
            | (FlxG.keys.anyPressed(down ) ? DOWN : 0);
        
        if (negateOpposing) {
            
            if (keyDirs & Dir.WALL == Dir.WALL)
                keyDirs -= Dir.WALL;
            
            if (keyDirs & Dir.NOTWALL == Dir.NOTWALL)
                keyDirs -= Dir.NOTWALL;
        }
        
        return keyDirs;
    }
    
    
    inline static public function has(dir:Int, component:Int):Bool {
        
        return dir & component > 0;
    }
    
    inline static public function hasI(dir, component):Int {
        
        return has(dir, component) ? 1 : 0;
    }
    
    inline static public function axisSign(dir, fore):Int {
        
        return hasI(dir, fore) - hasI(dir, getOppositeSimple(fore));
    }
    
    inline static public function getOpposite(dir:Int):Int {
        
        return hasI(dir, LEFT ) * RIGHT
            |  hasI(dir, RIGHT) * LEFT
            |  hasI(dir, DOWN ) * UP
            |  hasI(dir, UP   ) * DOWN
            ;
    }
    
    inline static public function getOppositeSimple(dir:Int):Int {
        
        return switch(dir) {
            case LEFT : return RIGHT;
            case RIGHT: return LEFT;
            case DOWN : return UP;
            case UP   : return DOWN;
            default: return NONE;
        }
    }
    
    static public function fromDistance(x:Float, y:Float) {
        
        var dir = NONE;
        if (x != 0)
            dir = x > 0 ? RIGHT : LEFT;
        if (y != 0)
            dir = dir | (y > 0 ? UP : DOWN);
        return dir;
    }
}