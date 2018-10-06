package art;

import data.Color;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;

class Enemy extends flixel.FlxSprite {
    
    static inline var WIDTH = 16;
    static inline var HEIGHT = 8;
    
    public var dropsBall = false;
    
    public function new (x:Float = 0, y:Float = 0) {
        
        super(x, y);
        loadGraphic("assets/Enemy.png", true, WIDTH, HEIGHT);
        animation.add("no_drop", [0]);
        animation.add("drop", [1]);
        
        revive();
    }
    
    override function revive() {
        super.revive();
        
        this.color = Color.getRandom();
        dropsBall = FlxG.random.bool(50);
        animation.play(dropsBall ? "drop" : "no_drop");
    }
    
    inline static public function generate(cols:Int, rows:Int):FlxTypedGroup<Enemy> {
        
        var group = new FlxTypedGroup<Enemy>();
        
        var spacing = FlxG.width / (cols + 1) - WIDTH;
        var startX = spacing;
        var startY = spacing;
        
        for (i in 0 ... cols) {
            
            for (j in 0 ... rows)
                group.add(new Enemy((i + 0.5) * (spacing + WIDTH), (j + 0.5) * (spacing + HEIGHT)));
        }
        
        return group;
    }
}