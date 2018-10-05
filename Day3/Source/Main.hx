package;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;

import art.Hero;
import art.Level;
import art.Level.EditorLevel;

class Main extends openfl.display.Sprite {
    
    public function new() {
        super();
        
        addChild(new flixel.FlxGame(480, 320, GameState, 4));
        
        trace('width:${FlxG.camera.width} height:${FlxG.camera.height}');
    }
}

class GameState extends flixel.FlxState
{
    static var _justDied:Bool = false;
    
    var _level:Level;
    var _player:Hero;
    
    override public function create():Void 
    {
        FlxG.cameras.bgColor = 0xffaaaaaa;
        
        FlxG.debugger.drawDebug = true;
        FlxG.mouse.useSystemCursor = true;
        
        // add(_level = new EditorLevel("assets/level.csv", Math.ceil(FlxG.width / 8), Math.ceil(FlxG.height / 8)));
        add(_level = new EditorLevel("assets/level.csv"));
        // add(_level = new Level("assets/level.csv"));
        _level.initWorld();
        
        // Create _player
        add(_player = new Hero(40, 8));
        FlxG.camera.follow(_player, FlxCameraFollowStyle.PLATFORMER);
    }
    
    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        
        FlxG.collide(_level, _player);
        
        if (_player.y > _level.height)
            FlxG.resetState();
        
        if (FlxG.keys.justPressed.ONE) {
            
            // FlxG.camera.zoom -= .125;
            // trace(FlxG.camera.zoom);
            setZoom(FlxG.camera.zoom - 0.125);
            
        } else if (FlxG.keys.justPressed.TWO) {
            
            // FlxG.camera.zoom += .125;
            // trace(FlxG.camera.zoom);
            setZoom(FlxG.camera.zoom + 0.125);
        }
    }
    
    public function setZoom(zoom:Float):Void {
        
        // Resize the camera based on the original value
        var newWidth :Float = zoom / FlxG.camera.zoom * FlxG.camera.width;
        var newHeight:Float = zoom / FlxG.camera.zoom * FlxG.camera.height;
        var newX:Float = 0;
        var newY:Float = 0;
        
        // set new camera zoom
        FlxG.camera.zoom = zoom;
        trace(FlxG.camera.zoom);
        
        if (newWidth > _level.width)
        {
            newWidth = _level.width;
            newX = (FlxG.stage.stageWidth/2) - (newWidth*FlxG.camera.zoom/2);
        }
        if (newHeight > _level.height)
        {
            newHeight = _level.height;
            newY = (FlxG.stage.stageHeight/2) - (FlxG.camera.height*FlxG.camera.zoom/2);
        }
 
        // Set final size
        FlxG.camera.setSize(Std.int(newWidth), Std.int(newHeight));
        FlxG.camera.setPosition(Std.int(newX), Std.int(newY));
 
        // Update tilemap out-of-screen buffer
        // _level.updateBuffers();
 
        // Update player deadzones
        FlxG.camera.follow(_player, FlxCameraFollowStyle.PLATFORMER);
    }
}