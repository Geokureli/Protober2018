package art;

import flixel.math.FlxPoint;

class Bullet extends flixel.FlxSprite {
    
    static public inline var SPEED:Float = 200;
    static public inline var FORCE:Float = 40;
    
    static var _pool:Array<Bullet> = [];
    
    public var force(default, null):FlxPoint;
    
    public function new (x:Float, y:Float, xSpeed:Float, ySpeed:Float) {
        super();
        
        makeGraphic(8, 8, 0xFF00FFFF, false, "bullet");
        force = new FlxPoint();
        init(x, y, xSpeed, ySpeed);
    }
    
    public function init(x:Float, y:Float, xSpeed:Float, ySpeed:Float):Bullet {
        
        this.x = x - width  * .5;
        this.y = y - height * .5;
        velocity.set(xSpeed, ySpeed);
        force.copyFrom(velocity).scale(FORCE / SPEED);
        
        return this;
    }
    
    inline static public function get(x:Float, y:Float, xSpeed:Float, ySpeed:Float):Bullet {
        
        var bullet;
        
        if (_pool.length > 0) {
            
            bullet = _pool.shift().init(x, y, xSpeed, ySpeed);
            
        } else
            bullet = new Bullet(x, y, xSpeed, ySpeed);
        
        return bullet;
    }
    
    inline public function put():Bullet {
        
        if (this != null)
            _pool.push(this);
        
        return this;
    }
}