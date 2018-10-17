package;

import art.Enemy;
import art.Enemy.EnemyBullet;
import art.SplashState;
import art.Hero;

import flixel.FlxG;
import flixel.util.FlxTimer;

class Main extends openfl.display.Sprite {
    
    public function new() {
        super();
        
        SplashState.nextState = MenuState;
        
        var zoom = 1.5;
        addChild(
            new flixel.FlxGame
                ( Std.int(320 / zoom)
                , Std.int(480 / zoom)
                // , art.SplashState
                , GameState
                // , MenuState
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
    
    var _hero:Hero;
    var _enemy:Enemy;
    var isResetting:Bool = false;
    
    override function create() {
        super.create();
        
        FlxG.cameras.bgColor = FlxG.stage.color;
        // FlxG.debugger.drawDebug = true;
        
        _hero = new Hero();
        add(_hero.gun);
        
        add(_enemy = new Enemy());
        _enemy.x = (FlxG.width - _enemy.width) / 2;
        _enemy.y = 16;
        _enemy.hero = _hero;
        
        add(_hero.absorber);
        add(_hero);
        add(_enemy.gun);
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (_hero.alive) {
            
            FlxG.overlap(_hero, _enemy.gun, onHeroHit);
            _hero.checkBullets(_enemy.gun);
        }
        
        FlxG.overlap(_enemy, _hero.gun, onEnemyHit);
        
        if (!_hero.alive) {
            
            isResetting = true;
            new FlxTimer().start(1.0, (_) -> { _hero.revive(); });
        }
    }
    
    function onHeroHit(_, bullet:EnemyBullet):Void {
        
        _hero.kill();
        bullet.kill();
    }
    
    function onEnemyHit(_, bullet:HeroBullet):Void {
        
        _enemy.onHit();
        bullet.kill();
    }
}