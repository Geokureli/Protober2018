package ui;

class UIWrapper {
    
    public var enabled(default, set):Bool;
    function set_enabled(value:Bool):Bool { return enabled = value; }
    
    public function new () {}
    
    @:generic
    inline function get<T>(object:Dynamic, path:String, defaultValue:T = null):T {
        
        return aGet(object, path.split("."), defaultValue);
    }
    
    @:generic
    inline function aGet<T>(object:Dynamic, path:Array<String>, defaultValue:T = null):T {
        
        while (path.length > 0 && Reflect.hasField(object, path[0]))
            object = Reflect.field(object, path.shift());
        
        if (path.length == 0)
            return object;
        
        return defaultValue;
    }
}
