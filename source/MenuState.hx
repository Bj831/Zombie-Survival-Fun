package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.particles.FlxEmitter;

class MenuState extends FlxState
{
    private var menuItems:Array<FlxText>;
    private var selector:FlxSprite;
    private var currentSelection:Int = 0;
    private var zombieEmitter:FlxEmitter;

    override public function create():Void
    {
        super.create();

        // Make mouse invisible
        FlxG.mouse.visible = false;

        // Dark background
        FlxG.camera.bgColor = FlxColor.fromRGB(15, 15, 20);

        // Zombie particles
        zombieEmitter = new FlxEmitter(FlxG.width / 2, FlxG.height, 50);
        zombieEmitter.makeParticles(2, 2, FlxColor.GREEN, 50);
        add(zombieEmitter);
        zombieEmitter.start(false, 0.1);

        // Menu title
        var titleText = new FlxText(0, FlxG.height * 0.2, FlxG.width, "MAIN MENU");
        titleText.setFormat(null, 48, FlxColor.WHITE, "center");
        titleText.setBorderStyle(SHADOW, FlxColor.RED, 3);
        add(titleText);

        // Menu items
        menuItems = [];
        var menuOptions = ["Start Game", "How to Play", "Credits", "Back to Title", "Exit"];
        var startY = FlxG.height * 0.4;

        for (i in 0...menuOptions.length)
        {
            var menuItem = new FlxText(0, startY + (i * 60), FlxG.width, menuOptions[i]);
            menuItem.setFormat(null, 32, FlxColor.WHITE, "center");
            menuItem.setBorderStyle(SHADOW, FlxColor.GRAY, 2);
            menuItem.ID = i;
            menuItems.push(menuItem);
            add(menuItem);

            // Initial alpha and position for animation
            menuItem.alpha = 0;
            menuItem.x = -50;

            // Animate in
            FlxTween.tween(menuItem, {
                alpha: 1,
                x: 0
            }, 0.5, {
                ease: FlxEase.quartOut,
                startDelay: i * 0.2
            });
        }

        // Selector sprite
        selector = new FlxSprite();
        selector.makeGraphic(20, 20, FlxColor.RED);
        selector.alpha = 0.8;
        add(selector);

        updateSelector();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // Menu navigation
        if (FlxG.keys.justPressed.UP)
        {
            currentSelection--;
            if (currentSelection < 0) currentSelection = menuItems.length - 1;
            updateSelector();
        }
        else if (FlxG.keys.justPressed.DOWN)
        {
            currentSelection++;
            if (currentSelection >= menuItems.length) currentSelection = 0;
            updateSelector();
        }

        // Menu selection
        if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
        {
            switch (currentSelection)
            {
                case 0: // Start Game
                    FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
                    {
                        FlxG.switchState(new PlayState());
                    });
                case 1: // How to Play
                        FlxG.switchState(new HowToPlayState());
                case 2: // Credits
                        FlxG.switchState(new CreditsState());
                case 3: // Back to Title
                        FlxG.switchState(new TitleState());
				case 4: // Exit the game
					FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
					{
						#if sys
						Sys.exit(0);
						#end
					});
            }
        }

        // Animate selector
        selector.angle += elapsed * 90; // Rotate selector
    }

    private function updateSelector():Void
    {
        var selectedText = menuItems[currentSelection];
        selector.x = (FlxG.width / 2) - 100;
        selector.y = selectedText.y + selectedText.height/2;

        // Update menu items appearance
        for (i in 0...menuItems.length)
        {
            var item = menuItems[i];
            if (i == currentSelection)
            {
                item.color = FlxColor.YELLOW;
                FlxTween.tween(item.scale, {x: 1.2, y: 1.2}, 0.2, {ease: FlxEase.quartOut});
            }
            else
            {
                item.color = FlxColor.WHITE;
                FlxTween.tween(item.scale, {x: 1.0, y: 1.0}, 0.2, {ease: FlxEase.quartOut});
            }
        }
    }
}