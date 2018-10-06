package art;

import openfl.Assets;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap.GraphicAuto;
import flixel.util.FlxSave;

class EditorLevel extends flixel.tile.FlxTilemap {
    
    var _editingEnabled = false;
    var _drawing = false;
    var _adding = false;
    var _save:FlxSave;
    
    public function new () {
        
        super();
    }
    
    public function bindCsvAssetSave
        ( csvName      :String
        , TileGraphic  :FlxTilemapGraphicAsset
        , TileWidth    :Int                    = 0
        , TileHeight   :Int                    = 0
        , ?AutoTile    :FlxTilemapAutoTiling
        , StartingIndex:Int                    = 0
        , DrawIndex    :Int                    = 1
        , CollideIndex :Int                    = 1
        ):Void {
        
        _editingEnabled = true;
        _save = new FlxSave();
        _save.bind(csvName);
        
        var map:String = cast _save.data.csv;
        if(map == null)
            map = Assets.getText(csvName);
        
        loadMapFromCSV
            ( map
            , FlxGraphic.fromClass(GraphicAuto)
            , 8
            , 8
            , AUTO
            );
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (!_editingEnabled)
            return;
        
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
    static public inline function stretchCsv(map:String, tilesX:Int, tilesY:Int, fillTile:Int = 0):String {
        
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