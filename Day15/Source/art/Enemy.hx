package art;

import flixel.FlxSprite;
import flixel.FlxG;

import haxe.macro.Expr;

typedef ShootStyle = Float->Float->Void;

class Enemy extends flixel.group.FlxSpriteGroup {
    
    public var hero:Hero;
    
    var _face:FlxSprite;
    var _shootTimer = 0.0;
    var _styleTimer = 0.0;
    var _styles:Array<ShootStyle>;
    var _currentStyle:ShootStyle;
    
    public var gun(default, null):Gun<EnemyBullet>;
    
    public function new () {
        super(1, 1);
        
        _face = new FlxSprite(0, 0);
        _face.loadGraphic("assets/Enemy.png", true, 211, 32);
        _face.animation.add("idle", [0], 8, false);
        _face.animation.add("hit", [1, 0], 30, false);
        _face.animation.play("idle");
        add(_face);
        
        gun = new Gun<EnemyBullet>(() -> { return new EnemyBullet(); });
        _styles = 
            [ style_edgeSpray
            , style_shootAtHero
            , style_burstAtHero
            , style_streamDown3
            // , style_wait
            ];
        
        chooseRandomStyle(0);
    }
    
    function chooseRandomStyle(index:Int = -1):Void {
        
        _styleTimer = 0.0;
        _shootTimer = 0.0;
        _shotsFiredPrev = gun.shotsFired;
        
        if (index == -1)
            index = FlxG.random.int(0, _styles.length - 1);
        
        _currentStyle = _styles[index];
    }
    
    public function onHit():Void {
        
        _face.animation.play("hit", true);
        health--;
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        _styleTimer += elapsed;
        
        _currentStyle(elapsed, _styleTimer);
    }
    
    function style_streamDown3(elapsed:Float, total:Float):Void {
        
        if (total > 1) {
            
            _shootTimer -= elapsed;
            if (_shootTimer <= 0) {
                
                _shootTimer += 1/8;
                gridX(x + (total - 1) * width / 3 / 3, y + height, 3, width / 3, 200);
            }
        }
        
        if (total > 4)
            chooseRandomStyle();
    }
    
    function style_streamDown2(elapsed:Float, total:Float):Void {
        
        if (total % 2 > .5) {
            
            _shootTimer -= elapsed;
            if (_shootTimer <= 0) {
                
                _shootTimer += 1/8;
                var shootX = (total - 1) * width / 4 / 3;
                for (i in 0 ... 4)
                    gun.shoot(x + shootX + width / 4 * i, y + height, 0, 200);
            }
        }
        
        if (total > 8)
            chooseRandomStyle();
    }
    
    function style_shootAtHero(elapsed:Float, total:Float):Void {
        
        _shootTimer -= elapsed;
        if (_shootTimer <= 0) {
            
            _shootTimer += 1/4;
            gun.shootAt(centerX, centerY, hero.centerX, hero.centerY, 200);
        }
        
        if (total > 4)
            chooseRandomStyle();
    }
    
    function style_burstAtHero(elapsed:Float, total:Float):Void {
        
        _shootTimer -= elapsed;
        if (_shootTimer <= 0) {
            
            _shootTimer += _shotsFired % 3 == 2 ? 5/8 : 1/8;
            gun.shootAt(centerX, centerY, hero.centerX, hero.centerY, 200);
        }
        
        if (total > 4)
            chooseRandomStyle();
    }
    
    function style_edgeSpray(elapsed:Float, total:Float):Void {
        
        _shootTimer -= elapsed;
        if (_shootTimer <= 0) {
            
            _shootTimer += 1/4;
            var angle = first
                ([ at(total, 0, 0, 1)
                ,  fromTo(total,  0, 15, 1, 3)
                ,  at(total, 15, 3, 4)
                ,  fromTo(total, 15,  0, 4, 7)
                ]);
            
            if (angle >= 0){
                
                spray(x        , y, 5, 90 - angle, -15, 100);
                spray(x + width, y, 5, 90 + angle,  15, 100);
            }
        }
        
        if (total > 9)
            chooseRandomStyle();
    }
    
    function style_wait(elapsed:Float, total:Float):Void {
        
        if (total > 2)
            chooseRandomStyle();
    }
    
    
    // macro static function first(list:Array<Expr>) {
        
    //     return macro _first([list]);
    // }
    
    static function first(list:Array<Float>):Float {
        
        for (i in 0 ... list.length)
            if (list[i] >= 0)
                return list[i];
        
        return -1;
    }
    
    inline static function fromTo(time:Float, start:Float, end:Float, startTime:Float, endTime:Float):Float {
        
        var value = -1.0;
        if (time <= endTime && time >= startTime)
            value = start + (end - start) * (time - startTime) / (endTime - startTime);
        return value;
    }
    
    inline static function at(time:Float, value:Float, startTime:Float, endTime:Float):Float {
        
        if (time > endTime || time < startTime)
            value = -1.0;
        return value;
    }
    
    function spray(x:Float, y:Float, num:Int, startAngle:Float, angle:Float, speed:Float):Void {
        
        for (i in 0 ... num)
            gun.shootDegrees(x, y, startAngle + i * angle, speed);
    }
    
    inline function gridX(x:Float, y:Float, num:Int, dis:Float, speed:Float):Void {
        
        for (i in 0 ... num)
            gun.shoot(x + dis * i, y, 0, speed);
    }
    
    var _shotsFiredPrev = 0;
    var _shotsFired(get, never):Int;
    inline function get__shotsFired():Int { return gun.shotsFired - _shotsFiredPrev; }
    public var centerX(get, never):Float;
    inline function get_centerX():Float { return x + width / 2; }
    public var centerY(get, never):Float;
    inline function get_centerY():Float { return y + height / 2; }
}

class EnemyBullet extends Bullet {
    
    inline static public var SPEED = 100;
    
    public var full(default, null) = true;
    
    public function new 
    ( graphic :String = "assets/EnemyBullet.png"
    , width   :Int    = 8
    , height  :Int    = 8
    ) {
        super(graphic, width, height);
        animation.add("full" , [2, 3], 15);
        animation.add("empty", [0, 1], 15);
        
        this.width  -= 2;
        this.height -= 2;
        offset.set(1, 1);
        // trace('w:$width h: $height');
    }
    
    override function init(x:Float, y:Float, vX:Float = 0, vY:Float = 0) {
        super.init(x, y, vX, vY);
        
        full = true;
        animation.play("full");
    }
    
    public function absorb(hero:Hero) {
        
        full = false;
        animation.play("empty");
    }
}