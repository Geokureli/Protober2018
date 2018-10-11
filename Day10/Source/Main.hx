package;

import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxRect;
import flixel.text.FlxText;

import flixel.addons.display.FlxSliceSprite;

import art.Hero;
import art.Hero.Drill;
import art.Level;
import art.SplashState;

class Main extends openfl.display.Sprite {
    
    public function new() {
        super();
        
        SplashState.nextState = MenuState;
        
        var zoom = 4;
        addChild(
            new flixel.FlxGame
                ( Std.int(736 / zoom)
                , Std.int(704 / zoom)
                , art.SplashState
                // , GameState
                // , MenuState
                , 1
                )
        );
    }
}

class MenuState extends flixel.FlxState {
    
    var _uis:FlxTypedGroup<PlayerMenu>;
    var _users:Array<Int>;
    var _instructions:FlxGroup;
    
    public function new (users:Array<Int> = null) {
        super();
        
        _users = users;
        if (_users == null)
            _users = [0, 1, 1, 1];
    }
    
    override function create() {
        super.create();
        
        FlxG.cameras.bgColor = FlxG.stage.color;
        
        var text;
        add(text = new CenterText(2, 0, "Drillmania", 24));
        text.color = 0x222034;
        
        add(_uis = new FlxTypedGroup<PlayerMenu>());
        for (i in 0 ... 4)
            _uis.add(new PlayerMenu(i, _users[i]));
        
        add(text = new CenterText(FlxG.height - 44, 0, "Press ENTER to start\nHold SPACE for instructions", 8));
        text.color = 0x222034;
        add(text = new CenterText(FlxG.height - 16, 0, "A 1-day game by George", 8));
        text.color = 0x222034;
        
        add(_instructions = new FlxGroup());
        var bg = new FlxSprite();
        bg.makeGraphic(1,1, FlxG.camera.bgColor, false, "bg");
        bg.scale.set(FlxG.width * 2, FlxG.height * 2);
        _instructions.add(bg);
        _instructions.add(text = new CenterText(0, 0, "Instructions", 24));
        text.borderColor = 0xFF222034;
        text.borderStyle = FlxTextBorderStyle.OUTLINE;
        _instructions.add(text = new CenterText(36, 0, "Drill others.\nDon't get drilled.", 16));
        text.borderColor = 0xFF222034;
        text.borderStyle = FlxTextBorderStyle.OUTLINE;
        var msg = "hold the direction you want to turn before you reach a corner or else you get stuck for a bit.";
        _instructions.add(text = new CenterText(92, 0, msg, 8));
        text.borderColor = 0xFF222034;
        text.borderStyle = FlxTextBorderStyle.OUTLINE;
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        
        _instructions.visible = FlxG.keys.pressed.SPACE;
        
        if (FlxG.keys.justReleased.ENTER)
            FlxG.switchState(
                new GameState(
                    [ _uis.members[0].value
                    , _uis.members[1].value
                    , _uis.members[2].value
                    , _uis.members[3].value
                    ]
                )
            );
    }
}

class PlayerMenu extends flixel.group.FlxSpriteGroup {
    
    static var colors = [0xFFAC3232, 0xFF6ABE30, 0xFF639BFF, 0xFFFBF236];
    
    public var value(default, null) = -1;
    
    var _options:FlxTypedGroup<UIText>;
    var _keyUp:Array<FlxKey>;
    var _keyDown:Array<FlxKey>;
    
    public function new(playerNum:Int, startValue:Int) {
        super(1 + FlxG.width / 4 * playerNum, 40);
        
        var width = Std.int(FlxG.width / 4) - 2;
        
        add(new FlxSliceSprite("assets/ui.png", FlxRect.get(1, 1, 1, 1), width, 91));
        add(new UIText(-2, 'P$playerNum', 16));
        
        _options = new FlxTypedGroup<UIText>();
        add(_options.add(new UIText(20, "Human")));
        add(_options.add(new UIText(30, "Easy" )));
        add(_options.add(new UIText(40, "Hard" )));
        select(startValue);
        
        var keys = new FlxSprite(0, 54);
        keys.loadGraphic("assets/keys.png", true, 35);
        keys.animation.add("0", [0]);
        keys.animation.add("1", [1]);
        keys.animation.add("2", [2]);
        keys.animation.add("3", [3]);
        keys.animation.play('$playerNum');
        keys.x = (width - keys.width) / 2;
        add(keys);
        
        switch(playerNum) {
            case 0:
                _keyUp   = [FlxKey.W];
                _keyDown = [FlxKey.S];
            case 1:
                _keyUp   = [FlxKey.UP];
                _keyDown = [FlxKey.DOWN];
            case 2:
                _keyUp   = [FlxKey.I];
                _keyDown = [FlxKey.K];
            case 3:
                _keyUp   = [FlxKey.EIGHT];
                _keyDown = [FlxKey.TWO];
        }
        color = colors[playerNum];
    }
    
    function select(index:Int):Void {
        
        if (value != -1)
            _options.members[value].borderStyle = FlxTextBorderStyle.NONE;
        
        value = signedMod(index, _options.length);
        _options.members[value].borderStyle = FlxTextBorderStyle.OUTLINE;
    }
    
    inline function signedMod(x, y) { return (x + y) % y; }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (FlxG.keys.anyJustPressed(_keyUp))
            select(value - 1);
        if (FlxG.keys.anyJustPressed(_keyDown))
            select(value + 1);
    }
}

class UIText extends CenterText {
    
    public function new (y:Float, text:String, size:Int = 8, embed:Bool = true) {
        super(y, Std.int(FlxG.width / 4) - 2, text, size, embed);
        
        borderColor = 0xFF222034;
        borderSize = 1;
    }
}

class CenterText extends FlxText {
    
    public function new (y:Float, width:Float = 0, text:String, size:Int = 8, embed:Bool = true) {
        
        if (width == 0)
            width = FlxG.width;
        
        super(0, y, width, text, size, embed);
        
        alignment = FlxTextAlign.CENTER;
    }
}

class GameState extends flixel.FlxState {
    
    var _level:Level;
    var _heroes:FlxTypedGroup<Hero>;
    var _drills:FlxTypedGroup<Drill>;
    var _slowDownTime = 0.0;
    var _users:Array<Int>;
    
    public function new (users:Array<Int> = null) {
        super();
        
        _users = users;
        if (_users == null)
            _users = [0, 1, 1, 1];
    }
    
    override function create() {
        super.create();
        
        FlxG.cameras.bgColor = FlxG.stage.color;
        FlxG.camera.scroll.x += Level.SIZE;
        
        
        add(_level = new Level(false, true));
        add(_heroes = new FlxTypedGroup<Hero>());
        _drills = new FlxTypedGroup<Drill>();
        var hero;
        _heroes.add(hero = new Hero(_level, 1, _users[0])); _drills.add(hero.drill);
        _heroes.add(hero = new Hero(_level, 2, _users[1])); _drills.add(hero.drill);
        _heroes.add(hero = new Hero(_level, 3, _users[2])); _drills.add(hero.drill);
        _heroes.add(hero = new Hero(_level, 4, _users[3])); _drills.add(hero.drill);
        
        // FlxG.debugger.drawDebug = true;
        if (FlxG.debugger.drawDebug)
            add(_drills);
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (FlxG.keys.justReleased.ENTER || _heroes.countLiving() == 1) {
            
            FlxG.timeScale = 1.0;
            FlxG.switchState(new MenuState(_users));
            return;
        }
        
        if (_slowDownTime > 0) {
            
            _slowDownTime -= elapsed;
            if (_slowDownTime <= 0)
                FlxG.timeScale = 1.0;
        }
        
        FlxG.overlap(_drills, _drills, overlapDrills);
        FlxG.overlap(_drills, _heroes, overlapDrillHero);
    }
    
    function overlapDrillHero(drill:Drill, hero:Hero):Void {
        
        if (drill.hero != hero){
            
            FlxG.timeScale = 0.25;
            _slowDownTime = 0.5;
            FlxG.camera.shake(0.02, 0.125);
            hero.kill();
        }
    }
    
    function overlapDrills(drill1:Drill, drill2:Drill):Void {
        
        FlxG.camera.shake(0.01, 0.125);
        
        drill1.hero.turnAround();
        drill2.hero.turnAround();
    }
}