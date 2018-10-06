package art;

import data.Color;
import Main.GameState;

import flixel.math.FlxMath;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

class Hero extends flixel.FlxSprite {
    
    inline static var SPEED = 200;
    inline static var SPEED_UP_TIME = 0.125;
    inline static var INV_SPD_TIME = 1 / SPEED_UP_TIME;
    inline static var Y_ZONE = GameState.Y_ZONE;
    
    public var onAction:Void->Void;
    
    public function new (x:Float = 0, y:Float = 0) {
        super(x, y, "assets/Hero.png");
        
        // makeGraphic(32, 8, 0xFFFFFFFF, false, "hero");
        
        maxVelocity.set(SPEED, SPEED);
        drag.copyFrom(maxVelocity).scale(INV_SPD_TIME);
        color = Color.ON;
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (Main.useMouse)
            updateMouse(elapsed);
        else
            updateKeys(elapsed);
        
        if (x < 0                   ) x = 0;
        if (x > FlxG.width  - width ) x = FlxG.width  - width;
        if (y < FlxG.height - Y_ZONE) y = FlxG.height - Y_ZONE;
        if (y > FlxG.height - height) y = FlxG.height - height;
    }
    
    static inline var CLICK_TIME = 0.1;
    var _pressTime = 0.0;
    function updateMouse(elapsed:Float):Void {
        
        setPosition(FlxG.mouse.x - width / 2, FlxG.mouse.y - height / 2);
        
        if (FlxG.mouse.justPressed)
            _pressTime = 0;
        else if (FlxG.mouse.justReleased) {
            
            if (_pressTime < CLICK_TIME)
                swapColors();
            
        } else
            _pressTime += elapsed;
    }
    
    function updateKeys(elapsed:Float):Void {
        
        var up    = FlxG.keys.anyPressed([FlxKey.W, FlxKey.UP   ]);
        var down  = FlxG.keys.anyPressed([FlxKey.S, FlxKey.DOWN ]);
        var left  = FlxG.keys.anyPressed([FlxKey.A, FlxKey.LEFT ]);
        var right = FlxG.keys.anyPressed([FlxKey.D, FlxKey.RIGHT]);
        
        acceleration.x = ((right ? 1 : 0) - (left ? 1 : 0)) * maxVelocity.x * INV_SPD_TIME;
        acceleration.y = ((down  ? 1 : 0) - (up   ? 1 : 0)) * maxVelocity.y * INV_SPD_TIME;
        
        if (FlxG.keys.justPressed.SPACE)
            swapColors();
    }
    
    inline function swapColors():Void {
        
        color = (color == Color.ON ? Color.OFF : Color.ON);
        
        if (onAction != null)
            onAction();
    }
    // --- --- --- --- --- ---
    // ---  HACKS, IGNORE  ---
    // --- --- --- --- --- ---
    
    override function updateMotion(elapsed:Float) { updateMotionNew(elapsed); }
    
    inline function updateMotionNew(elapsed:Float) {
        
        var velocityDelta = 0.5 * (computeVelocity(angularVelocity, angularAcceleration, angularDrag, maxAngular, elapsed) - angularVelocity);
        angularVelocity += velocityDelta; 
        angle += angularVelocity * elapsed;
        angularVelocity += velocityDelta;
        
        velocityDelta = 0.5 * (computeVelocity(velocity.x, acceleration.x, drag.x, maxVelocity.x, elapsed) - velocity.x);
        velocity.x += velocityDelta;
        x += velocity.x * elapsed;
        velocity.x += velocityDelta;
        
        velocityDelta = 0.5 * (computeVelocity(velocity.y, acceleration.y, drag.y, maxVelocity.y, elapsed) - velocity.y);
        velocity.y += velocityDelta;
        y += velocity.y * elapsed;
        velocity.y += velocityDelta;
    }
    
    public static function computeVelocity(velocity:Float, acceleration:Float, drag:Float, max:Float, elapsed:Float):Float
    {
        if (acceleration != 0)
        {
            velocity += acceleration * elapsed;
        }
        
        if (drag != 0 && (acceleration == 0 || !FlxMath.sameSign(velocity, acceleration)))
        {
            var drag:Float = drag * elapsed;
            if (velocity - drag > 0)
            {
                velocity -= drag;
            }
            else if (velocity + drag < 0)
            {
                velocity += drag;
            }
            else
            {
                velocity = 0;
            }
        }
        
        if ((velocity != 0) && (max != 0))
        {
            if (velocity > max)
            {
                velocity = max;
            }
            else if (velocity < -max)
            {
                velocity = -max;
            }
        }
        return velocity;
    }
}