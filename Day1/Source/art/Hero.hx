package art;

import Main1.HealthBar;
import flixel.FlxG;

class Hero extends WrapSprite {
    
    public var onShoot:Bullet->Void;
    public var invincible(get, never):Bool;
    function get_invincible():Bool { return _flashing > 0; }
    
    var _healthBar:HealthBar;
    var _flashing:Int;
    
    public function new (x:Float = 0, y:Float = 0, healthBar:HealthBar) {
        super(x, y);
        
        makeGraphic(16, 16, 0xFF0000FF);
        
        maxVelocity.set(200, 200);
        
        _healthBar = healthBar;
        health = 3;
        _healthBar.value = 3;
    }
    
    override public function update(elapsed:Float) {
        super.update(elapsed);
        
        var up    = FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP;
        var down  = FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN;
        var left  = FlxG.keys.justPressed.A || FlxG.keys.justPressed.LEFT;
        var right = FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT;
        
        if      (up)    shootBullet( 0, -1);
        else if (down)  shootBullet( 0,  1);
        else if (left)  shootBullet(-1,  0);
        else if (right) shootBullet( 1,  0);
        
        if (_flashing > 0) {
            
            trace(_flashing % 4 > 2);
            
            if (_flashing % 8 > 2)
                setColorTransform(1, 1, 1, 1, 0xFF, 0xFF, 0xFF);
            else
                setColorTransform();
            
        } else if (_flashing == 0)
            setColorTransform();
        
        _flashing--;
    }
    
    function shootBullet(dirX:Float, dirY:Int):Void {
        
        var bullet = Bullet.get
            ( x + (width * 0.5)  + dirX * 0.5 * width
            , y + (height * 0.5) + dirY * 0.5 * height
            , dirX * Bullet.SPEED// + velocity.x
            , dirY * Bullet.SPEED// + velocity.y
            );
        velocity.subtractPoint(bullet.force);
        onShoot(bullet);
    }
    
    public function hitEnemy():Void {
        
        _flashing = 64;
        setColorTransform(1, 1, 1, 1, 0xFF, 0xFF, 0xFF);
        health--;
        _healthBar.value = Std.int(health);
        if (health == 0)
            kill();
    }
}