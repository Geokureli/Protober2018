package;


class Main extends openfl.display.Sprite {
    
    public function new () {
        super();
        
        addChild(new flixel.FlxGame(480, 320, GameState, 2));
    }
}

class GameState extends flixel.FlxState {
    
    public function new () { super(); }
    
    override public function create():Void {
        super.create();
        
        
    }
}