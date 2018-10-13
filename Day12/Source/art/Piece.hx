package art;

import Main.GameState;
import flixel.effects.FlxFlicker;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.input.keyboard.FlxKey;

import utils.Dir;

class Piece extends flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup<Block> {
    
    inline static public var SIZE = 8;
    inline static public var FALL = 8;//tiles per second
    
    inline static public var SNAKE_STEP  = 8;
    inline static public var TETRIS_STEP = 1;
    
    var _dir = Dir.NONE;
    public var bottom(default, null) = 0.0;
    public var right (default, null) = 0.0;
    public var left  (default, null) = 0.0;
    public var motion(default, null) = 0;
    
    public function new (x:Float = 0, y:Float = 0):Void {
        super(x * SIZE, y * SIZE);
        
        for (i in 0 ... 4) {
            
            add(new Block(0, -i * SIZE));
        }
        
        solid = false;
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (!solid) {
            // Snake
            
        } else {
            // Tetris
        }
    }
    
    public function step(num:Int):Void {
        
        var keyDirs = getKeyDirs(FlxG.keys.anyPressed);
        var justKeyDirs = getKeyDirs(FlxG.keys.anyJustPressed);
        
        if (!solid)
            stepSnake(num, keyDirs);
        else
            tetrisStep(num, keyDirs);
    }
    
    inline function getKeyDirs(getter):Int {
        
        var dirs 
            = (getter([FlxKey.A, FlxKey.LEFT ]) ? Dir.LEFT  : 0)
            | (getter([FlxKey.D, FlxKey.RIGHT]) ? Dir.RIGHT : 0)
            | (getter([FlxKey.W, FlxKey.UP   ]) ? Dir.UP    : 0)
            | (getter([FlxKey.S, FlxKey.DOWN ]) ? Dir.DOWN  : 0);
            
        if (dirs & Dir.WALL == Dir.WALL)
            dirs -= Dir.WALL;
        
        if (dirs & Dir.NOTWALL == Dir.NOTWALL)
            dirs -= Dir.NOTWALL;
        
        return dirs;
    }
    
    function stepSnake(num, keyDirs) {
        
        if (num % SNAKE_STEP != 0)
            return;
        
        // prevent 180 turns
        if (_dir == Dir.LEFT  && keyDirs & Dir.RIGHT > 0) keyDirs -= Dir.RIGHT;
        if (_dir == Dir.RIGHT && keyDirs & Dir.LEFT  > 0) keyDirs -= Dir.LEFT ;
        if (_dir == Dir.UP    && keyDirs & Dir.DOWN  > 0) keyDirs -= Dir.DOWN ;
        if (_dir == Dir.DOWN  && keyDirs & Dir.UP    > 0) keyDirs -= Dir.UP   ;
        
        var hitEdge = false;
        if (members[0].x + SIZE * 2 > FlxG.width){
            
            hitEdge = true;
            keyDirs = keyDirs & ~Dir.RIGHT;
            
        } else if (members[0].x - SIZE < 0) {
            
            hitEdge = true;
            keyDirs = keyDirs & ~Dir.LEFT;
        }
        
        if (keyDirs == Dir.NONE && hitEdge)
            keyDirs = Dir.DOWN;
        
        if (keyDirs != Dir.NONE && (keyDirs != Dir.NONE || keyDirs & _dir != _dir))
            _dir = keyDirs;
        
        if (_dir == Dir.NONE)
            return;
        
        var pos = FlxPoint.get(members[0].x, members[0].y);
        var temp = FlxPoint.get
            ( Dir.axisSign(_dir, Dir.RIGHT) * SIZE
            , Dir.axisSign(_dir, Dir.DOWN ) * SIZE
            );
        
        if (pos.y + temp.y > SIZE * 5) {
            
            solidify();
            return;
        }
        
        members[0].x += temp.x;
        members[0].y += temp.y;
        
        for (i in 1 ... members.length) {
            
            temp.set(members[i].x, members[i].y);
            members[i].setPosition(pos.x, pos.y);
            pos.copyFrom(temp);
            if (i < members.length - 1)
                members[i].redraw(members[i-1], members[i+1]);
            else
                members[i].redraw(members[i-1]);
        }
        pos.put();
        temp.put();
        
        members[0].redraw(members[1]);
        members[1].redraw(members[0], members[2]);
        members[2].redraw(members[1], members[3]);
        members[3].redraw(members[2]);
    }
    
    public function tetrisStep(num, keyDirs) {
        
        if (num % TETRIS_STEP != 0)
            return;
        
        y += FALL * SIZE / GameState.FPS;
        
        var oldMotion = motion;
        
        motion = 0;
        if (x + right + SIZE - 1 < FlxG.width && Dir.has(keyDirs, Dir.RIGHT))
            motion = 1;
        else if (x + left - SIZE > -1 && Dir.has(keyDirs, Dir.LEFT))
            motion = -1;
    }
    
    public function solidify():Void {
        
        solid = true;
        //FlxFlicker.flicker(this, .25);
        
        bottom = getBottom();
        right  = getRight ();
        left   = getLeft  ();
    }
    
    function getBottom():Float {
        
        var max = 0.0;
        for (member in members)
            if (member.y - y > max)
                max = member.y - y;
        
        return max + SIZE;
    }
    
    function getRight():Float {
        
        var max = 0.0;
        for (member in members)
            if (member.x - x > max)
                max = member.x - x;
        
        return max + SIZE;
    }
    
    function getLeft():Float {
        
        var min = 10000000.0;
        for (member in members)
            if (member.x - x < min)
                min = member.x - x;
        
        return min;
    }
    
    
    function overlapsBody(pX:Float, pY:Float):Bool {
        
        for (i in 1 ... members.length){
            
            if (members[i].x == pX && members[i].y == pY)
                return true;
        }
        
        return false;
    }
}

class Block extends flixel.FlxSprite {
    
    public function new (x:Float = 0, y:Float = 0) {
        super(x, y);
        
        loadGraphic("assets/tiles.png", true, Piece.SIZE, Piece.SIZE);
        for (i in 0 ... animation.frames)
            animation.add(Std.string(i), [i], 1, false);
        
        animation.play("8");
    }
    
    public function redraw(prev:Block, next:Block = null, log:Bool = false):Void {
        
        var dir = Dir.fromDistance(prev.x - x, prev.y - y);
        if (log)
            trace('prev ${prev.x - x} ${prev.y - y} ${Dir.toString(dir)}');
        
        if (next != null) {
            
            dir = dir | Dir.fromDistance(next.x - x, next.y - y);
            if (log)
                trace('next ${next.x - x} ${next.y - y} ${Dir.toString(dir)}');
        }
        
        
        // probably an easier way to do this
        if (dir & Dir.RIGHT > Dir.NONE) dir = dir & ~Dir.RIGHT | 2;
        if (dir & Dir.UP    > Dir.NONE) dir = dir & ~Dir.UP    | 4;
        if (dir & Dir.DOWN  > Dir.NONE) dir = dir & ~Dir.DOWN  | 8;
        
        if (log)
            trace(dir);
        animation.play(Std.string(dir));
    }
}