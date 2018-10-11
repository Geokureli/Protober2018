package art;

import flixel.math.FlxPoint;

class EnemySpawner {
    
    static var types:Array<Class<Enemy>> = [DumbEnemy, SeekerEnemy];
    
    inline static public function spawn(hero:Hero):Enemy {
        
        return Type.createInstance(types[Std.int(Math.random() * types.length)], [hero]);
    }
}

class Enemy extends WrapSprite {
    
    var _hero:Hero;
    var _flashing:Int;
    
    public function new (hero:Hero) {
        
        _hero = hero;
        
        super();
        firstDraw();
        init();
    }
    
    function init():Void {
        
        health = 5;
        _flashing = 0;
        setToEdge();
    }
    
    function firstDraw():Void {}
    
    public function onHit(bullet:Bullet):Void {
        
        velocity.addPoint(bullet.force);
        _flashing = 16;
        setColorTransform(1, 1, 1, 1, 0xFF, 0xFF, 0xFF);
        health--;
        if (health <= 0)
            init();
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (_flashing > 0) {
            
            if (_flashing % 4 > 2)
                setColorTransform(1, 1, 1, 1, 0xFF, 0xFF, 0xFF);
            else
                setColorTransform();
            
        } else if (_flashing == 0)
            setColorTransform();
        
        _flashing--;
    }
    
    override function destroy() {
        super.destroy();
        
        _hero = null;
    }
}

class DumbEnemy extends Enemy {
    
    public function new (hero:Hero) {
        super(hero);
        
        velocity.set(Math.random() * 25 + 25, 0);
        velocity.rotate(FlxPoint.weak(), Math.random() * 360);
    }
    
    override function firstDraw():Void {
        
        makeGraphic(24, 24, 0xFFFF0000, false, "dumb_enemy");
    }
}

class SeekerEnemy extends Enemy {
    
    inline static var SPEED:Float = 100;
    inline static var JERK:Float = 100;
    
    public function new (hero:Hero) {
        super(hero);
        
        maxVelocity.set(SPEED, SPEED);
    }
    
    override function firstDraw():Void {
        
        makeGraphic(24, 24, 0xFFFF0080, false, "seeker_enemy");
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        acceleration.set(_hero.x - x, _hero.y - y);
        acceleration.scale(JERK / acceleration.distanceTo(FlxPoint.weak()));
    }
}