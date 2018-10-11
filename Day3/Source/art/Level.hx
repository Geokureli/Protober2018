package art;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.tile.FlxTilemap.GraphicAuto;

class Level extends EditorLevel {
    
    public function new (editorEnabled:Bool = true, forceLoadFile:Bool = false, resize:Bool = false) {
        super(editorEnabled || !forceLoadFile || resize ? "day3" : null);
        
        _editingEnabled = editorEnabled;
        
        if (forceLoadFile)
            clearSave("assets/level.csv");
        
        loadMapFromCSV("assets/level.csv", FlxGraphic.fromClass(GraphicAuto), 8, 8, AUTO);
        
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
}