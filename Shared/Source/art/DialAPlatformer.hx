package art;

import flixel.math.FlxMath;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;

class DialAPlatformer extends flixel.FlxSprite { 
    
    /** The time you can jump after walking off a cliff (ACME tm) */
    public var coyoteTime = 0.0;
    /** Whether to apply drag when accelerating in the opposite direction of velocity. */
    public var inverseDrag = true;
    public var numAirJumps = 0;
    
    var _groundAcceleration:Float;
    var _groundDrag:Float;
    var _airAcceleration:Float;
    var _airDrag:Float;
    
    var _jumpVelocity:Float;
    var _jumpHoldTime = 0.0;
    var _jumpHoldTimer = 0.0;
    var _coyoteTimer = 0.0;
    
    var _numAirJumpsLeft = 0;
    var _airJumpVelocity = 0.0;
    var _airJumpHoldTime = 0.0;
    var _airJumpHoldTimer = 0.0;
    
    var _wallJumpVelocity = 0.0;
    var _wallJumpHoldTime = 0.0;
    var _wallJumpHoldTimer = 0.0;
    var _wallJumpXVelocity =-1.0;
    var _wallJumpXHold =-1.0;
    
    var _keys:Map<String, Array<FlxKey>> = new Map<String, Array<FlxKey>>();
    var _keyStates:Map<String, Bool> = new Map<String, Bool>();
    var _npcMode = false;
    
    public function new (x = 0.0, y = 0.0, graphic = null) {
        super(x, y, graphic);
        
        setKeys([FlxKey.A, FlxKey.LEFT], [FlxKey.D, FlxKey.RIGHT], [FlxKey.SPACE, FlxKey.W, FlxKey.UP]);
    }
    
    function setupJump(height:Float, timeToApex:Float) {
        
        acceleration.y = 2 * height / timeToApex / timeToApex;
        _jumpVelocity = -2 * height / timeToApex;
        _airJumpVelocity = _jumpVelocity;
    }
    
    function setupVariableJump(minHeight:Float, maxHeight:Float, timeToApex:Float) {
        
        setupJump(minHeight, timeToApex);
        _jumpHoldTime = (maxHeight - minHeight) / -_jumpVelocity;
        _airJumpHoldTime = _jumpHoldTime;
    }
    
    function setupAirJump(height:Float) {
        
        //0 = v*v + 2*a*h
        // --> v*v = -2(a*h)
        // --> v = -Math.sqrt(2*a*h)
        _airJumpVelocity = -Math.sqrt(2 * acceleration.y * height);
        _airJumpHoldTime = 0;
    }
    
    function setupVariableAirJump(minHeight:Float, maxHeight:Float) {
        
        setupAirJump(minHeight);
        _airJumpHoldTime = (maxHeight - minHeight) / -_airJumpVelocity;
    }
    
    function setupSpeed
    ( jumpDistance   :Float
    , speedUpTime     = 0.25
    , airSpeedUpTime  = -1.0
    , slowDownTime    = -1.0
    , airSlowDownTime = -1.0
    ):Void {
        
        //0 = v + a * t
        // --> -v = a*t
        // --> -v/a = t
        var jumpUpTime = -_jumpVelocity / acceleration.y;
        maxVelocity.x = jumpDistance / jumpUpTime / 2;
        
        // Default(Ground) speed
        if(speedUpTime == 0)
            speedUpTime = 0.000001;
        _groundAcceleration = maxVelocity.x / speedUpTime;
        
        // Default(Ground) drag
        if (slowDownTime < 0)
            slowDownTime = speedUpTime;
        else if (slowDownTime == 0)
            slowDownTime = 0.000001;
        
        if (slowDownTime == Math.POSITIVE_INFINITY)
            _groundDrag = 0;
        else if (slowDownTime >= 0)
            _groundDrag = maxVelocity.x / slowDownTime;
        
        // Air speed
        if (airSpeedUpTime < 0)
            airSpeedUpTime = speedUpTime;
        else if (airSpeedUpTime == 0)
            airSpeedUpTime = 0.000001;
        
        if (airSpeedUpTime == Math.POSITIVE_INFINITY)
            _airAcceleration = 0;
        else
            _airAcceleration = maxVelocity.x / airSpeedUpTime;
        
        // Air drag
        if (airSlowDownTime < 0)
            airSlowDownTime = airSpeedUpTime;
        else if (airSlowDownTime == 0)
            airSlowDownTime = 0.000001;
        
        if (airSlowDownTime == Math.POSITIVE_INFINITY)
            _airDrag = 0;
        else if (airSlowDownTime >= 0)
            _airDrag = maxVelocity.x / airSlowDownTime;
    }
    
    function setKeys(left:Array<FlxKey>, right:Array<FlxKey>, jump:Array<FlxKey>):Void { 
        
        _keys['left' ] = left;
        _keys['right'] = right;
        _keys['jump' ] = jump;
        
        _keyStates['left' ] = false;
        _keyStates['right'] = false;
        _keyStates['jump' ] = false;
    }
    
    override public function update(elapsed:Float):Void {
        
        var justPressed = _keyStates['jump'];
        updateKeys();
        justPressed = _keyStates['jump'] && !justPressed;
        
        // Determine direction, set acceleration after jump
        var accellSign = 0.0;
        if (_keyStates['left' ]) accellSign = -1;
        if (_keyStates['right']) accellSign =  1;
        var currentAcceleration = 0.0;
        
        _coyoteTimer += elapsed;
        if (isTouching(FlxObject.FLOOR))
            _coyoteTimer = 0;
        
        if (getOnCoyoteGround()) {
            
            _jumpHoldTimer = 0;
            _numAirJumpsLeft = numAirJumps;
            drag.x = _groundDrag;
            currentAcceleration = _groundAcceleration;
            
        } else {
            
            drag.x = _airDrag;
            currentAcceleration = _airAcceleration;
            
            if (!_keyStates['jump']) {
                
                _jumpHoldTimer = _jumpHoldTime + 1;
                _airJumpHoldTimer = _airJumpHoldTime + 1;
            }
        }
        
        var log = false;
        if (_keyStates['jump']) {
            
            if (getOnCoyoteGround()) {
                // Start jump
                
                jump(true);
                _coyoteTimer = coyoteTime;
                _jumpHoldTimer = elapsed;
                _airJumpHoldTimer = _airJumpHoldTime + 1.0;
                
            } else if (_jumpHoldTimer <= _jumpHoldTime) {
                // Maintain jump (key held)
                
                jump(false);
                _jumpHoldTimer += elapsed;
                
                
            } else if (_numAirJumpsLeft > 0 && justPressed) {
                // Start air jump
                
                airJump(true);
                _airJumpHoldTimer = elapsed;
                _numAirJumpsLeft--;
                
            } else if (_airJumpHoldTimer <= _airJumpHoldTime) {
                // Maintain air jump (key held)
                
                airJump(false);
                _airJumpHoldTimer += elapsed;
            }
        }
        
        // Horizontal movement
        acceleration.x = accellSign * currentAcceleration;
        
        super.update(elapsed);
    }
    
    inline function getOnCoyoteGround():Bool {
        
        return _coyoteTimer < coyoteTime || isTouching(FlxObject.FLOOR);
    }
    
    function jump(justPressed:Bool) {
        
        velocity.y = _jumpVelocity;
    }
    
    function airJump(justPressed:Bool) {
        
        velocity.y = _airJumpVelocity;
    }
    
    function updateKeys():Void {
        
        if (!_npcMode) {
            
            _keyStates['left' ] = FlxG.keys.anyPressed(_keys['left' ]);
            _keyStates['right'] = FlxG.keys.anyPressed(_keys['right']);
            _keyStates['jump' ] = FlxG.keys.anyPressed(_keys['jump' ]);
        }
    }
    // --- --- --- --- --- ---
    // ---  HACKS, IGNORE  ---
    // --- --- --- --- --- ---
    
    override function updateMotion(elapsed:Float) { 
        
        if(inverseDrag)
            updateMotionInverseDrag(elapsed);
        else
            super.updateMotion(elapsed);
    }
    
    inline function updateMotionInverseDrag(elapsed:Float) {
        
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