package art;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap.GraphicAuto;
import flixel.util.FlxSave;

import openfl.Assets;

class Level extends flixel.tile.FlxTilemap {
    
    public function new (map:String = null) {
        super();
        
        if (map == null)
            map = "assets/level.csv";
        
        loadMapFromCSV
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

class EditorLevel extends Level {
    
    var _drawing = false;
    var _adding = false;
    var _save:FlxSave;
    
    public function new (csvName:String, stretchX:Int = 0, stretchY:Int = 0) {
        
        _save = new FlxSave();
        _save.bind(csvName);
        
        var csv:String = cast _save.data.csv;
        if(csv == null)
            csv = Assets.getText(csvName);
        
        super(stretchCsv(csv, stretchX, stretchY));
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if ((!FlxG.mouse.justPressed && !FlxG.mouse.justReleased && !_drawing)
        || (_drawing && !FlxG.mouse.justMoved && !FlxG.mouse.justReleased))
            return;
        
        var tileIndex = getTileIndexByCoords(FlxPoint.weak(FlxG.mouse.x - x, FlxG.mouse.y - y));
        
        if (FlxG.mouse.justPressed) {
            
            _drawing = true;
            _adding = getTileByIndex(tileIndex) == 0;
            setTileByIndex(tileIndex, _adding ? 1 : 0);
            
        } else if (FlxG.mouse.justReleased) {
            
            _drawing = false;
            
            saveCsv();
            
        } else
            setTileByIndex(tileIndex, _adding ? 1 : 0);
    }
    
    function saveCsv():Bool {
        
        var csv = getCsv();
        openfl.system.System.setClipboard(csv);
        _save.data.csv = csv;
        return _save.flush();
    }
    
    function getCsv(simple:Bool = true):String {
        
        var data = getData(simple).copy();
        var map = new Array<String>();
        while (data.length > 0)
            map.push(data.splice(0, widthInTiles).join(","));
        
        return map.join("\n");
    }
    
    /**
     * stretches the map to fill the game, never shrinks
     * @param map 
     * @return String
     */
    function stretchCsv(map:String, tilesX:Int, tilesY:Int, fillTile:Int = 0):String {
        
        var rowData = map.split('\n');
        var rows = rowData.length;
        var cols = rowData[0].split(",").length;
        var add:String;
        if (tilesX > cols) {
            
            tilesX -= cols;
            cols += tilesX;
            add = "";
            while (tilesX-- > 0)
                add += ',$fillTile';
            
            map = rowData.join(add + "\n") + add;
        }
        
        if (tilesY > rows) {
            
            tilesY -= rows;
            add = "";
            while(cols-- > 0)
                add += '$fillTile,';
            
            add = add.substr(0, add.length - 1) + "\n";
            while(tilesY-- > 0)
                map += add;
        }
        
        return map;
    }
}