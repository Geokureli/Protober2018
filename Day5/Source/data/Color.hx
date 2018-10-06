package data;

import flixel.FlxG;
import flixel.util.FlxColor;

abstract Color(Int) from Int from UInt from FlxColor to Int to UInt to FlxColor {
    
    public static inline var RANDOM:FlxColor = 0;
    
    public static inline var ON:FlxColor = 0x00FF00;
    public static inline var OFF:FlxColor = 0xFF00FF;
    
    public static inline function getRandom():Color {
        return FlxG.random.getObject([ON, OFF]);
    }
}