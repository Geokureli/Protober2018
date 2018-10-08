package art;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxTilemap.GraphicAuto;

class Level extends EditorLevel {
    
    public function new (editorEnabled:Bool, map:String = null) {
        super();
        
        if (map == null)
            map = "assets/level.csv";
        
        var graphics = FlxGraphic.fromClass(GraphicAuto);
        if (editorEnabled)
            bindCsvAssetSave("day3", map, graphics, 8, 8, AUTO);
        else
            loadMapFromCSV(map, graphics, 8, 8, AUTO);
    }
    
    public function initWorld():Void {
        
        FlxG.worldBounds.set(x, y, width, height);
        FlxG.camera.minScrollX = x;
        FlxG.camera.minScrollY = y;
        FlxG.camera.maxScrollX = x + width;
        FlxG.camera.maxScrollY = y + height;
    }
}