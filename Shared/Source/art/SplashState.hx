package art;

import flixel.FlxG;
import flixel.FlxState;

class SplashState extends FlxState {
    
    static public var nextState:Class<FlxState>;
    
    override function create(){
        super.create();
        
        FlxG.cameras.bgColor = FlxG.stage.color;
        
        var logo = new Logo();
        add(logo);
        var callback:Void->Void = null;
        callback =
            FlxG.switchState.bind(Type.createInstance(nextState, []));
            // () -> { logo.start(callback); };// debug loop forever
        
        logo.start(callback);
    }
}