package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class HowToPlayState extends FlxState
{
    private var titleText:FlxText;
    private var instructionsText:FlxText;
    private var backText:FlxText;

    override public function create():Void
    {
        super.create();

        // Add title
        titleText = new FlxText(0, 50, FlxG.width, "How To Play");
        titleText.setFormat(null, 32, FlxColor.WHITE, CENTER);
        add(titleText);

        // Add instructions
        instructionsText = new FlxText(50, 150, FlxG.width - 100,
            "- Use ARROW KEYS or WASD to move\n\n" +
            "- Left click to shoot\n\n" +
            "- Survive as long as you can!"
        );
        instructionsText.setFormat(null, 16, FlxColor.WHITE, LEFT);
        add(instructionsText);

        // Add back button text
        backText = new FlxText(0, FlxG.height - 100, FlxG.width, "Press ESCAPE to return to menu");
        backText.setFormat(null, 16, FlxColor.YELLOW, CENTER);
        add(backText);

        // Add fade-in effect
        for (text in [titleText, instructionsText, backText]) {
            text.alpha = 0;
            FlxTween.tween(text, {alpha: 1}, 0.5, {ease: FlxEase.quartOut});
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.switchState(new MenuState());
        }
    }
}