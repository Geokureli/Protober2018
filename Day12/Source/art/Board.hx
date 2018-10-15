package art;

import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;

class Board extends FlxTypedGroup<Block> {
    
    inline static var ROWS = 19;
    inline static var COLUMNS = 11;
    
    var _rows:Array<Array<Block>> = [];
    
    public function new () { super(); }
    
    public function addPiece(piece:Piece, callback:Void->Void):Void {
        
        var block:Block;
        var clearedRows:Array<Int> = [];
        
        while(piece.members.length > 0){
            
            block = piece.members.pop();
            var row = Std.int(block.y / Piece.SIZE);
            block.y = row * Piece.SIZE;
            add(block);
            
            row = ROWS - row;
            var arr:Array<Block>;
            while (_rows.length <= row) {
                
                arr = [];
                for (i in 0 ... COLUMNS)
                    arr.push(null);
                
                _rows.push(arr);
            }
            
            _rows[row][Std.int(block.x / Piece.SIZE)] = block;
            if (checkRow(row))
                clearedRows.push(row);
        }
        
        if (clearedRows.length == 0)
            callback();
        else {
            
            for (row in clearedRows)
                for (block in _rows[row])
                    block.animation.play("3");
            
            new FlxTimer().start
                ( 0.5
                ,   (_) -> {
                        
                        while (clearedRows.length > 0)
                            clearRow(clearedRows.pop());
                        
                        callback();
                    }
                );
        }
    }
    
    public function checkRow(row:Int):Bool {
        
        for (block in _rows[row])
            if (block == null)
                return false;
        
        return true;
    }
    
    public function clearRow(row:Int):Void {
        
        while (_rows[row].length > 0)
            remove(_rows[row].pop());
        
        while (_rows.length > row){
            
            for (block in _rows[row]) {
                
                if (block != null)
                    block.y += Piece.SIZE;
            }
            row++;
        }
    }
    
    public function addGarbage():Void {
        
        forEach((block) -> { block.y -= Piece.SIZE; });
        var ran = FlxG.random.int(0, COLUMNS - 1);
        var arr:Array<Block> = [];
        var block;
        for(i in 0 ... COLUMNS) {
            
            block = null;
            
            if (i != ran) {
                block = new Block();
                add(block);
                block.setPosition(i * Piece.SIZE, ROWS * Piece.SIZE);
            }
            
            arr.push(block);
        }
        
        _rows.unshift(arr);
    }
}