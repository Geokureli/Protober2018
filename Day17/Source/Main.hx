package;

import art.Level;
import art.Hero;
import art.SplashState;

import ui.MenuWrapper;

import flixel.FlxG;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.util.FlxSignal;

import openfl.Assets;
import openfl.display.Sprite;

class Main extends Sprite {
    
    public function new() {
        super();
        
        if (stage == null)
            addEventListener(flash.events.Event.ADDED_TO_STAGE, onAddedToStage);
        else
            onAddedToStage();
    }
    
    function onAddedToStage(e = null) {
        
        art.SplashState.nextState = GameState;
        
        var zoom = 2;
        addChild
        ( new flixel.FlxGame
            ( Std.int(stage.stageWidth  / zoom)
            , Std.int(stage.stageHeight / zoom)
            // , art.SplashState
            , art.SplashState
                //.nextState
            , Std.int(stage.frameRate)
            , Std.int(stage.frameRate)
            )
        );
        
        GameState.onStart.add(
            () -> {
                
                var swf = Assets.getMovieClip("Layout:MainPage");
                var menu = new MenuWrapper(swf);
                addChild(swf);
                menu.show();
            }
        );
    }
}

class GameState extends flixel.FlxState {
    
    static public final onStart = new FlxSignal();
    
    var _level:Level;
    public var hero(default, null):Hero;
    
    override function create() {
        super.create();
        
        FlxG.cameras.bgColor = FlxG.stage.color;
        // FlxG.debugger.drawDebug = true;
        FlxG.mouse.useSystemCursor = true;
        
        add(_level = new Level());
        _level.initWorld();
        
        // Create _player
        add(hero = new Hero(12, 12));
        FlxG.camera.follow(hero, FlxCameraFollowStyle.PLATFORMER);
        
        onStart.dispatch();
    }
    
    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        
        FlxG.collide(_level, hero);
    }
}