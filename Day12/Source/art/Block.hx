package art;


import utils.Dir;

class Block extends flixel.FlxSprite {
    
    public function new (x:Float = 0, y:Float = 0) {
        super(x, y);
        
        loadGraphic("assets/tiles.png", true, Piece.SIZE, Piece.SIZE);
        for (i in 0 ... animation.frames)
            animation.add(Std.string(i), [i], 1, false);
        
        animation.play("0");
    }
    
    public function redraw(prev:Block, next:Block = null):Void {
        
        var dir = Dir.fromDistance(prev.x - x, prev.y - y);
        
        if (next != null)
            dir = dir | Dir.fromDistance(next.x - x, next.y - y);
        
        // probably an easier way to do this
        if (dir & Dir.RIGHT > Dir.NONE) dir = dir & ~Dir.RIGHT | 2;
        if (dir & Dir.UP    > Dir.NONE) dir = dir & ~Dir.UP    | 4;
        if (dir & Dir.DOWN  > Dir.NONE) dir = dir & ~Dir.DOWN  | 8;
        
        animation.play(Std.string(dir));
    }
}