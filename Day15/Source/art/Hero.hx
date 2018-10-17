package art;

import art.Enemy.EnemyBullet;

import flixel.FlxG;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxVector;
import flixel.math.FlxPoint;

class Hero extends flixel.FlxSprite {
    
    static inline var SPEED = 100;
    
    public var useKeys = true;
    public var gun(default, null) = new Gun<HeroBullet>(()->{ return new HeroBullet(); });
    public var absorber(default, null):Absorber;
    
    public function new () {
        super();
        
        loadGraphic("assets/Hero.png");
        width -= 4;
        height -= 4;
        offset.set(2, 2);
        absorber = new Absorber(this);
        toSpawnPoint();
    }
    
    inline function toSpawnPoint():Void {
        
        x = (FlxG.width - width) / 2;
        y = FlxG.height - 16 - height;
    }
    
    override function update(elapsed:Float) {
        if (useKeys)
            updateKeys(elapsed);
        else
            updateMouse(elapsed);
        
        super.update(elapsed);
        
        if (x + width > FlxG.width)
            x = FlxG.width - width;
        
        if (x < 0)
            x = 0;
        
        if (y + height > FlxG.height)
            y = FlxG.height - height;
        
        absorber.x = x - (absorber.width  - width ) / 2;
        absorber.y = y - (absorber.height - height) / 2;
    }
    
    function updateKeys(elapsed:Float):Void {
        
        velocity.x
            = (FlxG.keys.anyPressed([FlxKey.D, FlxKey.RIGHT]) ? SPEED : 0)
            - (FlxG.keys.anyPressed([FlxKey.A, FlxKey.LEFT ]) ? SPEED : 0);
        
        velocity.y
            = (FlxG.keys.anyPressed([FlxKey.S, FlxKey.DOWN]) ? SPEED : 0)
            - (FlxG.keys.anyPressed([FlxKey.W, FlxKey.UP  ]) ? SPEED : 0);
    }
    
    function updateMouse(elapsed:Float):Void {
        
        var dis = FlxPoint.get(FlxG.mouse.x - x, FlxG.mouse.y - y);
        velocity.x = dis.x > 0 ? SPEED : -SPEED;
        velocity.y = dis.y > 0 ? SPEED : -SPEED;
        
        if (velocity.x * elapsed > dis.x) {
            
            velocity.x = 0;
            x += dis.x;
        }
        
        if (velocity.y * elapsed > dis.y) {
            
            velocity.y = 0;
            y += dis.y;
        }
    }
    
    public function checkBullets(bullets:Gun<EnemyBullet>) {
        
        FlxG.overlap(absorber, bullets, checkBullet);
    }
    
    function checkBullet(_, bullet:EnemyBullet) {
        
        var diff = FlxVector.get
            ( centerX - bullet.centerX
            , centerY - bullet.centerY
            );
        
        if (diff.lengthSquared < absorber.radiusSquared && bullet.full) {
            
            bullet.absorb(this);
            gun.shoot(centerX, centerY, 0, -200);
        }
        
        diff.put();
    }
    
    override function kill() {
        super.kill();
        
        absorber.kill();
    }
    
    override function revive() {
        super.revive();
        
        toSpawnPoint();
        absorber.revive();
        solid = false;
        FlxFlicker.flicker(this, 0.5, 0.04, true, true, (_) -> { solid = true; });
    }
    
    public var centerX(get, never):Float;
    inline function get_centerX():Float { return x + width / 2; }
    public var centerY(get, never):Float;
    inline function get_centerY():Float { return y + height / 2; }
}

class HeroBullet extends Bullet {
    
    var _hasInner:Bool = true;
    
    public function new () { super("assets/HeroBullet.png"); }
    
    override function init(x:Float, y:Float, vX:Float = 0, vY:Float = 0) {
        super.init(x, y, vX, vY);
        
        _hasInner = true;
    }
}

class Absorber extends flixel.FlxSprite {
    
    public var radiusSquared(default, null) = 0.0;
    
    public var hero(default, null):Hero;
    
    public function new (hero:Hero) {
        super(0, 0, "assets/HeroOrb.png");
        
        this.hero = hero;
        scale.set(1.5, 1.5);
        updateHitbox();
        radiusSquared = (width + 8) * (width + 8) / 4;// add enemy bullet radius (8)
        // alpha = .25;
    }
    
    public var centerX(get, never):Float;
    inline function get_centerX():Float { return x + width / 2; }
    public var centerY(get, never):Float;
    inline function get_centerY():Float { return y + height / 2; }
}