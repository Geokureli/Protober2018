package ui;

import Main.GameState;
import art.Hero;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

import openfl.events.KeyboardEvent;
import openfl.events.Event;
import openfl.display.Sprite;
import openfl.text.TextField;

class MenuWrapper extends UIWrapper {
    
    var _gameState:GameState;
    var _target:Sprite;
    
    var _fields:Array<FieldWrapper>;
    var _toggles:Array<CheckBoxWrapper>;
    
    var _minJump          :FieldWrapper;
    var _maxJump          :FieldWrapper;
    var _timeToApex       :FieldWrapper;
    var _coyoteTime       :FieldWrapper;
    var _bounce           :CheckBoxWrapper;
    
    var _jumpDistance     :FieldWrapper;
    var _skidDrag         :CheckBoxWrapper;
    var _groundSpeedTime  :FieldWrapper;
    var _groundDragTime   :FieldWrapper;
    var _groundSkidJump   :CheckBoxWrapper;
    var _airSpeedTime     :FieldWrapper;
    var _airDragTime      :FieldWrapper;
    var _airSkidJump      :CheckBoxWrapper;
    
    var _numAirJumps      :FieldWrapper;
    var _minAirJump       :FieldWrapper;
    var _maxAirJump       :FieldWrapper;
    var _autoApexJump     :CheckBoxWrapper;
    
    var _minWallJump      :FieldWrapper;
    var _maxWallJump      :FieldWrapper;
    var _wallJumpDistance :FieldWrapper;
    var _wallJumpTouchOnly:CheckBoxWrapper;
    
    var _minSkidJump      :FieldWrapper;
    var _maxSkidJump      :FieldWrapper;
    
    var _jumpVelocity     :TextField;
    var _jumpHoldTime     :TextField;
    var _gravity          :TextField;
    var _xSpeed           :TextField;
    var _airJumpVelocity  :TextField;
    var _airJumpHoldTime  :TextField;
    var _wallJumpVelocity :TextField;
    var _wallJumpHoldTime :TextField;
    var _skidJumpVelocity :TextField;
    var _skidJumpHoldTime :TextField;
    
    public function new(layout:Sprite):Void {
        super();
        
        _target = layout;
        _target.visible = false;
        _fields = [];
        _toggles = [];
        
        getField     ("minJump", "6.25");
        getField     ("maxJump").backup = _minJump;
        getTimeField ("timeToApex", "0.35");
        getTimeField ("coyoteTime");
        getToggle    ("bounce");
        
        getField     ("jumpDistance", "8");
        getToggle    ("skidDrag", true);
        getTimeField ("groundSpeedTime", "0.25");
        getTimeField ("groundDragTime").backup = _groundSpeedTime;
        getToggle    ("groundSkidJump");
        getTimeField ("airSpeedTime").backup = _groundSpeedTime;
        getTimeField ("airDragTime", "i").backup = _airSpeedTime;
        getToggle    ("airSkidJump");
        
        getCountField("numAirJumps", "0");
        getField     ("minAirJump", "3");
        getField     ("maxAirJump").backup = _minAirJump;
        getToggle    ("autoApexJump");
        
        getField     ("minWallJump");
        getField     ("maxWallJump").backup = _minWallJump;
        getField     ("wallJumpDistance");
        getToggle    ("wallJumpTouchOnly");
        
        getField     ("minSkidJump");
        getField     ("maxSkidJump").backup = _minSkidJump;
        
        _jumpVelocity     = getVarField('jumpVelocity'    );
        _jumpHoldTime     = getVarField('jumpHoldTime'    );
        _gravity          = getVarField('gravity'         );
        _xSpeed           = getVarField('xSpeed'          );
        _airJumpVelocity  = getVarField('airJumpVelocity' );
        _airJumpHoldTime  = getVarField('airJumpHoldTime' );
        _wallJumpVelocity = getVarField('wallJumpVelocity');
        _wallJumpHoldTime = getVarField('wallJumpHoldTime');
        _skidJumpVelocity = getVarField('skidJumpVelocity');
        _skidJumpHoldTime = getVarField('skidJumpHoldTime');
        
        multiUpdateCheck
            ( [_minJump, _maxJump, _timeToApex, _jumpDistance]
            , (e)->{ 
                    var timeToMin = 2 * _timeToApex.float * _minJump.float / (_minJump.float + _maxJump.float);
                    var jumpVelocity = -2 * _minJump.float / timeToMin;
                    _gravity.text = '${2 * _minJump.float / timeToMin / timeToMin}';
                    _jumpVelocity.text = '$jumpVelocity';
                    _jumpHoldTime.text = '${(_maxJump.float - _minJump.float) / -jumpVelocity}';
                    _xSpeed.text = '${_jumpDistance.float / _timeToApex.float / 2}';
                }
            );
        
        multiUpdateCheck
            ( [_minJump, _maxJump, _timeToApex, _minAirJump, _maxAirJump]
            , (e)->{ 
                    var timeToMin = 2 * _timeToApex.float * _minJump.float / (_minJump.float + _maxJump.float);
                    var gravity = 2 * _minJump.float / timeToMin / timeToMin;
                    var jumpVelocity = -Math.sqrt(2 * gravity * _minAirJump.float);
                    _airJumpVelocity.text = '$jumpVelocity';
                    _airJumpHoldTime.text = '${(_maxAirJump.float - _minAirJump.float) / -jumpVelocity}';
                }
            );
        
        multiUpdateCheck
            ( [_minJump, _maxJump, _timeToApex, _minWallJump, _maxWallJump]
            , (e)->{ 
                    var timeToMin = 2 * _timeToApex.float * _minJump.float / (_minJump.float + _maxJump.float);
                    var gravity = 2 * _minJump.float / timeToMin / timeToMin;
                    var jumpVelocity = -Math.sqrt(2 * gravity * _minWallJump.float);
                    _wallJumpVelocity.text = '$jumpVelocity';
                    _wallJumpHoldTime.text = '${(_maxWallJump.float - _minWallJump.float) / -jumpVelocity}';
                }
            );
        
        multiUpdateCheck
            ( [_minJump, _maxJump, _timeToApex, _minSkidJump, _maxSkidJump]
            , (e)->{ 
                    var timeToMin = 2 * _timeToApex.float * _minJump.float / (_minJump.float + _maxJump.float);
                    var gravity = 2 * _minJump.float / timeToMin / timeToMin;
                    var jumpVelocity = -Math.sqrt(2 * gravity * _minSkidJump.float);
                    _skidJumpVelocity.text = '$jumpVelocity';
                    _skidJumpHoldTime.text = '${(_maxSkidJump.float - _minSkidJump.float) / -jumpVelocity}';
                }
            );
        
        try {
            
            _gameState = cast FlxG.state;
            FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyPress);
            
        } catch(e:Dynamic){}
    }
    
    function multiUpdateCheck(fields:Array<FieldWrapper>, callback:Event->Void):Void {
        
        for (field in fields)
            field.addChangeListener(callback);
        
        callback(null);
    }
    
    function onKeyPress(e:KeyboardEvent):Void {
        
        if (e.keyCode == FlxKey.ENTER)
            _target.visible ? hide() : show();
    }
    
    public function show():Void {
        
        _target.visible = true;
        
        if (FlxG.game != null) {
            
            _gameState.exists = false;
            FlxG.game.visible = false;
        }
    }
    
    public function hide():Void {
        
        setupPlayer();
        
        _target.visible = false;
        if (FlxG.game != null) {
            
            _gameState.exists = true;
            FlxG.game.visible = true;
        }
    }
    
    function setupPlayer():Void {
        
        trace(_gameState.hero);
        var hero = _gameState.hero;
        hero.resetParams();
        
        hero.allowSinglePressBounce = _bounce.value;
        hero.coyoteTime = _coyoteTime.float;
        if (_maxJump.float > _minJump.float)
            hero.setupVariableJump(_minJump.float, _maxJump.float, _timeToApex.float);
        else
            hero.setupJump(_minJump.float, _timeToApex.float);
        
        hero.skidDrag = _skidDrag.value;
        hero.jumpDirectionChange = _groundSkidJump.value;
        hero.airJumpDirectionChange = _airSkidJump.value;
        hero.setupSpeed
            ( _jumpDistance.float
            , _groundSpeedTime.float
            , _airSpeedTime.float
            , _groundDragTime.float
            , _airDragTime.float
            );
        
        hero.numAirJumps = _numAirJumps.int;
        hero.autoApexAirJump = _autoApexJump.value;
        if (_numAirJumps.int > 0) {
            
            if (_maxAirJump.float > _minAirJump.float)
                hero.setupVariableAirJump(_minAirJump.float, _maxAirJump.float);
            else
                hero.setupAirJump(_minAirJump.float);
        }
        
        hero.wallJumpLean = !_wallJumpTouchOnly.value;
        if (_minWallJump.float > 0) {
            
            if (_maxWallJump.float > _minWallJump.float)
                hero.setupVariableWallJump(_minWallJump.float, _maxWallJump.float, _wallJumpDistance.float);
            else
                hero.setupWallJump(_minWallJump.float, _wallJumpDistance.float);
        }
        
        if (_minSkidJump.float > 0) {
            
            if (_maxSkidJump.float > _minSkidJump.float)
                hero.setupVariableSkidJump(_minSkidJump.float, _maxSkidJump.float);
            else
                hero.setupSkidJump(_minSkidJump.float);
        }
    }
    
    inline function getTimeField(name:String, startingValue:String = ""):FieldWrapper {
        
        return getField(name, startingValue, FieldWrapper.TIME);
    }
    
    inline function getCountField(name:String, startingValue:String = ""):FieldWrapper {
        
        return getField(name, startingValue, FieldWrapper.COUNT);
    }
    
    inline function getVarField(name:String):TextField {
        
        var target:TextField = get(_target, name);
        
        target.textColor = 0xD77BBA;
        target.background = false;
        target.border = true;
        target.borderColor = 0xD77BBA;
        
        return target;
    }
    
    inline function getField(name:String, startingValue = "", type = FieldWrapper.DISTANCE):FieldWrapper {
        
        var target:TextField = get(_target, name);
        
        target.borderColor = target.textColor;
        var field = null;
        if (target != null) {
            
            field = new FieldWrapper(target, startingValue, type);
            _fields.push(field);
            Reflect.setField(this, "_" + name, field);
            
        } else {
            
            trace('$name not found');
        }
        
        return field;
    }
    
    inline function getToggle(name:String, defaultValue:Bool = false):CheckBoxWrapper {
        
        var toggle = new CheckBoxWrapper(get(_target, name), defaultValue);
        _toggles.push(toggle);
        Reflect.setField(this, "_" + name, toggle);
        return toggle;
    }
}