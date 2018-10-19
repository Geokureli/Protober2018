package art;

import flixel.math.FlxMath;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;

class DialAPlatformer extends flixel.FlxSprite {
    
    /** logs jumps of all type, but only when they are started, not when maintained for variable jumps */
    public var enableJumpLogs = false;
    /** logs jumps of all type when they are maintained for variable jumps */
    public var enableVerboseJumpLogs = false;
    /** logs setup parameters when they change */
    public var enableParamLogs = false;
    /** The time you can jump after walking off a cliff (ACME tm) */
    public var coyoteTime = 0.0;
    /** Whether to apply drag when accelerating in the opposite direction of velocity. */
    public var skidDrag = true;
    /** Number of times you can jump in the air without touching the ground */
    public var numAirJumps = 0;
    /** Full speed change when accelerating in the opposite direction of velocity on ground jumps */
    public var jumpDirectionChange = false;
    /** Full speed change when accelerating in the opposite direction of velocity on air jumps */
    public var airJumpDirectionChange = false;
    /** If true, the player can hold jump forever to keep ground jumping */
    public var allowSinglePressBounce = false;
    /** If true, the player will air jump at the height of their jump, if air jumps are available */
    public var autoApexAirJump = false;
    /** Whether the hero has to press inward to the wall to wall jump */
    public var wallJumpLean = true;
    
    
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
    
    /**
     * Sets the jump arc by setting the gravity and jump velocity
     * @param height        The desired jump height in pixels
     * @param timeToApex    The time it takes to reach the top of the jump
     */
    function setupJump(height:Float, timeToApex:Float) {
        
        acceleration.y = 2 * height / timeToApex / timeToApex;
        _jumpVelocity = -2 * height / timeToApex;
        _airJumpVelocity = _jumpVelocity;
        
        logParam
            ( 'setupJump($height, $timeToApex)'
            + '\n - gravity :${acceleration.y}'
            + '\n - velocity:$_jumpVelocity'
            );
    }
    
    function setupVariableJump(minHeight:Float, maxHeight:Float, timeToApex:Float) {
        
        setupJump(minHeight, timeToApex);
        _jumpTime = (maxHeight - minHeight) / -_jumpVelocity;
        _airJumpTime = _jumpTime;
        
        logParam
            ( 'setupVariableJump($minHeight, $maxHeight, $timeToApex)'
            + '\n - holdTime:$_jumpTime'
            );
    }
    
    /**
     * Sets the air jump arc by setting the jump velocity based on gravity
     * @param height    The desired jump height in pixels
     */
    function setupAirJump(height:Float) {
        
        //0 = v*v + 2*a*h
        // --> v*v = -2(a*h)
        // --> v = -Math.sqrt(2*a*h)
        _airJumpVelocity = -Math.sqrt(2 * acceleration.y * height);
        _airJumpTime = 0;
        
        logParam
            ( 'setupAirJump($height)'
            + '\n - velocity:$_airJumpVelocity'
            );
    }
    
    /**
     * Sets the air jump arc by setting the jump velocity and how long they can hold the jump button
     * @param minHeight The desired jump height in pixels
     * @param maxHeight The desired jump height in pixels
     */
    function setupVariableAirJump(minHeight:Float, maxHeight:Float) {
        
        setupAirJump(minHeight);
        _airJumpTime = (maxHeight - minHeight) / -_airJumpVelocity;
        
        logParam
            ( 'setupVariableAirJump($minHeight, $maxHeight)'
            + '\n - holdTime:$_airJumpTime'
            );
    }
    
    
    /**
     * Sets the wall jump arc by setting the jump velocity based on gravity.
     * Wall Jumps are performed by touching a wall while jumping
     * @param height    The desired jump height in pixels
     * @param width     How far they should jump away from the wall, in pixels.
     *                  If set to -1 they will move away util the apex is reached
     */
    function setupWallJump(height:Float, width = -1.0) {
        
        _wallJumpVelocity = -Math.sqrt(2 * acceleration.y * height);
        _wallJumpTime = 0;
        
        if (width < 0) {
            
            var timeToApex = -_wallJumpVelocity / acceleration.y;
            _wallJumpXTime = _wallJumpTime;
        } else
            _wallJumpXTime = width / maxVelocity.x;
        
        logParam
            ( 'setupWallJump($height, $width)'
            + '\n - velocity :$_wallJumpVelocity'
            + '\n - xHoldTime:$_wallJumpXTime'
            );
    }
    
    /**
     * Sets the wall jump arc by setting the jump velocity and how long they can hold the jump button.
     * Wall Jumps are performed by touching a wall while jumping
     * @param minHeight The desired jump height in pixels
     * @param maxHeight The desired jump height in pixels
     * @param width     How far they should jump away from the wall, in pixels.
     *                  If set to -1 they will move away util the minimum apex
     *                  would have been reached
     */
    function setupVariableWallJump(minHeight:Float, maxHeight:Float, width:Float) {
        
        setupWallJump(minHeight, width);
        _wallJumpTime = (maxHeight - minHeight) / -_wallJumpVelocity;
        
        logParam
            ( 'setupVariableAirJump($minHeight, $maxHeight, $width)'
            + '\n - holdTime:$_wallJumpTime'
            );
    }
    
    /**
     * Sets the skid jump arc by setting the jump velocity based on gravity.
     * Skid jumps are performed by jumping while changing direction.
     * @param height    The desired jump height in pixels
     */
    function setupSkidJump(height:Float) {
        
        _skidJumpVelocity = -Math.sqrt(2 * acceleration.y * height);
        
        logParam
            ( 'setupSkidJump($height)'
            + '\n - velocity:$_skidJumpVelocity'
            );
    }
    
    /**
     * Sets the air jump arc by setting the jump velocity and how long they can hold the jump button.
     * Skid jumps are performed by jumping while changing direction.
     * @param minHeight The desired jump height in pixels
     * @param maxHeight The desired jump height in pixels
     */
    function setupVariableSkidJump(minHeight:Float, maxHeight:Float) {
        
        setupSkidJump(minHeight);
        _skidJumpTime = (maxHeight - minHeight) / -_skidJumpVelocity;
        
        logParam
            ( 'setupSkidJump($minHeight, $maxHeight)'
            + '\n - holdTime:$_skidJumpTime'
            );
    }
    
    /**
     * Sets the hero speed based on how far you want him to jump.
     * @param jumpDistance      The distance the hero can clear using their normal jump (maxHeight).
     * @param speedUpTime       How long it takes to go from full stop to full speed on the ground.
     * @param airSpeedUpTime    How long it takes to go from full stop to full speed run in the air.
     *                          If set to -1, speedUpTime is used.
     * @param slowDownTime      How long it takes to go from full speed run to a full stop on the ground.
     *                          If set to -1, speedUpTime is used.
     * @param airSlowDownTime   How long it takes to go from full speed run to a full stop in the air.
     *                          If set to -1, airSpeedUpTime is used.
     */
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
        var timeToApex = -_jumpVelocity / acceleration.y + _jumpTime;
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
        
        logParam
            ( 'setupSpeed($jumpDistance, $speedUpTime, $airSpeedUpTime, $slowDownTime, $airSlowDownTime)'
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
    
    /**
     * Sets which keys perform various actions
     */
    public function setKeys(left:Array<FlxKey>, right:Array<FlxKey>, jump:Array<FlxKey>):Void { 
        
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
        
        logJump(justPressed, 'jump $justPressed $_jumpTimer < $_jumpTime');
    }
    
    function airJump(justPressed:Bool) {
        
        velocity.y = _airJumpVelocity;
        logJump(justPressed, 'air jump $justPressed $_jumpTimer < $_airJumpTime');
    }
    
    function wallJump(justPressed:Bool) {
        
        velocity.y = _wallJumpVelocity;
        logJump(justPressed, 'wall jump $justPressed $_jumpTimer < $_wallJumpTime');
    }
    
    function skidJump(justPressed:Bool) {
        
        velocity.y = _skidJumpVelocity;
        logJump(justPressed, 'skid jump $justPressed $_jumpTimer < $_skidJumpTime');
    }
    
    function updateKeys():Void {
        
        if (!_npcMode) {
            
            _keyStates['left' ] = FlxG.keys.anyPressed(_keys['left' ]);
            _keyStates['right'] = FlxG.keys.anyPressed(_keys['right']);
            _keyStates['jump' ] = FlxG.keys.anyPressed(_keys['jump' ]);
        }
    }
    
    inline function log(msg:String):Void { trace (msg); }
    inline function logParam(msg:String):Void { if (enableParamLogs) log(msg); }
    inline function logJump(justTouched:Bool, msg:String):Void {
        
        if ((enableVerboseJumpLogs && !justTouched) || enableJumpLogs)
            log(msg);
    }
    
    // --- --- --- --- --- ---
    // ---  HACKS, IGNORE  ---
    // --- --- --- --- --- ---
    
    override function updateMotion(elapsed:Float) { 
        
        if(skidDrag)
            updateMotionSkidDrag(elapsed);
        else
            super.updateMotion(elapsed);
    }
    
    inline function updateMotionSkidDrag(elapsed:Float) {
        
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