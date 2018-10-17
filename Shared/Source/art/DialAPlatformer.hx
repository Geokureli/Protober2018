package art;

import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;

class DialAPlatformer extends flixel.FlxSprite { 
    
    /** The time you can jump after walking off a cliff (ACME tm) */
    
    public var coyoteTime = 0.0;
    
    var _jumpVelocity:Float;
    var _jumpUpTime:Float;
    var _moveAccel:Float;
    var _coyoteTimer = 0.0;
    var _jumpHoldTime = 0.0;
    var _jumpHoldTimer = 0.0;
    
    var _keys:Map<String, Array<FlxKey>> = new Map<String, Array<FlxKey>>();
    var _keyStates:Map<String, Bool> = new Map<String, Bool>();
    var _npcMode = false;
    
    public function new (x:Float = 0, y:Float = 0, graphic = null) { super(x, y, graphic); }
    
    function setupJump(jumpHeight:Float, jumpUpTime:Float, maxFallRatio:Float = 0) {
        
        _jumpUpTime = jumpUpTime;
        acceleration.y = 2 * jumpHeight / jumpUpTime / jumpUpTime;
        _jumpVelocity = -2 * jumpHeight / jumpUpTime;
        
        if (maxFallRatio > 0)
            maxVelocity.y = _jumpVelocity;
        
        setKeys([FlxKey.A, FlxKey.LEFT], [FlxKey.D, FlxKey.RIGHT], [FlxKey.SPACE, FlxKey.W, FlxKey.UP]);
    }
    
    function setupVariableJump(minJumpHeight:Float, maxJumpHeight:Float, minJumpUpTime:Float, maxFallRatio:Float = 0) {
        
        _jumpUpTime = minJumpUpTime;
        acceleration.y = 2 * minJumpHeight / minJumpUpTime / minJumpUpTime;
        _jumpVelocity = -2 * minJumpHeight / minJumpUpTime;
        
        _jumpHoldTime = (maxJumpHeight - minJumpHeight) / -_jumpVelocity;
        
        if (maxFallRatio > 0)
            maxVelocity.y = _jumpVelocity;
        
        setKeys([FlxKey.A, FlxKey.LEFT], [FlxKey.D, FlxKey.RIGHT], [FlxKey.SPACE, FlxKey.W, FlxKey.UP]);
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
    
    function setKeys(left:Array<FlxKey>, right:Array<FlxKey>, jump:Array<FlxKey>):Void { 
        
        _keys['left' ] = left;
        _keys['right'] = right;
        _keys['jump' ] = jump;
        
        _keyStates['left' ] = false;
        _keyStates['right'] = false;
        _keyStates['jump' ] = false;
    }
    
    override public function update(elapsed:Float):Void {
        
        updateKeys();
        
        acceleration.x = 0;
        
        if (_keyStates['left' ]) acceleration.x = -_moveAccel;
        if (_keyStates['right']) acceleration.x =  _moveAccel;
        
        _coyoteTimer += elapsed;
        if (isTouching(FlxObject.FLOOR))
            _coyoteTimer = 0;
        
        _jumpHoldTimer += elapsed;
        if (getOnCoyoteGround())
            _jumpHoldTimer = 0;
        else if (!_keyStates['jump'])
            _jumpHoldTimer = _jumpHoldTime;
        
        if (_keyStates['jump'] && getCanJump())
            jump();
        
        super.update(elapsed);
    }
    
    function getOnCoyoteGround():Bool {
        
        return _coyoteTimer < coyoteTime || isTouching(FlxObject.FLOOR);
    }
    
    function getCanJump():Bool {
        
        return getOnCoyoteGround() || _jumpHoldTimer <= _jumpHoldTime;
    }
    
    function jump() {
        
        velocity.y = _jumpVelocity;
        _coyoteTimer = coyoteTime;
    }
    
    function updateKeys():Void {
        
        if (!_npcMode) {
            
            _keyStates['left' ] = FlxG.keys.anyPressed(_keys['left' ]);
            _keyStates['right'] = FlxG.keys.anyPressed(_keys['right']);
            _keyStates['jump' ] = FlxG.keys.anyPressed(_keys['jump' ]);
        }
    }
}