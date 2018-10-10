package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;
import flixel.system.FlxSplash;

import art.Hero;
import art.Level;
import art.CenterText;
import art.SplashState;

class Main extends openfl.display.Sprite {
    
    public function new() {
        super();
        
        var zoom = 4;
        
        SplashState.nextState = new MenuState();
        
        addChild(new flixel.FlxGame(Std.int(960 / zoom), Std.int(640 / zoom), SplashState, 1));
    }
}

class MenuState extends flixel.FlxState {
    
    var _options:Array<CenterText> = [];
    var _selected:Int = -1;
    
    override function create() {
        super.create();
        
        FlxG.cameras.bgColor = FlxG.stage.color;
        
        add(new CenterText(20, "Pong-Former", 24));
        
        var text;
        add(text = new CenterText(72, "Player Vs COM", 16));
        text.borderColor = 0xFFFFFFFF;
        text.borderSize = 2;
        text.color = 0x808080;
        _options.push(text);
        
        add(text = new CenterText(96, "2 Player", 16));
        text.borderColor = 0xFFFFFFFF;
        text.borderSize = 2;
        text.color = 0x808080;
        _options.push(text);
        
        selectText(0);
        
        add(new CenterText(FlxG.height - 32, "Intructions: WASD and Arrow keys", 8));
        add(new CenterText(FlxG.height - 16, "A game by George", 8));
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (FlxG.keys.anyJustPressed([FlxKey.S, FlxKey.DOWN, FlxKey.W, FlxKey.UP]))
            selectText(_selected + 1);
        
        if (FlxG.keys.anyJustReleased([FlxKey.Z, FlxKey.X, FlxKey.SPACE, FlxKey.ENTER]))
            FlxG.switchState(new GameState(_selected == 1));
    }
    
    function selectText(i:Int):Void {
        
        if (_selected != -1)
            _options[_selected].borderStyle = FlxTextBorderStyle.NONE;
        
        _selected = i % 2;
        
        _options[_selected].borderStyle = FlxTextBorderStyle.OUTLINE;
    }
}

class GameState extends flixel.FlxState {
    
    static inline var DEATH_Y = 1000;
    static inline var END_POINTS = 10;
    
    var _isPvp:Bool;
    var _level:Level;
    var _player1:Hero;
    var _player2:Hero;
    var _ball:Ball;
    var _pointsText1:FlxText;
    var _pointsText2:FlxText;
    
    public function new (isPvp:Bool = false) {
        
        _isPvp = isPvp;
        
        super();
    }
    
    override public function create():Void {
        
        FlxG.cameras.bgColor = 0xff76428a;
        
        // FlxG.debugger.drawDebug = true;
        FlxG.mouse.useSystemCursor = true;
        
        // add(_level = new Level(true, false, true));
        add(_level = new Level(false, true));
        _level.initWorld();
        
        // Create _player
        add(_ball = new Ball());
        add(_player1 = new Hero(true, _isPvp));
        if (_isPvp)
            add(_player2 = new Hero(false));
        else
            add(_player2 = new Enemy(_ball));//, cast add(new FlxSprite())));
        
        add(_pointsText1 = new FlxText(16, 16, 100, "0", 16));
        add(_pointsText2 = new FlxText(FlxG.width - 16, 16, 100, "0", 16));
        _pointsText2.x -= _pointsText2.width;
        _pointsText2.alignment = flixel.text.FlxText.FlxTextAlign.RIGHT;
    }
    
    override public function update(elapsed:Float):Void {
        
        if (_ball.moves){
            
            if (_ball.velocity.x < 0) {
                
                if (_ball.x < Ball.EDGE){
                    
                    var points = Std.parseInt(_pointsText2.text) + 1;
                    _pointsText2.text = '$points';
                    FlxFlicker.flicker(_pointsText2, 1.0, 0.125);
                    
                    if (points == END_POINTS) {
                        
                        _pointsText2.text = 'Winner!';
                        onVictory();
                        
                    } else
                        _ball.respawn(false, true);
                    
                } else if (FlxG.overlap(_ball, _player1))
                    _ball.onHit(_player1);
                
            } else {
                
                if (_ball.x + _ball.width > FlxG.width - Ball.EDGE) {
                    
                    var points = Std.parseInt(_pointsText1.text) + 1;
                    _pointsText1.text = '$points';
                    FlxFlicker.flicker(_pointsText1, 1.0, 0.125);
                    
                    if (points == END_POINTS) {
                        
                        _pointsText1.text = 'Winner!';
                        onVictory();
                        
                    } else
                        _ball.respawn(false, false);
                    
                } else if (FlxG.overlap(_ball, _player2))
                    _ball.onHit(_player2);
            }
        }
        
        FlxG.collide(_level, _player1);
        FlxG.collide(_level, _player2);
        
        super.update(elapsed);
    }
    
    function onVictory():Void {
        
        _ball.moves = false;
        alive = false;
        new FlxTimer().start(2, (_)->{ FlxG.switchState(new MenuState()); });
    }
}

class Ball extends FlxSprite {
    
    static inline public var EDGE = 8;
    static inline var START_SPEED = 50;
    static inline var SPEED_SCALE = 1.05;
    
    public function new() {
        super(0, 0, "assets/ball.png");
        
        setPosition((FlxG.width - width) / 2, (FlxG.height - height) / 2);
        moves = false;
        new FlxTimer().start(1.0, 
                (_) -> {
                    
                    moves = true;
                    respawn(true, FlxG.random.bool(50));
                }
            );
    }
    
    public function respawn(now:Bool, moveRight:Bool):Void {
        
        if (now){
            
            setPosition((FlxG.width - width) / 2, (FlxG.height - height) / 2);
            velocity.x = START_SPEED;
            velocity.y = FlxG.random.float(-START_SPEED, START_SPEED);
            if (!moveRight)
                velocity.x *= -1;
            
        } else {
            
            moves = false;
            
            FlxFlicker.flicker
                ( this
                , 1
                , 0.04
                , true
                , true
                , (_) -> {
                        respawn(true, moveRight);
                        new FlxTimer().start(1.0, (_) -> { moves = true; });
                    }
                );
        }
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (y < EDGE) {
            
            velocity.y *= -1;
            y = EDGE;
            shakeY();
            
        } else if (y + height > FlxG.height - EDGE) {
            
            velocity.y *= -1;
            y = FlxG.height - EDGE - height;
            shakeY();
        }
    }
    
    public function onHit(hero:FlxSprite):Void {
        
        velocity.y = (y - hero.y + (height - hero.height) / 2) / hero.height * 2 * Math.abs(velocity.x);
        velocity.x *= -1;
        velocity.scale(SPEED_SCALE);
        
        shake();
    }
    
    function shake(intesnity:Float = 0.01, duration:Float = 0.125, ?axes:FlxAxes):Void {
        
        FlxG.camera.shake(intesnity, duration, null, true, axes);
    }
    
    function shakeX(intesnity:Float = 0.01, duration:Float = 0.125):Void {
        
        shake(intesnity, duration, FlxAxes.X);
    }
    
    function shakeY(intesnity:Float = 0.01, duration:Float = 0.125):Void {
        
        shake(intesnity, duration, FlxAxes.Y);
    }
}

class Splash extends FlxSplash {
    
    override public function create():Void {
        
        FlxG.cameras.bgColor = FlxG.stage.color;
        
        super.create();
        
        FlxG.cameras.bgColor = FlxG.stage.color;
    }
}