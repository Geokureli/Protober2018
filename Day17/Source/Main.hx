package;

import art.Level;
import art.Hero;
import flixel.FlxCamera.FlxCameraFollowStyle;
import art.SplashState;

import flixel.FlxG;

class Main extends openfl.display.Sprite {
    
    public function new() {
        super();
        
        if (stage == null)
            addEventListener(flash.events.Event.ADDED_TO_STAGE, onAddedToStage);
        else
            onAddedToStage();
    }
    
    function onAddedToStage(e = null) {
        
        art.SplashState.nextState = MenuState;
        
        var zoom = 2;
        addChild
        ( new flixel.FlxGame
            ( Std.int(stage.stageWidth  / zoom)
            , Std.int(stage.stageHeight / zoom)
            // , art.SplashState
            , GameState
            // , MenuState
            , Std.int(stage.frameRate)
            , Std.int(stage.frameRate)
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
    
    var _level:Level;
    var _player:Hero;
    
    override function create() {
        super.create();
        
        FlxG.cameras.bgColor = FlxG.stage.color;
        // FlxG.debugger.drawDebug = true;
        FlxG.mouse.useSystemCursor = true;
        
        add(_level = new Level());
        _level.initWorld();
        
        // Create _player
        add(_player = new Hero(12, 12));
        FlxG.camera.follow(_player, FlxCameraFollowStyle.PLATFORMER);
    }
    
    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        
        FlxG.collide(_level, _player);
    }
}