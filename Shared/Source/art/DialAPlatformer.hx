package art;

import flixel.FlxG;
import flixel.FlxObject;

class DialAPlatformer extends flixel.FlxSprite { 
    
    var _jumpVelocity:Float;
    var _jumpUpTime:Float;
    var _moveAccel:Float;
    
    public function new (x:Float = 0, y:Float = 0, graphic = null) { super(x, y, graphic); }
    
    function setupJump(jumpHeight:Float, jumpUpTime:Float, maxFallRatio:Float = 0) {
        
        _jumpUpTime = jumpUpTime;
        acceleration.y = 2 * jumpHeight / jumpUpTime / jumpUpTime;
        _jumpVelocity = -2 * jumpHeight / jumpUpTime;
        
        if (maxFallRatio > 0)
            maxVelocity.y = _jumpVelocity;
    }
    
    function setupSpeed(jumpDistance:Float, speedUpTime:Float = 0.25, slowDownTime:Float = -1):Void {
        
        maxVelocity.x = jumpDistance / _jumpUpTime / 2;
        
        if(speedUpTime == 0)
            speedUpTime = 0.000001;
        _moveAccel = maxVelocity.x / speedUpTime;
        
        if (slowDownTime <= 0)
            slowDownTime = speedUpTime;
        else if (slowDownTime == 0)
            slowDownTime = 0.000001;
        
        if (slowDownTime >= 0)
            drag.x = maxVelocity.x / slowDownTime;
        
        trace('speed:${maxVelocity.x} accel:$_moveAccel drag:${drag.x}');
    }
    
    override public function update(elapsed:Float):Void {
        
        acceleration.x = 0;
        
        if (FlxG.keys.anyPressed([LEFT, A]))
            acceleration.x = -_moveAccel;
        
        if (FlxG.keys.anyPressed([RIGHT, D]))
            acceleration.x = _moveAccel;
        
        if (FlxG.keys.anyJustPressed([SPACE, UP, W]) && isTouching(FlxObject.FLOOR))
            velocity.y = _jumpVelocity;
        
        super.update(elapsed);
    }
}