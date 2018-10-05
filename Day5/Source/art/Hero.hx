package art;

class Hero extends flixel.FlxSprite {
    
    public function new (x:Float = 0, y:Float = 0) {
        
        super(x, y);
        makeGraphic(32, 8, 0xFFFF0000, false, "hero");
    }
}