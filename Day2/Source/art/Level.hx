package art;

import flixel.math.FlxPoint;
import flixel.FlxG;

class Level extends flixel.tile.FlxTilemap {
    
    static inline var TILES_X = 15;
    static inline var TILES_Y = 15;
    
    public function new () {
        super();
        
        var row = "";
        for (i in 0 ... TILES_X)
            row += "0,";
        row = '1,${row}1';// left/right padding
        
        var csv = row.split("0").join("1") + "\n";//top padding
        for (i in 0 ... TILES_Y)
            csv += row + "\n";
        csv += row.split("0").join("1");//bottom padding
        
        loadMapFromCSV(csv, "assets/Tiles.png", 32, 32, null, 0, 0, 1);
        
        // FlxG.camera.setScrollBounds(x, y, width + x, height + y);
        FlxG.camera.minScrollX = x;
        FlxG.camera.minScrollY = y;
        FlxG.camera.maxScrollX = width  + x;
        FlxG.camera.maxScrollY = height + y;
        
        FlxG.worldBounds.set(x, y, width, height);
    }
    
    inline public function removeAtPoint(p:FlxPoint):Void { removeAt(p.x, p.y); }
    
    public function removeAt(x:Float, y:Float):Void {
        
        setTile
            ( Std.int((x - this.x) / _scaledTileWidth)
            , Std.int((y - this.y) / _scaledTileHeight)
            , 1
            );
    }
}