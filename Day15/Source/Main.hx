package;

import art.SplashState;

import flixel.FlxG;

class Main extends openfl.display.Sprite {
    
    public function new() {
        super();
        
        SplashState.nextState = MenuState;
        
        var zoom = 4;
        addChild(
            new flixel.FlxGame
                ( Std.int(960 / zoom)
                , Std.int(640 / zoom)
                // , art.SplashState
                , GameState
                // , MenuState
                )
        );
    }
}

class MenuState extends flixel.FlxState {
    
    override function create() {
        super.create();
        
        FlxG.cameras.bgColor = FlxG.stage.color;
        
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
    }
}

class GameState extends flixel.FlxState {
    
    override function create() {
        super.create();
        
        FlxG.cameras.bgColor = FlxG.stage.color;
        
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        
    }
}