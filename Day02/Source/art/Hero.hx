package art;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

class Hero extends FlxSprite {
    
    inline static var SPEED = 150;
    inline static var SPEED_UP_TIME = 0.1;
    inline static var ACCEL = SPEED / SPEED_UP_TIME;
    
    public var onStrike:HammerStrike->Void;
    public var _hammerStrike:HammerStrike;
    
    var _struck:Bool = false; 
    
    public function new (x:Float = 0, y:Float = 0){
        super(x, y);
        
        loadGraphic("assets/Hero.png", true, 112, 40);
        animation.add("idle"  , [0]          , 30, false);
        animation.add("windup", [1,2]        ,  8, false);
        animation.add("strike", [1,3,4,4,4,4], 30, false);
        animation.play("idle");
        
        width = height;
        offset.x = 22;
        origin.x = offset.x + origin.y;
        maxVelocity.set(SPEED, SPEED);
        
        _hammerStrike = new HammerStrike();
    }
    
    override public function update(elapsed:Float) {
        super.update(elapsed);
        
        if (animation.name != "strike") {
            
            var up    = FlxG.keys.pressed.W || FlxG.keys.pressed.UP;
            var down  = FlxG.keys.pressed.S || FlxG.keys.pressed.DOWN;
            var left  = FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT;
            var right = FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT;
            
            velocity.x = ((right ? 1 : 0) - (left ? 1 : 0)) * SPEED;
            velocity.y = ((down  ? 1 : 0) - (up   ? 1 : 0)) * SPEED;
            
            if (animation.name == "idle") {
                
                if      (velocity.y != 0) angle = velocity.y > 0 ? 90 : -90;
                else if (velocity.x != 0) angle = velocity.x > 0 ?  0 : 180;
            }
            
            if (animation.name == "idle" && FlxG.keys.justPressed.SPACE) {
                
                animation.play("windup");
                
            } else if (animation.name == "windup" && animation.finished && !FlxG.keys.pressed.SPACE)
                animation.play("strike");
            
        } else {
            
            if (animation.finished) {
                
                _struck = false;
                animation.play("idle");
                
            } else if (animation.frameIndex == 4 && !_struck) {
                // hammer landed
                _struck = true;
                FlxG.camera.shake(0.01, 0.125);
                
                _hammerStrike.strike(this);
                if (onStrike != null)
                    onStrike(_hammerStrike);
            }
        }
    }
}

class HammerStrike extends FlxObject {
    
    public var force(default, null):FlxPoint;
    
    public function new () {
        super (0, 0, 25, 25);
        
        force = FlxPoint.get();
    }
    
    public function strike(hero:Hero):Void {
        
        force.set(60).rotate(FlxPoint.get(), hero.angle);
        reset
            ( hero.x + force.x + width  * 0.5
            , hero.y + force.y + height * 0.5
            );
    }
}