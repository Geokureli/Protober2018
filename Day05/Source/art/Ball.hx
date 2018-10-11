package art;

import flixel.math.FlxRect;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;

class BallGroup extends flixel.group.FlxGroup.FlxTypedGroup<Ball>{
    
    public function new (maxSize:Int = 0):Void { super(maxSize); }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
    }
    
    override public function kill():Void
    {
        var i:Int = 0;
        var basic:Ball = null;
        
        while (i < length)
        {
            basic = members[i++];
            
            if (basic != null && basic.alive)
                basic.kill();
        }
        
        alive = false;
    }
    
    override public function revive():Void {
        var i:Int = 0;
        var basic:Ball = null;
    
        while (i < length)
        {
            basic = members[i++];
            
            if (basic != null && !basic.active)
                basic.revive();
        }
        
        alive = true;
    }
}

class Ball extends FlxSprite {
    
    public function new() {
        super(0, 0, "assets/Ball.png");
        
        // makeGraphic(8, 8, 0xFFFFFFFF, false, "ball");
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (x < 0 || x + width > FlxG.width)
            velocity.x *= -1;
        
        if (y < 0)
            velocity.y *= -1;
        
        if (y + height > FlxG.height) {
            
            kill();
            color = 0xff0000;
        }
    }
    
    override function kill() {
        
        alive = false;
        active = false;
    }
    
    override function revive() {
        
        alive = true;
        active = true;
    }
    
    public function onHit(target:FlxSprite, calcRebound:Bool):Bool {
        
        color = target.color;
        
        var intersect = FlxRect.get(x, y, width, height)
            .union(FlxRect.weak(target.x, target.y, target.width, target.height));
        
        var hasHit = true;
        
        if (intersect.width < intersect.height) {
            
            hasHit = FlxMath.sameSign(target.x - x, velocity.x);
            if (hasHit && calcRebound)
                velocity.x *= -1;
            
        } else {
            
            hasHit = FlxMath.sameSign(target.y - y, velocity.y);
            if (hasHit && calcRebound)
                velocity.y *= -1;
            
        }
        
        intersect.put();
        
        return hasHit;
    }
}