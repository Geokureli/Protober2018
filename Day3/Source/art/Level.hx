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
        
        (editorEnabled ? bindCsvAssetSave : loadMapFromCSV)
            ( map
            , FlxGraphic.fromClass(GraphicAuto)
            , 8
            , 8
            , AUTO
            );
    }
    
    public function initWorld():Void {
        
        FlxG.worldBounds.set(x, y, width, height);
        FlxG.camera.minScrollX = x;
        FlxG.camera.minScrollY = y;
        FlxG.camera.maxScrollX = x + width;
        FlxG.camera.maxScrollY = y + height;
    }
}