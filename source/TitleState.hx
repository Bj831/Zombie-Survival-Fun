package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.particles.FlxEmitter;
import flixel.system.FlxSound;

class TitleState extends FlxState
{
    private var titleText:FlxText;
    private var pressText:FlxText;
    private var zombieEmitter:FlxEmitter;
    private var elapsedTime:Float = 0;
	private var titleMusic:FlxSound;

    override public function create():Void
    {
        super.create();

		// Make mouse invisible
		FlxG.mouse.visible = false;

		// Initialize and play background music
		titleMusic = FlxG.sound.load("assets/music/titleTheme.wav", 0.3, true);
		titleMusic.play();

        // Dark atmospheric background
        FlxG.camera.bgColor = FlxColor.fromRGB(10, 10, 15);

        // Create zombie particle effect (green mist)
        zombieEmitter = new FlxEmitter(0, FlxG.height, 100);
        zombieEmitter.makeParticles(3, 3, FlxColor.GREEN, 100);
        zombieEmitter.setSize(FlxG.width, 1);
        add(zombieEmitter);
        zombieEmitter.start(false, 0.1);

        // Main title with shadow effect
        titleText = new FlxText(0, FlxG.height * 0.3, FlxG.width);
        titleText.text = "ZOMBIE\nSURVIVAL\nFUN";
        titleText.setFormat(null, 72, FlxColor.WHITE, "center");
        titleText.setBorderStyle(SHADOW, FlxColor.RED, 4);
        titleText.alpha = 0;
        add(titleText);

        // Press any key text with pulsing animation
        pressText = new FlxText(0, FlxG.height * 0.9, FlxG.width, "Press ENTER to Start");
        pressText.setFormat(null, 24, FlxColor.WHITE, "center");
        pressText.setBorderStyle(SHADOW, FlxColor.RED, 2);
        pressText.alpha = 0;
        add(pressText);

        // Animate elements in
        FlxTween.tween(titleText, {alpha: 1, y: titleText.y + 30}, 2, {ease: FlxEase.quartOut});
        FlxTween.tween(pressText, {alpha: 1}, 2, {ease: FlxEase.quartOut, startDelay: 1});
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        elapsedTime += elapsed;

        // Pulse effect for press text
        pressText.alpha = 0.5 + Math.sin(elapsedTime * 3) * 0.5;
        
        // Subtle movement for title
        titleText.y = (FlxG.height * 0.3) + Math.sin(elapsedTime) * 5;

        if (FlxG.keys.anyJustPressed([ENTER]))
        {
            FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
            {
                FlxG.switchState(new MenuState());
            });
        }
    }
}