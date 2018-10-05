package;

import art.Hero;

class Main extends openfl.display.Sprite {
    
    public function new() {
        super();
        
        addChild(new flixel.FlxGame(320, 240, GameState, 2));
    }
}

class GameState extends flixel.FlxState {
    
    override public function create():Void {
        super.create();
        
        
    }
}