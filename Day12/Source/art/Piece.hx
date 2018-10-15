package art;

import flixel.effects.FlxFlicker;
import flixel.util.FlxColor;
import Main.GameState;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

import utils.Dir;

class Piece extends flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup<Block> {
    
    inline static public var SIZE = 8;
    inline static public var FALL = 8;//tiles per second
    
    inline static public var SNAKE_STEP  = 1;
    inline static public var TETRIS_STEP = 1;
    
    public var bottom(default, null) = 0.0;
    public var right (default, null) = 0.0;
    public var left  (default, null) = 0.0;
    public var motion(default, null) = 0;
    
    var _dir = Dir.NONE;
    
    public function new ():Void {
        super(5 * SIZE, 0 * SIZE);
        
        for (i in 0 ... 4) {
            
            add(new Block(0, -i * SIZE));
        }
        
        solid = false;
        redraw();
    }
    
    public function startIntro(callback:Void->Void):Void {
        
        FlxFlicker.flicker(this, 0.5, 0.04, true, true, (_)->{ onIntroComplete(); callback(); });
    }
    
    function onIntroComplete():Void {
        
        _dir = Dir.DOWN;
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
        
        if (!solid)
            stepSnake(num);
        else
            tetrisStep(num);
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
    
    function stepSnake(num) {
        
        var keyDirs = getKeyDirs(FlxG.keys.anyJustPressed);
        // var justKeyDirs = getKeyDirs(FlxG.keys.anyJustPressed);
        
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
        
        if (keyDirs != Dir.NONE && keyDirs & _dir != _dir) {
            
            if (keyDirs & Dir.WALL > 0 && keyDirs & Dir.NOTWALL > 0)
                keyDirs = keyDirs & (FlxG.random.bool() ? Dir.WALL : Dir.NOTWALL);
            
            _dir = keyDirs;
        }
        
        if (_dir == Dir.ANY || _dir == Dir.NONE)
            return;
        
        var pos = FlxPoint.get(members[0].x, members[0].y);
        var vel = FlxPoint.get
            ( Dir.axisSign(_dir, Dir.RIGHT) * SIZE
            , Dir.axisSign(_dir, Dir.DOWN ) * SIZE
            );
        
        if (pos.y + vel.y > SIZE * 5) {
            
            solidify();
            return;
        }
        
        x += vel.x;
        y += vel.y;
        pos.set(members[0].x, members[0].y);
        var temp = FlxPoint.get();
        for (i in 1 ... members.length) {
            
            temp.set(members[i].x, members[i].y);
            members[i].setPosition(pos.x - vel.x, pos.y - vel.y);
            pos.copyFrom(temp);
        }
        pos.put();
        vel.put();
        temp.put();
        redraw();
    }
    
    function redraw() {
        
        members[0].redraw(members[1]);
        members[1].redraw(members[0], members[2]);
        members[2].redraw(members[1], members[3]);
        members[3].redraw(members[2]);
    }
    
    public function tetrisStep(num) {
        
        if (num % TETRIS_STEP != 0)
            return;
        
        var speed = FALL;
        if (FlxG.keys.anyPressed([FlxKey.S, FlxKey.DOWN ]))
            speed *= 2;
        y += speed * SIZE / GameState.FPS;
        
        motion = 0;
        if (x + right + SIZE - 1 < FlxG.width && FlxG.keys.anyPressed([FlxKey.D, FlxKey.RIGHT]))
            motion = 1;
        else if (x + left - SIZE > -1 && FlxG.keys.anyPressed([FlxKey.A, FlxKey.LEFT ]))
            motion = -1;
    }
    
    public function solidify():Void {
        
        solid = true;
        //FlxFlicker.flicker(this, .25);
        
        bottom = getBottom();
        right  = getRight ();
        left   = getLeft  ();
        
        trace('bottom:${bottom/SIZE} left:${left/SIZE} right:${right/SIZE}');
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