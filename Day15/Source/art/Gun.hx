package art;

import flixel.math.FlxVector;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;

class Gun<T:Bullet> extends FlxTypedGroup<T> {
    
    public var shotsFired(default, null) = 0;
    
    var _factory:Void->T;
    
    public function new (factory:Void->T) {
        super();
        
        _factory = factory;
    }
    
    public function shoot(x:Float, y:Float, vX:Float = 0, vY:Float = 0):T {
        
        shotsFired++;
        var bullet = recycle(null, _factory);
        bullet.init(x, y, vX, vY);
        return bullet;
    }
    
    inline public function shootP(start:FlxPoint, velocity:FlxPoint):T {
        
        var bullet = shoot(start.x, start.y, velocity.x, velocity.y);
        start.putWeak();
        velocity.putWeak();
        return bullet;
    }
    
    inline public function shootAt(x:Float, y:Float, x2:Float, y2:Float, speed:Float = 0):T {
        
        var dis = FlxVector.get(x2 - x, y2 - y);
        speed /= dis.length;
        return shoot(x, y, dis.x * speed, dis.y * speed);
    }
    
    inline public function shootAtP(start:FlxPoint, end:FlxPoint, speed:Float = 0):T {
        
        return shootAt(start.x, start.y, end.x, end.y, speed);
    }
    
    inline public function shootDegrees(x:Float, y:Float, degrees:Float, speed:Float = 0):T {
        
        var dis = FlxVector.get(speed).rotateByDegrees(degrees);
        return shoot(x, y, dis.x, dis.y);
    }
    
    inline public function shootDegreesP(start:FlxPoint, degrees:Float, speed:Float = 0):T {
        
        return shootDegrees(start.x, start.y, degrees, speed);
    }
    
    inline public function shootRadians(x:Float, y:Float, radians:Float, speed:Float = 0):T {
        
        var dis = FlxVector.get(speed).rotateByDegrees(radians);
        return shoot(x, y, dis.x, dis.y);
    }
    
    inline public function shootRadiansP(start:FlxPoint, radians:Float, speed:Float = 0):T {
        
        return shootRadians(start.x, start.y, radians, speed);
    }
}