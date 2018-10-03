package;

import art.Enemy;
import art.Hero;
import art.Hero.HammerStrike;
import art.Level;

import flixel.FlxG;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.group.FlxGroup.FlxTypedGroup;

import flixel.tile.FlxTilemap;

class Main extends openfl.display.Sprite {
    
    public function new () {
        super();
        
        FlxG.debugger.drawDebug = true;
        
        addChild(new flixel.FlxGame(480, 320, GameState, 2));
    }
}

class GameState extends flixel.FlxState {
    
    var _map:FlxTilemap;
    var _hero:Hero;
    var _enemies:FlxTypedGroup<Enemy>;
    
    public function new () { super(); }
    
    override public function create():Void {
        super.create();
        
        add(_map = new Level());
        add(_enemies = new FlxTypedGroup<Enemy>());
        
        add(_hero = new Hero());
        _hero.x = (_map.width  - _hero.width ) / 4 + _map.x;
        _hero.y = (_map.height - _hero.height) / 2 + _map.y;
        FlxG.camera.follow(_hero);
        FlxG.camera.updateFollow();
        FlxG.camera.follow(_hero, FlxCameraFollowStyle.TOPDOWN);
        _hero.onStrike = onHeroStrike;
        add(_hero._hammerStrike);
        
        _enemies.add(new Enemy(_hero.x + 128, _hero.y));
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        FlxG.collide(_hero, _map);
    }
    
    function onHeroStrike(hammer:HammerStrike):Void {
        
        FlxG.overlap(hammer, _enemies, overlapHammerEnemy);
        //add(hammer);
    }
    
    function overlapHammerEnemy(hammer:HammerStrike, enemy:Enemy):Void {
        
        enemy.onHit(hammer.force);
    }
}