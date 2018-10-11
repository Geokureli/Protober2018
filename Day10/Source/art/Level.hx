package art;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxG;

class Level extends EditorLevel {
    
    inline static public var SIZE = 8;
    
    public function new (editingEnabled:Bool = true, forceLoadFile:Bool = false, resize:Bool = false) {
        super(editingEnabled || !forceLoadFile || resize ? "day10" : null);
        
        _editingEnabled = editingEnabled;
        
        if (forceLoadFile)
            clearSave("assets/level.csv");
        
        loadMapFromCSV("assets/level.csv", "assets/tiles.png", SIZE, SIZE, AUTO);
        
        if (resize)
            resizeAndSave(Std.int(FlxG.width / _tileWidth), Std.int(FlxG.height/_tileHeight));
    }
    
    public function initWorld():Void {
        
        FlxG.worldBounds.set(x, y, width, height);
        FlxG.camera.minScrollX = x;
        FlxG.camera.minScrollY = y;
        FlxG.camera.maxScrollX = x + width;
        FlxG.camera.maxScrollY = y + height;
    }
    
    public function getMoves(x:Float, y:Float):Int {
        
        var index = getTileIndexByCoords(FlxPoint.weak(x, y));
        
        return collidingTile(index, 1, 0) * FlxObject.RIGHT
            |  collidingTile(index,-1, 0) * FlxObject.LEFT
            |  collidingTile(index, 0,-1) * FlxObject.UP
            |  collidingTile(index, 0, 1) * FlxObject.DOWN;
    }
    
    inline function collidingTile(index, xD:Int, yD:Int):Int {
        
        return getTileByIndex(index + (yD * widthInTiles) + xD) > 0 ? 0 : 1;
    }
}