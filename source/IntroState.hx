package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class IntroState extends FlxState
{
	private var presentsText:FlxText;
	private var appearComplete:Bool = false;

	override public function create():Void
	{
		super.create();

		// Make mouse invisible
		FlxG.mouse.visible = false;

		// Set background to black
		FlxG.camera.bgColor = FlxColor.BLACK;

		// Create the presents text
		presentsText = new FlxText(0, 0, FlxG.width, "Bj83 presents...");
		presentsText.setFormat(null, 48, FlxColor.WHITE, "center");
		presentsText.screenCenter();
		presentsText.alpha = 0;
		add(presentsText);

		// Fade in the text
		FlxTween.tween(presentsText, {alpha: 1}, 2, {
			ease: FlxEase.quartOut,
			onComplete: function(tween:FlxTween)
			{
				// Wait a moment, then fade out
				FlxTween.tween(presentsText, {alpha: 0}, 1, {
					ease: FlxEase.quartIn,
					startDelay: 1,
					onComplete: function(tween:FlxTween)
					{
						// Transition to TitleState
						FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
						{
							FlxG.switchState(new TitleState());
						});
					}
				});
			}
		});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// Optional: Allow skipping the intro with ENTER or SPACE
		if (FlxG.keys.anyJustPressed([ENTER, SPACE]))
		{
			FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
			{
				FlxG.switchState(new TitleState());
			});
		}
	}
}