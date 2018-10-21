package ui;

import Main.GameState;
import art.Hero;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

import openfl.events.KeyboardEvent;
import openfl.display.Sprite;

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
        getTimeField ("airDragTime").backup = _airSpeedTime;
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
        
        _gameState = cast FlxG.state;
        FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyPress);
    }
    
    function onKeyPress(e:KeyboardEvent):Void {
        
        if (e.keyCode == FlxKey.ENTER)
            _target.visible ? hide() : show();
    }
    
    public function show():Void {
        
        _target.visible = true;
        _gameState.exists = false;
    }
    
    public function hide():Void {
        
        setupPlayer();
        
        _target.visible = false;
        _gameState.exists = true;
    }
    
    function setupPlayer():Void {
        
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
            , _groundDragTime.float
            , _airSpeedTime.float
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
    
    inline function getField(name:String, startingValue = "", type = FieldWrapper.DISTANCE):FieldWrapper {
        
        var field = new FieldWrapper(get(_target, name), startingValue, type);
        _fields.push(field);
        Reflect.setField(this, "_" + name, field);
        return field;
    }
    
    inline function getToggle(name:String, defaultValue:Bool = false):CheckBoxWrapper {
        
        var toggle = new CheckBoxWrapper(get(_target, name), defaultValue);
        _toggles.push(toggle);
        Reflect.setField(this, "_" + name, toggle);
        return toggle;
    }
}