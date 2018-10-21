package ui;

import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.text.TextField;

class FieldWrapper extends UIWrapper {
    
    inline static var BLANK_COLOR   = 0x808080;
    inline static var NORMAL_COLOR  = 0x000000;
    inline static var INVALID_COLOR = 0xEC5216;
    
    inline static public var COUNT   :String = "count";
    inline static public var DISTANCE:String = "distance";
    inline static public var TIME    :String = "time";
    
    public var defaultValue(default, set) = "";
    public var typedValue(get, never):String;
    public var value(get, set):String;
    public var float(get, never):Float;
    public var int(get, never):Int;
    public var name(get, never):String;
    public var backup(default, set):FieldWrapper;
    
    var _target:TextField;
    var _isDefaultValue = false;
    var _type = DISTANCE;
    var _hasFocus = false;
    
    public function new (target:TextField, startingValue:String, type:String) {
        super();
        
        _target = target;
        target.addEventListener(FocusEvent.FOCUS_IN , onFocusChange);
        target.addEventListener(FocusEvent.FOCUS_OUT, onFocusChange);
        _type = type;
        switch(_type) {
            case COUNT   :
                _target.restrict = "0123456789";
                defaultValue = "0";
            case DISTANCE:
                _target.restrict = "0123456789.bpBP";
                defaultValue = "0";
            case TIME    :
                _target.restrict = "0123456789.";
                defaultValue = "0.0";
        }
        
        _target.text = "10101";
        value = startingValue;
    }
    
    function onFocusChange(e:FocusEvent):Void {
        
        _hasFocus = e.type == FocusEvent.FOCUS_IN;
        
        if (!_hasFocus) {
            
            var tempValue = onValueChange(_isDefaultValue ? "" : _target.text);
            if (tempValue != _target.text)
                _target.text = tempValue;
            
        } else if (_isDefaultValue) {
            
            _target.text = "";
        }
    }
    
    public function addChangeListener(listener:Event->Void) {
        
        _target.addEventListener(Event.CHANGE, listener);
    }
    
    public function removeChangeListener(listener:Event->Void) {
        
        _target.removeEventListener(Event.CHANGE, listener);
    }
    
    inline function getDefaultText():String {
        
        if (backup != null)
            return backup.value;
        
        return defaultValue;
    }
    
    function get_value():String { return _target.text; }
    function set_value(v:String):String {
        
        removeChangeListener(onUserChange);
        _target.text = onValueChange(v);
        addChangeListener(onUserChange);
        return _target.text;
    }
    
    function get_float():Float {
        
        if (_type == DISTANCE)
            return Std.parseFloat(value) * 8;
        
        return Std.parseFloat(value);
    }
    
    function get_int():Int {
        
        return Std.parseInt(value);
    }
    
    function onUserChange(e:Event):Void {
        
        if (!Std.is(e, FakeChangeEvent))
            onValueChange(_target.text);
        // if (_hasFocus && _target.text != retVal)
        //     _target.text = retVal;
    }
    
    function onBackupChange(e:Event):Void {
        
        if (_isDefaultValue) {
            
            _target.text = onValueChange("");
            _target.dispatchEvent(new FakeChangeEvent());
        }
    }
    
    inline function onValueChange(v:String):String {
        
        // var oldV = v;
        
        if (v == "") {
            
            if (!_isDefaultValue) {
                
                _target.textColor = BLANK_COLOR;
                _isDefaultValue = true;
            }
            
            v = getDefaultText();
            
        } else {
            
            _target.textColor = NORMAL_COLOR;
            _isDefaultValue = false;
            
            // isValidEntry(v);
        }
        
        // trace('$name: ${_target.text} -> $oldV -> $v');
        return v;
    }
    
    function set_defaultValue(value:String):String {
        
        if (_isDefaultValue && backup != null)
            _target.text = defaultValue;
        
        return defaultValue = value;
    }
    
    function get_typedValue():String {
        
        return _isDefaultValue ? "" : _target.text;
    }
    
    function set_backup(v:FieldWrapper):FieldWrapper {
        
        if (backup != null)
            backup.removeChangeListener(onBackupChange);
        
        backup = v;
        backup.addChangeListener(onBackupChange);
        if (_isDefaultValue)
            _target.text = getDefaultText();
        
        return backup;
    }
    
    function get_name():String { return _target.name; }
}

class FakeChangeEvent extends Event {
    
    public function new () { super(Event.CHANGE); }
}