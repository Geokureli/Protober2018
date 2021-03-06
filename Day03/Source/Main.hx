package;

import flixel.FlxG;
import flixel.FlxCamera.FlxCameraFollowStyle;

import art.Hero;
import art.Level;
import art.EditorLevel;

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
        
        add(_level = new Level());
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
        var newWidth :Float = FlxG.camera.width  * zoom / FlxG.camera.zoom;
        var newHeight:Float = FlxG.camera.height * zoom / FlxG.camera.zoom;
        
        trace('$newWidth, $newHeight | ${FlxG.camera.width}, ${FlxG.camera.height}');
        
        // set new camera zoom
        FlxG.camera.zoom = zoom;
        trace(FlxG.camera.zoom);
        
        // Set final size
        FlxG.camera.setSize(Std.int(newWidth), Std.int(newHeight));
        //FlxG.camera.setPosition(Std.int(newX), Std.int(newY));
 
        // Update tilemap out-of-screen buffer
        // _level.updateBuffers();
 
        // Update player deadzones
        FlxG.camera.follow(_player, FlxCameraFollowStyle.PLATFORMER);
    }
}