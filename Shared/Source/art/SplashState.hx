package art;

import flixel.FlxG;
import flixel.FlxState;

class SplashState extends FlxState {
    
    static public var nextState:Class<FlxState>;
    
    override function create(){
        super.create();
        
        FlxG.cameras.bgColor = FlxG.stage.color;
        
        add(new Logo(FlxG.switchState.bind(Type.createInstance(nextState, []))));
    }
}