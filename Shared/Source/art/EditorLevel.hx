package art;

import flixel.tile.FlxTile;
import flixel.tile.FlxBaseTilemap;
import openfl.Assets;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap.GraphicAuto;
import flixel.util.FlxSave;

class EditorLevel extends flixel.tile.FlxTilemap {
    
    var _editingEnabled = true;
    var _drawing = false;
    var _adding = false;
    var _save:FlxSave;
    var _mapName:String;
    
    public function new (saveName:String) {
        super();
        
        if(saveName != null)
            initSave(saveName);
    }
    
    function initSave(key:String):Void {
        
        _save = new FlxSave();
        _save.bind(key);
    }
    
    function loadCsvSave(mapName:String):String {
        
        if (_save == null)
            return null;
        
        return Reflect.field(_save.data, mapName);
    }
    
    public function clearSave(mapName:String):Bool {
        
        if (_save == null)
            return false;
        
        Reflect.setField(_save.data, mapName, null);
        return _save.flush();
    }
    
    function saveCsv(mapName:String, data:String):Bool {
        
        if (_save == null)
            return false;
        
        Reflect.setField(_save.data, mapName, data);
        return _save.flush();
    }
    
    function saveCurrentCsv():Bool {
        
        if (_save == null)
            return false;
        
        var csv = getCsv();
        openfl.system.System.setClipboard(csv);
        
        if (_mapName != null)
            return saveCsv(_mapName, csv);
        
        return false;
    }
    
    function getCsv():String {
        
        var simple = auto != FlxTilemapAutoTiling.OFF;
        var data = getData(simple);
        if (!simple)
            data = data.copy();
        
        var map = new Array<String>();
        while (data.length > 0)
            map.push(data.splice(0, widthInTiles).join(","));
        
        return map.join("\n");
    }
    
    override function loadMapFromCSV
    ( mapName      :String
    , tileGraphic  :FlxTilemapGraphicAsset
    , tileWidth    :Int = 0
    , tileHeight   :Int = 0
    , ?autoTile    :FlxTilemapAutoTiling
    , startingIndex:Int = 0
    , drawIndex    :Int = 1
    , collideIndex :Int = 1
    ):FlxBaseTilemap<FlxTile> {
        
        var map:String = loadCsvSave(mapName);
            
        if (map == null)
            map = Assets.getText(mapName);
        
        if (map == null){
            
            map = mapName;
            mapName = null;
        }
        _mapName = mapName;
        
        super.loadMapFromCSV
            ( map
            , tileGraphic
            , tileWidth
            , tileHeight
            , autoTile
            , startingIndex
            , drawIndex
            , collideIndex
            );
        
        saveCurrentCsv();
        
        return this;
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
            
            saveCurrentCsv();
            
        } else
            setTileByIndex(tileIndex, _adding ? 1 : 0);
    }
    
    public function resizeAndSave(width:Int, height:Int, fillTile:Int = 0):Bool {
        
        resize(width, height, fillTile);
        
        return saveCurrentCsv();
    }
    
    inline function resize(tilesX:Int, tilesY:Int, fillTile:Int = 0):Void {
        
        var updated = false;
        
        if (tilesX > widthInTiles) {
            
            updated = true;
            var i = heightInTiles;
            while (i-- > 0) {
                var j = tilesX - widthInTiles;
                while (j-- > 0)
                    _data.insert((i + 1) * widthInTiles, fillTile);
            }
            
            widthInTiles = tilesX;
        }
        
        if (tilesY > heightInTiles) {
            
            updated = true;
            heightInTiles = tilesY;
            totalTiles = widthInTiles * heightInTiles;
            
            var oldLen = _data.length;
            while(oldLen++ < totalTiles)
                _data.push(fillTile);
        }
        
        if (updated){
            
            applyAutoTile();
            computeDimensions();
            updateMap();
        }
    }
}