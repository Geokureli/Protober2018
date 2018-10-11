package art;

import flixel.math.FlxPoint;

class Enemy extends flixel.FlxSprite{
    
    public function new (x:Float, y:Float):Void {
        super(x, y);
        
        firstDraw();
    }
    
    function firstDraw():Void {
        
        makeGraphic(32, 32, 0xFFFF0080, false, "enemy");
    }
    
    public function onHit(force:FlxPoint):Void {
        
        velocity.copyFrom(force);
        velocity.scale(2);
        drag.set(Math.abs(velocity.x), Math.abs(velocity.y));
    }
}