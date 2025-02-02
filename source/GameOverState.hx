package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.particles.FlxEmitter;

class GameOverState extends FlxState
{
    private var gameOverText:FlxText;
    private var scoreText:FlxText;
    private var restartText:FlxText;
    private var menuText:FlxText;
    private var finalScore:Int;
    private var bloodEmitter:FlxEmitter;

    public function new(score:Int)
    {
        super();
        finalScore = score;
    }

    override public function create():Void
    {
        super.create();
        
        // Dark background with blood particles
        FlxG.camera.bgColor = FlxColor.fromRGB(20, 0, 0);
        
        // Create blood particle effect
        bloodEmitter = new FlxEmitter(0, 0, 200);
        bloodEmitter.makeParticles(2, 2, FlxColor.RED, 200);
        bloodEmitter.setSize(FlxG.width, FlxG.height);
        add(bloodEmitter);
        bloodEmitter.start(false, 0.05);

        // Game Over text with animation
        gameOverText = new FlxText(0, FlxG.height * 0.2, FlxG.width, "GAME OVER");
        gameOverText.setFormat(null, 64, FlxColor.RED, "center");
        gameOverText.setBorderStyle(SHADOW, FlxColor.GRAY, 4);
        gameOverText.alpha = 0;
        add(gameOverText);

        // Score text
        scoreText = new FlxText(0, FlxG.height * 0.4, FlxG.width, 'Final Score: $finalScore');
        scoreText.setFormat(null, 32, FlxColor.WHITE, "center");
        scoreText.setBorderStyle(SHADOW, FlxColor.GRAY, 2);
        scoreText.alpha = 0;
        add(scoreText);

        // Restart prompt
        restartText = new FlxText(0, FlxG.height * 0.6, FlxG.width, "Press R to Restart");
        restartText.setFormat(null, 24, FlxColor.WHITE, "center");
        restartText.setBorderStyle(SHADOW, FlxColor.GRAY, 2);
        restartText.alpha = 0;
        add(restartText);

        // Menu prompt
        menuText = new FlxText(0, FlxG.height * 0.7, FlxG.width, "Press M for Menu");
        menuText.setFormat(null, 24, FlxColor.WHITE, "center");
        menuText.setBorderStyle(SHADOW, FlxColor.GRAY, 2);
        menuText.alpha = 0;
        add(menuText);

        // Animate elements in
        FlxTween.tween(gameOverText, {alpha: 1, y: gameOverText.y + 20}, 1, {ease: FlxEase.quartOut});
        FlxTween.tween(scoreText, {alpha: 1, y: scoreText.y + 20}, 1, {ease: FlxEase.quartOut, startDelay: 0.5});
        FlxTween.tween(restartText, {alpha: 1, y: restartText.y + 20}, 1, {ease: FlxEase.quartOut, startDelay: 1});
        FlxTween.tween(menuText, {alpha: 1, y: menuText.y + 20}, 1, {ease: FlxEase.quartOut, startDelay: 1.2});
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.R)
        {
            FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
            {
                FlxG.switchState(new PlayState());
            });
        }
        else if (FlxG.keys.justPressed.M)
        {
            FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
            {
                FlxG.switchState(new MenuState());
            });
        }
    }
}