package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class CreditsState extends FlxState
{
    private var titleText:FlxText;
    private var creditsText:FlxText;
    private var backText:FlxText;

    override public function create():Void
    {
        super.create();

		// Make mouse invisible
		FlxG.mouse.visible = false;

        // Add title
        titleText = new FlxText(0, 50, FlxG.width, "Credits");
        titleText.setFormat(null, 32, FlxColor.WHITE, CENTER);
        add(titleText);

        // Add credits content
        creditsText = new FlxText(50, 150, FlxG.width - 100,
            "Programming: Bj83\n" +
            "Music: Noah Simcox\n" +
            "Special Thanks:\n" +
            "HaxeFlixel Community"
        );
        creditsText.setFormat(null, 16, FlxColor.WHITE, CENTER);
        add(creditsText);

        // Add back button text
        backText = new FlxText(0, FlxG.height - 100, FlxG.width, "Press ESCAPE to return to menu");
        backText.setFormat(null, 16, FlxColor.YELLOW, CENTER);
        add(backText);

        // Add fade-in effect
        for (text in [titleText, creditsText, backText]) {
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