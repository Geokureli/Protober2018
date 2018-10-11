package;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;
import art.Bullet;
import art.Enemy;
import art.Enemy.EnemySpawner;
import art.Hero;
import art.WrapSprite;
import art.WrapSprite.Star;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.math.FlxPoint;

class Main extends openfl.display.Sprite {
    
    public function new () {
        super();
        
        addChild(new FlxGame(480, 320, GameState, 2));
    }
}

class GameState extends flixel.FlxState {
    
    var _hero:Hero;
    var _scoreText:FlxText;
    var _gameOverText:FlxText;
    var _fruits:FlxTypedGroup<Fruit>;
    var _stars:FlxTypedGroup<Star>;
    var _bullets:FlxTypedGroup<Bullet>;
    var _enemies:FlxTypedGroup<Enemy>;
    
    var _canReset = false;
    
    var _score(get, set):Int;
    function get__score():Int {return Std.parseInt(_scoreText.text); }
    function set__score(score:Int):Int {
        
        _scoreText.text = '$score';
        return score;
    }
    
    public function new () { super(); }
    
    override public function create():Void {
        super.create();
        
        add(_stars = new FlxTypedGroup<Star>());
        add(_fruits = new FlxTypedGroup<Fruit>());
        add(_enemies = new FlxTypedGroup<Enemy>());
        add(_bullets = new FlxTypedGroup<Bullet>());
        
        var health = new HealthBar();
        
        add(_hero = new Hero(FlxG.width * 0.5, FlxG.height * 0.5, health));
        _hero.onShoot = shootBullet;
        FlxG.camera.follow(_hero);
        
        add(_scoreText = new FlxText(16, 16, 50, "0", 16));
        _scoreText.alignment = FlxTextAlign.CENTER;
        _scoreText.x = (FlxG.width - _scoreText.width) / 2;
        _scoreText.scrollFactor.set(0, 0);
        _score = 0;
        
        add(_gameOverText = new FlxText(0, 0, 200, "Game Over\n Press Any Key", 16));
        _gameOverText.scrollFactor.set(0, 0);
        _gameOverText.alignment = FlxTextAlign.CENTER;
        _gameOverText.x = (FlxG.width  - _gameOverText.width ) / 2;
        _gameOverText.y = (FlxG.height - _gameOverText.height) / 2;
        _gameOverText.visible = false;
        
        add(health);
        
        for (i in 0 ... 100)
            _stars.add(new Star());
        
        for (i in 0 ... 10)
            _enemies.add(EnemySpawner.spawn(_hero));
    }
    
    function shootBullet(bullet:Bullet):Void {
        
        _bullets.add(bullet);
    }
    
    function removeBullet(bullet:Bullet):Void {
        
        _bullets.remove(bullet).put();
        
    }
    
    function removeEnemy(enemy:Enemy):Void {
        
        _enemies.remove(enemy);
    }
    
    override public function update(elapsed:Float) {
        super.update(elapsed);
        
        FlxG.worldBounds.setPosition(FlxG.camera.scroll.x, FlxG.camera.scroll.y);
        
        for (bullet in _bullets.members) {
            
            if (bullet != null && !bullet.isOnScreen())
                removeBullet(bullet);
        }
        
        if (!_hero.alive) {
            
            if (_canReset && FlxG.keys.justPressed.ANY)
                FlxG.switchState(new GameState());
            
            return;
        }
        
        FlxG.overlap(_bullets, _enemies, collideBulletEnemy);
        FlxG.overlap(_hero, _fruits, collideHeroFruit);
        
        for (fruit in _fruits)
            fruit.attract(_hero);
        
        if (!_hero.invincible && FlxG.overlap(_hero, _enemies)) {
            
            if (_hero.health == 1) {
                
                for (i in 0 ... _score)
                    _fruits.add(new Fruit(_hero.x, _hero.y)).velocity.scale(2);
                
                new FlxTimer().start(1.0, (_) -> { _gameOverText.visible = true; });
                new FlxTimer().start(2.0, (_) -> { _canReset = true; });
            }
            
            _hero.hitEnemy();
        }
    }
    
    function collideHeroFruit(hero:Hero, fruit:Fruit):Void {
        
        _fruits.remove(fruit);
        _score++;
    }
    
    function collideBulletEnemy(bullet:Bullet, enemy:Enemy):Void {
        
        removeBullet(bullet);
        if (enemy.health == 1) {
            
            for (i in 0 ... 10)
                _fruits.add(new Fruit(enemy.x, enemy.y));
        }
        enemy.onHit(bullet);
    }
}

class Fruit extends WrapSprite {
    
    inline static var DIS = 50;
    
    var _wasClose = false;
    
    public function new (x:Float, y:Float) {
        super(x, y);
        
        makeGraphic(4, 4, 0xFF00FF00, false, "fruit");
        
        drag.set(100, 100);
        velocity.set(Math.random() * 200 - 100, Math.random() * 200 - 100);
    }
    
    public function attract(target:FlxSprite):Void {
        
        var p = FlxPoint.get(target.x - x, target.y - y);
        var distance = p.distanceTo(FlxPoint.weak());
        
        if (_wasClose){
            
            velocity.copyFrom(p);
            velocity.scale(200 / distance);
            
        } else
            _wasClose = distance <= DIS;
        
        p.put();
    }
}

class HealthBar extends FlxSpriteGroup {
    
    public var value(default, set):Int;
    function set_value(v:Int):Int {
        
        this.value = v;
        _bar.scale.x = Std.int(44 / 3 * v);
        return v;
    }
    
    var _bar:FlxSprite;
    
    public function new () {
        super(8, 8);
        
        scrollFactor.set(0, 0);
        add(new FlxSprite(0, 0, "assets/Health.png"));
        
        add(_bar = new FlxSprite(2, 2));
        _bar.makeGraphic(1, 1, 0xFFFF0000, false, "bar");
        _bar.scale.y = 8;
        _bar.origin.set(0,0);
    }
}