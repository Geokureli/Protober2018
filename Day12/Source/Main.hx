package;

import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.FlxSprite;

import art.Board;
import art.Piece;
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
    
    inline static public var FPS = 32;
    inline static public var STEP = 1 / FPS;
    
    var _lastStep = 0.0;
    var _piece:Piece;
    var _board:Board;
    var _pellets:FlxTypedGroup<Pellet>;
    var _stepNum = 0;
    
    
    override function create() {
        super.create();
        
        FlxG.cameras.bgColor = FlxG.stage.color;
        
        add(_board = new Board());
        var sprite = new FlxSprite(0, Piece.SIZE * 6);
        sprite.makeGraphic(FlxG.width, 2, 0xFF000000);
        add(sprite);
        
        add(_pellets = Pellet.create());
        
        startSnake();
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        _stepNum++;
        
        if (_piece == null)
            return;
        
        _piece.step(_stepNum);
        
        if (_piece.solid) {
            
            FlxG.drawFramerate = FlxG.updateFramerate = 16;
            _pellets.visible = false;
            
            if (_piece.y + _piece.bottom > FlxG.height || FlxG.overlap(_piece, _board)) {
                
                _piece.y = Std.int(_piece.y / Piece.SIZE) * Piece.SIZE;
                if (!checkMotion())
                    endTurn();
                
            } else
                checkMotion();
        } else {
            
            for (pellet in _pellets.members) {
                
                if(pellet.x == _piece.members[0].x && pellet.y == _piece.members[0].y) {
                    
                    if (pellet.good)
                        _piece.solidify();
                    else {
                        
                        _board.addGarbage();
                        remove(_piece);
                        _piece.destroy();
                        startSnake();
                    }
                }
            }
        }
    }
    
    function endTurn():Void{
        
        var piece = _piece;
        _piece = null;
        _board.addPiece(piece, startSnake);
    }
    
    function checkMotion():Bool {
        
        if (_piece.motion != 0) {
            
            _piece.x += Piece.SIZE * _piece.motion;
            
            var oddFrame = _stepNum % 2 == 1;
            if (FlxG.overlap(_piece, _board) || oddFrame) {
                
                _piece.x -= Piece.SIZE * _piece.motion;
                return oddFrame;
            }
            return true;
        }
        
        return false;
    }
    
    function startSnake():Void {
        
        add(_piece = new Piece());
        _piece.startIntro(() -> { FlxG.updateFramerate = FlxG.drawFramerate = 4; });
        
        _pellets.visible = true;
        Pellet.shuffle();
        for (pellet in _pellets.members)
            pellet.randomise();
    }
}

class Pellet extends flixel.FlxSprite {
    
    static var _randomPoints:Array<FlxPoint>;
    static var _count = 0;
    static var _group:FlxTypedGroup<Pellet>;
    
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
    
    static public function create():FlxTypedGroup<Pellet> {
        
        _randomPoints = [];
        for (i in 0 ... 11)
            for (j in 0 ... 6)
                if (Math.abs(5 - i) + Math.abs(1 - j) > 2)
                    _randomPoints.push(FlxPoint.get(i * Piece.SIZE, j * Piece.SIZE));
        
        _group = new FlxTypedGroup<Pellet>();
        for (i in 0 ... 30)
            _group.add(new Pellet());
            
        return _group;
    }
}