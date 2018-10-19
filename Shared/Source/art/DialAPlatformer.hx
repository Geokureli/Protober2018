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
    /** Full speed change when accelerating in the opposite direction of velocity on ground jumps */
    public var jumpDirectionChange = false;
    /** Full speed change when accelerating in the opposite direction of velocity on air jumps */
    public var airJumpDirectionChange = false;
    /** If true, the player can hold jump forever to keep ground jumping */
    public var allowSinglePressBounce = false;
    /** If true, the player can hold jump forever to keep ground jumping */
    public var autoApexAirJump = false;
    
    var _groundAcceleration:Float;
    var _groundDrag:Float;
    var _airAcceleration:Float;
    var _airDrag:Float;
    
    var _jumpVelocity:Float;
    var _jumpTime = 0.0;
    var _jumpTimer = Math.POSITIVE_INFINITY;
    var _coyoteTimer = 0.0;
    
    var _numAirJumpsLeft = 0;
    var _airJumpVelocity = 0.0;
    var _airJumpTime = 0.0;
    var _airJumpTimer = Math.POSITIVE_INFINITY;
    
    var _skidJumpVelocity = 0.0;
    var _skidJumpTime = 0.0;
    var _skidJumpTimer = Math.POSITIVE_INFINITY;
    
    var _wallJumpVelocity = 0.0;
    var _wallJumpTime = 0.0;
    var _wallJumpTimer = Math.POSITIVE_INFINITY;
    var _wallJumpXTime = -1.0;
    var _wallJumpXTimer = Math.POSITIVE_INFINITY;
    
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
        
        log ( 'setupJump($height, $timeToApex)'
            + '\n - gravity :${acceleration.y}'
            + '\n - velocity:$_jumpVelocity'
            );
    }
    
    function setupVariableJump(minHeight:Float, maxHeight:Float, timeToApex:Float) {
        
        setupJump(minHeight, timeToApex);
        _jumpTime = (maxHeight - minHeight) / -_jumpVelocity;
        _airJumpTime = _jumpTime;
        
        log ( 'setupVariableJump($minHeight, $maxHeight, $timeToApex)'
            + '\n - holdTime:$_jumpTime'
            );
    }
    
    function setupAirJump(height:Float) {
        
        //0 = v*v + 2*a*h
        // --> v*v = -2(a*h)
        // --> v = -Math.sqrt(2*a*h)
        _airJumpVelocity = -Math.sqrt(2 * acceleration.y * height);
        _airJumpTime = 0;
        
        log ( 'setupAirJump($height)'
            + '\n - velocity:$_airJumpVelocity'
            );
    }
    
    function setupVariableAirJump(minHeight:Float, maxHeight:Float) {
        
        setupAirJump(minHeight);
        _airJumpTime = (maxHeight - minHeight) / -_airJumpVelocity;
        
        log ( 'setupVariableAirJump($minHeight, $maxHeight)'
            + '\n - holdTime:$_airJumpTime'
            );
    }
    
    function setupWallJump(height:Float, width = -1.0) {
        
        _wallJumpVelocity = -Math.sqrt(2 * acceleration.y * height);
        _wallJumpTime = 0;
        
        if (width < 0) {
            
            var timeToApex = -_wallJumpVelocity / acceleration.y;
            _wallJumpXTime = _wallJumpTime;
        } else
            _wallJumpXTime = width / maxVelocity.x;
        
        log ( 'setupWallJump($height, $width)'
            + '\n - velocity :$_wallJumpVelocity'
            + '\n - xHoldTime:$_wallJumpXTime'
            );
    }
    
    function setupVariableWallJump(minHeight:Float, maxHeight:Float, width:Float) {
        
        setupWallJump(minHeight, width);
        _wallJumpTime = (maxHeight - minHeight) / -_wallJumpVelocity;
        
        log ( 'setupVariableAirJump($minHeight, $maxHeight, $width)'
            + '\n - holdTime:$_wallJumpTime'
            );
    }
    
    function setupSkidJump(height:Float) {
        
        _skidJumpVelocity = -Math.sqrt(2 * acceleration.y * height);
        
        log ( 'setupSkidJump($height)'
            + '\n - velocity:$_skidJumpVelocity'
            );
    }
    
    function setupVariableSkidJump(minHeight:Float, maxHeight:Float) {
        
        setupSkidJump(minHeight);
        _skidJumpTime = (maxHeight - minHeight) / -_skidJumpVelocity;
        
        log ( 'setupSkidJump($minHeight, $maxHeight)'
            + '\n - holdTime:$_skidJumpTime'
            );
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
        var timeToApex = -_jumpVelocity / acceleration.y;
        maxVelocity.x = jumpDistance / timeToApex / 2;
        
        if (slowDownTime < 0)
            slowDownTime = speedUpTime;
        
        if (airSpeedUpTime < 0)
            airSpeedUpTime = speedUpTime;
        
        if (airSlowDownTime < 0)
            airSlowDownTime = airSpeedUpTime;
        
        _groundAcceleration = getAccelerationFromTime(speedUpTime    );
        _groundDrag         = getAccelerationFromTime(slowDownTime   );
        _airAcceleration    = getAccelerationFromTime(airSpeedUpTime );
        _airDrag            = getAccelerationFromTime(airSlowDownTime);
        
        log ( 'setupSpeed($jumpDistance, $speedUpTime, $airSpeedUpTime, $slowDownTime, $airSlowDownTime)'
            + '\n - groundUp  :$_groundAcceleration'
            + '\n - groundDown:$_groundDrag'
            + '\n - airUp     :$_airAcceleration'
            + '\n - airDown   :$_airDrag'
            );
    }
    
    inline function getAccelerationFromTime(time:Float, backupTime = -1.0):Float {
        
        if (time == 0)
            time = 0.000001;
        
        return time == Math.POSITIVE_INFINITY
            ? 0
            : maxVelocity.x / time;
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
        var currentAcceleration = 0.0;
        var accelSign;
        if (_wallJumpXTimer < _wallJumpXTime)
            accelSign = FlxMath.signOf(velocity.x);
        else
            accelSign = (_keyStates['right'] ? 1 : 0) - (_keyStates['left'] ? 1 : 0);
        
        var isSkidding = accelSign != 0 && velocity.x != 0 && !FlxMath.sameSign(velocity.x, accelSign);
        
        _coyoteTimer += elapsed;
        if (isTouching(FlxObject.FLOOR))
            _coyoteTimer = 0;
        
        // Ground VS air status
        if (getOnCoyoteGround()) {
            
            _numAirJumpsLeft = numAirJumps;
            drag.x = _groundDrag;
            currentAcceleration = _groundAcceleration;
            _wallJumpXTimer = _wallJumpXTime + 1;
            
        } else {
            
            drag.x = _airDrag;
            currentAcceleration = _airAcceleration;
            _wallJumpXTimer += elapsed;
            
            if (!_keyStates['jump']) {
                
                _jumpTimer = _jumpTime + 1;
                _airJumpTimer = _airJumpTime + 1;
                _wallJumpTimer = _wallJumpTime + 1;
                _skidJumpTimer = _skidJumpTime + 1;
            }
        }
        
        var log = false;
        if (_keyStates['jump']) {
            
            if (getOnCoyoteGround() && (justPressed || allowSinglePressBounce)) {
                // Start jump
                
                if (isSkidding) {
                    
                    if (jumpDirectionChange)
                        velocity.x = accelSign * maxVelocity.x;
                    
                    if (_skidJumpVelocity != 0){
                        
                        skidJump(true);
                        _skidJumpTimer = 0;
                        _jumpTimer = _jumpTime + 1;
                    }
                    
                } else {
                    
                    jump(true);
                    _jumpTimer = 0;
                    _skidJumpTimer = _skidJumpTime + 1;
                }
                
                _coyoteTimer = coyoteTime;
                _airJumpTimer = _airJumpTime + 1.0;
                
            } else if (_jumpTimer <= _jumpTime) {
                // Maintain jump (key held)
                
                jump(false);
                _jumpTimer += elapsed;
                
            }else if (_skidJumpTimer <= _skidJumpTime){
                //maintain skid jump
                
                skidJump(false);
                _skidJumpTimer += elapsed;
                
            } else if (justPressed && _wallJumpVelocity != 0 && isLeaningOnWall(accelSign)) {
                // Start wall jump
                
                wallJump(true);
                _wallJumpTimer = 0;
                _wallJumpXTimer = 0;
                accelSign *= -1;
                velocity.x = maxVelocity.x * accelSign;
                
            } else if (_wallJumpTimer <= _wallJumpTime) {
                // Maintain wall jump
                
                wallJump(false);
                _wallJumpTimer += elapsed;
                
            } else if (_numAirJumpsLeft > 0 && _airJumpVelocity != 0 && (justPressed || (autoApexAirJump && velocity.y >= 0))) {
                // Start air jump
                
                if (isSkidding && airJumpDirectionChange)
                    velocity.x = accelSign * maxVelocity.x;
                
                airJump(true);
                _airJumpTimer = 0;
                _numAirJumpsLeft--;
                
            } else if (_airJumpTimer <= _airJumpTime) {
                // Maintain air jump (key held)
                
                airJump(false);
                _airJumpTimer += elapsed;
            }
        }
        
        // Horizontal movement
        acceleration.x = accelSign * currentAcceleration;
        
        super.update(elapsed);
    }
    
    inline function getOnCoyoteGround():Bool {
        
        return _coyoteTimer < coyoteTime || isTouching(FlxObject.FLOOR);
    }
    
    function isLeaningOnWall(accellSign:Float):Bool {
        return (isTouching(FlxObject.RIGHT) && accellSign > 0)
            || (isTouching(FlxObject.LEFT ) && accellSign < 0);
    }
    
    function jump(justPressed:Bool) {
        
        velocity.y = _jumpVelocity;
    }
    
    function airJump(justPressed:Bool) {
        
        velocity.y = _airJumpVelocity;
    }
    
    function wallJump(justPressed:Bool) {
        
        velocity.y = _wallJumpVelocity;
    }
    
    function skidJump(justPressed:Bool) {
        
        velocity.y = _skidJumpVelocity;
    }
    
    function updateKeys():Void {
        
        if (!_npcMode) {
            
            _keyStates['left' ] = FlxG.keys.anyPressed(_keys['left' ]);
            _keyStates['right'] = FlxG.keys.anyPressed(_keys['right']);
            _keyStates['jump' ] = FlxG.keys.anyPressed(_keys['jump' ]);
        }
    }
    
    /**
     * Override me to log stuff
     * @param msg Cool-speak for "Massage", I Think
     */
    function log(msg:String):Void {
        
        
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