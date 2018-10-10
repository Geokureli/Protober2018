package art;

import flixel.FlxG;
import flixel.text.FlxText.FlxTextAlign;

class CenterText extends flixel.text.FlxText {
    
    public function new (y:Float = 0, text:String = "", size:Int = 8, embeddedFont:Bool = true) {
        super(0, y, FlxG.width, text, size, embeddedFont);
        
        alignment = FlxTextAlign.CENTER;
    }
}