package;

import flixel.util.FlxTimer;
import art.Ball;
import art.Enemy;
import art.Hero;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class Main extends openfl.display.Sprite {
    
    static public var useMouse = true;
    
    public function new() {
        super();
        
        addChild(new flixel.FlxGame(160, 240, MenuState, 2));
    }
}

class MenuState extends flixel.FlxState {
    
    override public function create():Void {
        super.create();
        
        add(new Text
            ( 0
            // , "Click for mouse\nor\nPress any key\nfor keyboard"
            , "Click to change colors\n\nOK"
            , 16
            ).centerY()
        );
    }
    
    
    override function update(elapsed:Float) { 
        super.update(elapsed);
        
        if (FlxG.mouse.justPressed){
            
            Main.useMouse = true;
            FlxG.switchState(new GameState());
        }
        
        // if (FlxG.keys.justPressed.ANY){
            
        //     Main.useMouse = false;
        //     FlxG.switchState(new GameState());
        // }
    }
}

class GameState extends flixel.FlxState {
    
    inline public static var Y_ZONE = 100;
    
    var _hero:Hero;
    var _enemies:FlxTypedGroup<Enemy>;
    var _balls:BallGroup;
    var _gameOver:Text;
    var _instructions:Text;
    
    override public function create():Void {
        super.create();
        
        // Draw player bounds
        var line = new FlxSprite(0, FlxG.height - Y_ZONE);
        line.makeGraphic(1,1, 0xFFFFFFFF, false, "line");
        line.origin.x = 0;
        line.offset.x = 0;
        line.scale.x = FlxG.width;
        add(line);
        
        add(_hero = new Hero());
        _hero.setPosition((FlxG.width - _hero.width) / 2, (FlxG.height - Y_ZONE) / 2);
        _hero.onAction = onColorSwap;
        
        
        add(_enemies = Enemy.generate(8, 8));
        
        add(_balls = new BallGroup());
        var ball = _balls.add(new Ball());
        ball.color = _hero.color;
        _balls.kill();
        
        add(_gameOver = new Text(70, "Game Over")).visible = false;
        add(_instructions = new Text(100, "Click to Start"));
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (!_balls.alive) {
            
            if (!_gameOver.visible) {
                
                var ball = _balls.getFirstExisting();
                ball.x = _hero.x + _hero.width / 2;
                ball.y = _hero.y - _hero.height;
            }
        } else {
             
            var ball = _balls.getFirstDead();
            
            if (ball != null) {
                
                ball.color = 0xFF0000;
                _balls.kill();
                
                _gameOver.visible = true;
                new FlxTimer().start(.5)
                    .onComplete = (_) -> {
                        
                        _instructions.visible = true;
                    };
                
                return;
            }
            
            FlxG.overlap(_balls, _hero, overlapBallHero);
            FlxG.overlap(_balls, _enemies, overlapBallEnemy);
        }
    }
    
    function overlapBallHero(ball:Ball, hero:Hero):Void {
        
        if (ball.velocity.y < 0)
            return;
        
        if (hero.color == ball.color) {
            
            ball.onHit(hero, false);
            
            ball.velocity.set
                ( (ball.x - hero.x + (ball.width - hero.width) / 2) / hero.width * 2 * 100
                , -Math.abs(ball.velocity.y)
                );
            
        } else {
            
            ball.kill();
            ball.color = 0xFF0000;
        }
    }
    
    function overlapBallEnemy(ball:Ball, enemy:Enemy):Void {
        
        ball.onHit(enemy, true);
        if (enemy.dropsBall) {
            
            var newBall = _balls.recycle(Ball);
            newBall.setPosition
                ( enemy.x + (enemy.width  - newBall.width ) / 2
                , enemy.y + (enemy.height - newBall.height) / 2
                );
            newBall.velocity.set(0, 100);
            newBall.color = enemy.color;
        }
        enemy.kill();
    }
    
    function onColorSwap():Void {
        
        if (!_balls.alive && _instructions.visible)
            startGame();
    }
    
    function startGame():Void {
        
        _instructions.visible = false;
        _gameOver.visible = false;
        
        
        var ball = _balls.getFirstExisting();
        _balls.remove(ball);
        _balls.forEach (
            (ball) -> {
                _balls.remove(ball);
                ball.destroy();
            }
        );
        _balls.add(ball);
        
        if (ball.color == 0xFF0000) {
            
            _enemies.kill();
            _enemies.revive();
        }
        ball.setPosition(_hero.x + _hero.width / 2, _hero.y - _hero.height);
        ball.velocity.set(100, -100);
        ball.color = _hero.color;
        _balls.revive();
    }
}

class Text extends flixel.text.FlxText {
    
    public function new (y:Float, text:String, size:Int = 16) {
        super(0, y, FlxG.width, text, size);
        
        alignment = flixel.text.FlxText.FlxTextAlign.CENTER;
        color = 0xFFFFFF;
    }
    
    public function centerY():Text {
        
        y = (FlxG.height - height) / 2;
        return this;
    }
}