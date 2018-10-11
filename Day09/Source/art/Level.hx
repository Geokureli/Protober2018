package art;

import flixel.FlxG;
import flixel.FlxObject;

class Level extends EditorLevel {
    
    public function new (editorEnabled:Bool = true, forceLoadFile:Bool = false, resize:Bool = false) {
        super(editorEnabled || !forceLoadFile ? "day9" : null);
        
        _editingEnabled = editorEnabled;
        
        if (forceLoadFile)
            clearSave("assets/level.csv");
        
        loadMapFromCSV("assets/level.csv", "assets/tiles.png", 8, 8, null, 0, 1, 2);
        setTileProperties(2, FlxObject.UP);
        
        if (resize)
            resizeAndSave(Std.int(FlxG.width / _tileWidth), Std.int(FlxG.height/_tileHeight));
    }
    
    public function initWorld():Void {
        
        FlxG.worldBounds.set(x, y, width, height);
        FlxG.camera.minScrollX = x;
        FlxG.camera.minScrollY = y;
        FlxG.camera.maxScrollX = x + width;
        FlxG.camera.maxScrollY = y + height;
        trace('min:(${FlxG.camera.minScrollX}, ${FlxG.camera.minScrollY}) max:(${FlxG.camera.maxScrollX}, ${FlxG.camera.maxScrollY})');
    }
}