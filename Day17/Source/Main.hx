package;

import art.Level;
import art.Hero;
import art.SplashState;

import ui.UIWrapper;
import ui.FieldWrapper;
import ui.CheckBoxWrapper;
import ui.MenuWrapper;

import flixel.FlxG;
import flixel.FlxCamera.FlxCameraFollowStyle;

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
            , GameState
            , Std.int(stage.frameRate)
            , Std.int(stage.frameRate)
            )
        );
        
        // Assets.loadLibrary ("Layout").onComplete (function (_) {
            
        //     var clip = Assets.getMovieClip ("Layout:");
        //     addChild (clip);
        // });
        var swf = Assets.getMovieClip("Layout:");
        var menu = new MenuWrapper(swf);
        addChild(swf);
        menu.show();
    }
}

class GameState extends flixel.FlxState {
    
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
    }
    
    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        
        FlxG.collide(_level, hero);
    }
}