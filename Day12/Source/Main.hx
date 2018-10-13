package;

import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import art.Piece;
import flixel.FlxG;
import flixel.FlxSprite;

import art.SplashState;

class Main extends openfl.display.Sprite {
    
    public function new() {
        super();
        
        SplashState.nextState = MenuState;
        
        var zoom = 4;
        addChild(
            new flixel.FlxGame
                ( Std.int(360 / zoom)
                , Std.int(640 / zoom)
                // , art.SplashState
                , GameState
                // , MenuState
                , 1
                , 16
                , 16
                )
        );
    }
}

class MenuState extends flixel.FlxState {
    
    override function create() {
        super.create();
        
        FlxG.cameras.bgColor = FlxG.stage.color;
        
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
    }
}

class GameState extends flixel.FlxState {
    
    inline static public var FPS = 16;
    inline static public var STEP = 1 / FPS;
    
    var _lastStep = 0.0;
    var _piece:Piece;
    var _droppedBlocks:FlxGroup;
    var _things:FlxTypedGroup<Thing>;
    var _stepNum = 0;
    
    
    override function create() {
        super.create();
        
        FlxG.cameras.bgColor = FlxG.stage.color;
        
        add(_droppedBlocks = new FlxGroup());
        var sprite = new FlxSprite(0, Piece.SIZE * 6);
        sprite.makeGraphic(FlxG.width, 2, 0xFF000000);
        add(sprite);
        
        Thing.createRandom();
        add(_things = new FlxTypedGroup<Thing>());
        for (i in 0 ... 40)
            _things.add(new Thing());
        
        startSnake();
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        // _lastStep += elapsed;
        
        // while(_lastStep > STEP) {
            
            // _lastStep -= STEP;
            step();
            _stepNum++;
        // }
        
        if (!_piece.solid) {
            
            if (FlxG.keys.justPressed.SPACE)
                _piece.solidify();
            
        } else
            _things.visible = false;
    }
    
    function step():Void {
        
        _piece.step(_stepNum);
        
        if (_piece.solid) {
            
            if (_piece.y + _piece.bottom > FlxG.height || FlxG.overlap(_piece, _droppedBlocks)) {
                
                _piece.y = Std.int(_piece.y / Piece.SIZE) * Piece.SIZE;
                if (!checkMotion())
                    endTurn();
                
            } else
                checkMotion();
        } else {
            
            for (thing in _things.members) {
                
                if(thing.x == _piece.members[0].x && thing.y == _piece.members[0].y) {
                    
                    if (thing.good)
                        _piece.solidify();
                    else {
                        
                        remove(_piece);
                        _piece.destroy();
                        startSnake();
                    }
                }
            }
        }
    }
    
    function endTurn():Void{
        
        var block;
        while(_piece.members.length > 0){
            
            block = _piece.members.pop();
            block.y = Std.int(block.y / Piece.SIZE) * Piece.SIZE;
            _droppedBlocks.add(block);
        }
        
        startSnake();
    }
    
    function checkMotion():Bool {
        
        if (_piece.motion != 0) {
            
            _piece.x += Piece.SIZE * _piece.motion;
            
            var oddFrame = _stepNum % 2 == 1;
            if (FlxG.overlap(_piece, _droppedBlocks) || oddFrame) {
                
                _piece.x -= Piece.SIZE * _piece.motion;
                return oddFrame;
            }
            return true;
        }
        
        return false;
    }
    
    function startSnake():Void {
        
        add(_piece = new Piece(5, 0));
        
        _things.visible = true;
        Thing.shuffle();
        for (thing in _things.members)
            thing.randomise();
    }
}

class Thing extends flixel.FlxSprite {
    
    static var _randomPoints:Array<FlxPoint>;
    static var _count = 0;
    
    public var good:Bool;
    
    var _index = _count++;
    
    public function new () {
        super();
        
        loadGraphic("assets/tiles.png", true, Piece.SIZE, Piece.SIZE);
        animation.add("bad",  [14], 1, false);
        animation.add("good", [15], 1, false);
    }
    
    public function randomise():Void {
        
        x = _randomPoints[_index].x;
        y = _randomPoints[_index].y;
        good = FlxG.random.bool();
        animation.play(good ? "good" : "bad");
    }
    
    static public function shuffle():Void {
        
        FlxG.random.shuffle(_randomPoints);
    }
    
    static public function createRandom():Void {
        
        _randomPoints = [];
        for (i in 0 ... 11)
            for (j in 0 ... 6)
                if (Math.abs(5 - i) + j > 1)
                    _randomPoints.push(FlxPoint.get(i * Piece.SIZE, j * Piece.SIZE));
    }
}