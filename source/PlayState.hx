package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.effects.particles.FlxEmitter;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;

class PlayState extends FlxState
{
    // Game objects
    public var player:FlxSprite;
    public var zombies:FlxTypedGroup<FlxSprite>;
    public var bullets:FlxTypedGroup<FlxSprite>;
    public var powerUps:FlxTypedGroup<FlxSprite>;
    public var bloodEmitter:FlxEmitter;
    public var muzzleFlash:FlxSprite;
    
    // Player properties
    public var playerHealth:Int = 100;
    public var playerWalkSpeed:Float = 120;
    public var playerRunSpeed:Float = 220;
    public var playerShieldActive:Bool = false;
    public var playerDamageMultiplier:Float = 1.0;

    // Add new properties for waves
    private var maxWaves:Int = 10; // Total number of waves to complete
    private var isVictorious:Bool = false;
    private var gameEnded:Bool = false;
            
    // Game properties
    private var shootTimer:Float = 0;
    private var shootCooldown:Float = 0.25;
    private var score:Int = 0;
    private var wave:Int = 1;
    private var zombiesPerWave:Int = 5;
    private var comboMultiplier:Int = 0;
    private var comboTimer:Float = 0;
    private var comboTimeout:Float = 3.0;
    private var zombiesKilled:Int = 0;
    private var killsNeededForNextWave:Int = 30;
	private var isComboTextHidden:Bool = false;
	private var comboHideTimer:Float = 0;
	private var comboHideDuration:Float = 5.0; // Duration in seconds to hide the combo text
	private var comboPopup:FlxText;
	private var comboScale:Float = 1.0;
	private var isComboAnimating:Bool = false;
	private var lastComboPosition:FlxPoint;   

    // UI elements
    private var scoreText:FlxText;
    private var healthText:FlxText;
    private var waveText:FlxText;
    private var comboText:FlxText;
    private var powerUpText:FlxText;
    
    // Zombie properties
    private var zombieSpeed:Float = 50;
    private var spawnTimer:Float = 0;
    private var spawnCooldown:Float = 2.0;
    private var zombieTypes:Array<ZombieType>;
    
    // Sound effects
    private var sfxShoot:FlxSound;
    private var sfxZombieDeath:FlxSound;
    private var sfxPlayerHurt:FlxSound;
    private var sfxPowerUp:FlxSound;
    
    // Power-up properties
    private var powerUpTimer:Float = 0;
    private var powerUpDuration:Float = 10.0;
    
    override public function create()
    {
        super.create();

		FlxG.mouse.visible = true;
        
        initializeGame();
        createGameObjects();
        createUI();
        loadSounds();
        setupZombieTypes();
    }
    
    private function initializeGame():Void
    {
        FlxG.camera.bgColor = FlxColor.fromRGB(20, 20, 20);
        
        bullets = new FlxTypedGroup<FlxSprite>();
        zombies = new FlxTypedGroup<FlxSprite>();
        powerUps = new FlxTypedGroup<FlxSprite>();
        
        add(bullets);
        add(zombies);
        add(powerUps);
        
        bloodEmitter = new FlxEmitter();
        bloodEmitter.makeParticles(2, 2, FlxColor.RED, 50);
        bloodEmitter.lifespan.set(0.5, 1.0);
        add(bloodEmitter);
    }
    
    private function createGameObjects():Void
    {
        // Create player with visual improvements
        player = new FlxSprite(FlxG.width / 2, FlxG.height - 64);
        player.makeGraphic(32, 32, FlxColor.BLUE);
        player.setSize(32, 32);
        player.drag.x = 1600;
        player.drag.y = 1600;
        add(player);
        
        // Create muzzle flash
        muzzleFlash = new FlxSprite();
        muzzleFlash.makeGraphic(16, 4, FlxColor.YELLOW);
        muzzleFlash.visible = false;
        add(muzzleFlash);
    }
    
    private function createUI():Void
    {
        scoreText = new FlxText(10, 10, 200, "Score: 0");
        scoreText.setFormat(null, 16, FlxColor.WHITE);
        add(scoreText);
        
        healthText = new FlxText(10, 30, 200, "Health: 100");
        healthText.setFormat(null, 16, FlxColor.GREEN);
        add(healthText);
        
        waveText = new FlxText(FlxG.width - 110, 10, 100, "Wave: 1");
        waveText.setFormat(null, 16, FlxColor.WHITE);
        add(waveText);
        
        powerUpText = new FlxText(10, 50, 200, "");
        powerUpText.setFormat(null, 14, FlxColor.CYAN);
        add(powerUpText);
    }
    
    private function loadSounds():Void
    {
        sfxShoot = FlxG.sound.load("assets/sounds/shoot.wav");
        sfxZombieDeath = FlxG.sound.load("assets/sounds/zombie_death.wav");
        sfxPlayerHurt = FlxG.sound.load("assets/sounds/player_hurt.wav");
        sfxPowerUp = FlxG.sound.load("assets/sounds/powerup.wav");
    }
    
    private function setupZombieTypes():Void
    {
        zombieTypes = [
            {
                color: FlxColor.GREEN,
                health: 1,
                speed: 50,
                points: 100
            },
            {
                color: FlxColor.YELLOW,
                health: 2,
                speed: 75,
                points: 200
            },
            {
                color: FlxColor.RED,
                health: 3,
                speed: 100,
                points: 300
            }
        ];
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        handlePlayerMovement();
        handleShooting(elapsed);
        handleZombieSpawning(elapsed);
        updateZombies();
        checkCollisions();
        updateCombo(elapsed);
        updatePowerUps(elapsed);
    }

    private function handlePlayerMovement():Void
    {
        // Reset velocity
        player.velocity.x = 0;
        player.velocity.y = 0;
        
        // Get current speed based on if shift is pressed for running
        var currentSpeed = FlxG.keys.pressed.SHIFT ? playerRunSpeed : playerWalkSpeed;
        
        // Handle WASD/Arrow key movement
        if (FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT)
            player.velocity.x = -currentSpeed;
        if (FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT)
            player.velocity.x = currentSpeed;
        if (FlxG.keys.pressed.W || FlxG.keys.pressed.UP)
            player.velocity.y = -currentSpeed;
        if (FlxG.keys.pressed.S || FlxG.keys.pressed.DOWN)
            player.velocity.y = currentSpeed;
            
        // Normalize diagonal movement
        if (player.velocity.x != 0 && player.velocity.y != 0)
        {
            player.velocity.x *= 0.707;
            player.velocity.y *= 0.707;
        }
        
        // Rotate player to face mouse cursor
        var angle = Math.atan2(FlxG.mouse.y - player.y, FlxG.mouse.x - player.x);
        player.angle = angle * 180 / Math.PI;
        
        // Keep player in bounds
        FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
        player.x = FlxMath.bound(player.x, 0, FlxG.width - player.width);
        player.y = FlxMath.bound(player.y, 0, FlxG.height - player.height);
    }

    private function handleZombieSpawning(elapsed:Float):Void
    {
        spawnTimer += elapsed;
        
        if (spawnTimer >= spawnCooldown && zombies.countLiving() < zombiesPerWave)
        {
            spawnTimer = 0;
            spawnZombie();
        }
    }

    private function spawnZombie():Void
    {
        var zombie = new FlxSprite();
        var zombieType = zombieTypes[FlxG.random.int(0, zombieTypes.length - 1)];
        
        // Set zombie properties
        zombie.makeGraphic(32, 32, zombieType.color);
        zombie.health = zombieType.health;
        zombie.ID = zombieTypes.indexOf(zombieType); // Store type index for reference
        
        // Spawn position logic
        var side = FlxG.random.int(0, 3); // 0: top, 1: right, 2: bottom, 3: left
        switch(side)
        {
            case 0: // Top
                zombie.x = FlxG.random.float(0, FlxG.width - zombie.width);
                zombie.y = -zombie.height;
            case 1: // Right
                zombie.x = FlxG.width;
                zombie.y = FlxG.random.float(0, FlxG.height - zombie.height);
            case 2: // Bottom
                zombie.x = FlxG.random.float(0, FlxG.width - zombie.width);
                zombie.y = FlxG.height;
            case 3: // Left
                zombie.x = -zombie.width;
                zombie.y = FlxG.random.float(0, FlxG.height - zombie.height);
        }
        
        zombies.add(zombie);
    }
    

    private function updateZombies():Void
    {
        for (zombie in zombies)
        {
            if (zombie.alive)
            {
                // Get zombie type properties
                var zombieType = zombieTypes[zombie.ID];
                
                // Calculate direction to player
                var angle = Math.atan2(player.y - zombie.y, player.x - zombie.x);
                
                // Update zombie velocity
                zombie.velocity.x = Math.cos(angle) * zombieType.speed;
                zombie.velocity.y = Math.sin(angle) * zombieType.speed;
                
                // Rotate zombie to face player
                zombie.angle = angle * 180 / Math.PI;
            }
        }
    }
    
    private function triggerVictory():Void
        {
            if (!gameEnded)
            {
                gameEnded = true;
                isVictorious = true;
                
                // Stop spawning zombies
                spawnTimer = 0;
                zombiesPerWave = 0;
                
                // Create victory text
                var victoryText = new FlxText(0, FlxG.height/2 - 100, FlxG.width, "VICTORY!");
                victoryText.setFormat(null, 64, FlxColor.YELLOW, "center");
                add(victoryText);
                
                var finalScoreText = new FlxText(0, FlxG.height/2, FlxG.width, 
                    "Final Score: " + score + "\nPress ENTER to restart");
                finalScoreText.setFormat(null, 32, FlxColor.WHITE, "center");
                add(finalScoreText);
                
                // Optional: Add victory sound
                // FlxG.sound.play("assets/sounds/victory.wav");
                
                // Make the victory text bounce
                FlxTween.tween(victoryText.scale, {x: 1.2, y: 1.2}, 1, {
                    type: PINGPONG,
                    ease: FlxEase.quadInOut
                });
            }
        }
    
    private function handleShooting(elapsed:Float):Void
    {
        shootTimer += elapsed;
        
        if (FlxG.mouse.pressed && shootTimer >= shootCooldown)
        {
            shootTimer = 0;
            var bullet = createBullet();
            sfxShoot.play();
            showMuzzleFlash();
        }
        
        cleanupBullets();
    }

    private function cleanupBullets():Void
    {
        for (bullet in bullets)
        {
            if (bullet.x < 0 || bullet.x > FlxG.width || bullet.y < 0 || bullet.y > FlxG.height)
            {
                bullet.kill();
            }
        }
    }
    
    private function createBullet():FlxSprite
    {
        var bullet = new FlxSprite(player.x + player.width/2, player.y + player.height/2);
        bullet.makeGraphic(4, 4, playerDamageMultiplier > 1 ? FlxColor.ORANGE : FlxColor.YELLOW);
        
        var angle = Math.atan2(FlxG.mouse.y - player.y, FlxG.mouse.x - player.x);
        var speed = 400;
        bullet.velocity.x = Math.cos(angle) * speed;
        bullet.velocity.y = Math.sin(angle) * speed;
        
        bullets.add(bullet);
        return bullet;
    }
    
    private function showMuzzleFlash():Void
    {
        muzzleFlash.visible = true;
        muzzleFlash.angle = player.angle;
        muzzleFlash.x = player.x + Math.cos(player.angle * Math.PI / 180) * player.width;
        muzzleFlash.y = player.y + Math.sin(player.angle * Math.PI / 180) * player.width;
        
        FlxTween.tween(muzzleFlash, {alpha: 0}, 0.1, {
            onComplete: function(_) {
                muzzleFlash.visible = false;
                muzzleFlash.alpha = 1;
            }
        });
    }
    
    private function spawnPowerUp(X:Float, Y:Float):Void
    {
        if (FlxG.random.float() < 0.1) // 10% chance
        {
            var powerUp = new FlxSprite(X, Y);
            var type = FlxG.random.int(0, 2);
            
            switch(type)
            {
                case 0: // Health
                    powerUp.makeGraphic(16, 16, FlxColor.GREEN);
                    powerUp.ID = 0;
                case 1: // Shield
                    powerUp.makeGraphic(16, 16, FlxColor.CYAN);
                    powerUp.ID = 1;
                case 2: // Damage boost
                    powerUp.makeGraphic(16, 16, FlxColor.ORANGE);
                    powerUp.ID = 2;
            }
            
            powerUps.add(powerUp);
            FlxTween.tween(powerUp, {y: powerUp.y - 10}, 1, {type: PINGPONG});
        }
    }
    
    private function updateCombo(elapsed:Float):Void
    {
		// Handle combo timer
		if (comboTimer > 0)
		{
			comboTimer -= elapsed;
			if (comboTimer <= 0)
			{
				loseCombo();
			}
		}

		// Handle combo text visibility
		if (isComboTextHidden)
		{
			comboHideTimer -= elapsed;
			if (comboHideTimer <= 0)
			{
				showComboText();
			}
		}
    }

	private function showComboText():Void
	{
		isComboTextHidden = false;
		comboText.visible = true;
		comboText.text = "Combo: x" + comboMultiplier;
	}

	private function hideComboText():Void
	{
		isComboTextHidden = true;
		comboHideTimer = comboHideDuration;
		comboText.visible = false;
	}

	private function loseCombo():Void
	{
		if (comboMultiplier > 0)
		{
			comboMultiplier = 0;
			if (comboPopup != null && comboPopup.alive)
			{
				FlxTween.tween(comboPopup, {alpha: 0}, 0.2, {
					onComplete: function(_)
					{
						comboPopup.kill();
					}
				});
			}
		}
	}
    
    private function updatePowerUps(elapsed:Float):Void
    {
        if (powerUpTimer > 0)
        {
            powerUpTimer -= elapsed;
            if (powerUpTimer <= 0)
            {
                playerDamageMultiplier = 1.0;
                playerShieldActive = false;
                powerUpText.text = "";
            }
        }
        
        FlxG.overlap(player, powerUps, collectPowerUp);
    }
    
    private function collectPowerUp(Player:FlxSprite, PowerUp:FlxSprite):Void
    {
        PowerUp.kill();
        powerUpTimer = powerUpDuration;
        sfxPowerUp.play();
        
        switch(PowerUp.ID)
        {
            case 0: // Health
                playerHealth = Std.int(Math.min(playerHealth + 50, 100));
                healthText.text = "Health: " + playerHealth;
                powerUpText.text = "Health Boost!";
            case 1: // Shield
                playerShieldActive = true;
                powerUpText.text = "Shield Active!";
            case 2: // Damage boost
                playerDamageMultiplier = 2.0;
                powerUpText.text = "Damage Boost!";
        }
    }
    
    private function checkCollisions():Void
    {
        FlxG.overlap(bullets, zombies, function(bullet:FlxSprite, zombie:FlxSprite) {
            bullet.kill();
            
            var zombieType = zombieTypes[zombie.ID];
            zombie.health--;
            
            if (zombie.health <= 0)
            {
                zombie.kill();
                createZombieDeathEffect(zombie);
                updateScore(zombieType.points);
                spawnPowerUp(zombie.x, zombie.y);

				// Increment zombie kill counter
				zombiesKilled++;

				// Check if enough zombies have been killed for next wave
				if (zombiesKilled >= killsNeededForNextWave)
				{
					zombiesKilled = 0; // Reset kill counter
					startNewWave();
				}
            }
        });
        
        if (!playerShieldActive)
        {
            FlxG.overlap(player, zombies, function(player:FlxSprite, zombie:FlxSprite) {
                playerHealth -= 1;
                healthText.text = "Health: " + playerHealth;
                healthText.color = playerHealth > 30 ? FlxColor.GREEN : FlxColor.RED;
                
                if (playerHealth <= 0)
                {
                    sfxPlayerHurt.play();
                    FlxG.camera.shake(0.05, 0.1);
                    FlxG.switchState(new GameOverState(score));
                }
            });
        }
    }
    
    private function createZombieDeathEffect(zombie:FlxSprite):Void
    {
        bloodEmitter.x = zombie.x + zombie.width/2;
        bloodEmitter.y = zombie.y + zombie.height/2;
        bloodEmitter.start(true, 0.5);
        
        FlxG.camera.shake(0.005, 0.1);
        sfxZombieDeath.play();
    }

	private function startNewWave():Void
	{
		wave++;

		// Check if player has completed all waves
		if (wave > maxWaves)
		{
			triggerVictory();
			return;
		}

		waveText.text = "Wave: " + wave + "/" + maxWaves;

		// Increase difficulty
		zombiesPerWave += 2;
		spawnTimer = 0;

		// Speed up zombies slightly each wave
		for (type in zombieTypes)
		{
			type.speed += 5;
		}

		// Visual feedback for new wave
		var waveAnnouncement = new FlxText(0, FlxG.height / 2 - 50, FlxG.width,
			"Wave " + wave + " of " + maxWaves + "\nKills needed: " + killsNeededForNextWave);
		waveAnnouncement.setFormat(null, 32, FlxColor.WHITE, "center");
		add(waveAnnouncement);

		FlxTween.tween(waveAnnouncement, {alpha: 0}, 2, {
			onComplete: function(_)
			{
				waveAnnouncement.destroy();
			}
		});

		// Make sure zombies keep spawning
		spawnTimer = spawnCooldown;
	}
    
	private function updateScore(points:Int):Void
	{
		var finalPoints = points * (comboMultiplier > 0 ? comboMultiplier : 1);
		score += finalPoints;
		scoreText.text = "Score: " + score;

		// Update combo
		comboMultiplier++;
		comboTimer = comboTimeout;

		// Store last zombie kill position if not set
		if (lastComboPosition == null)
		{
			lastComboPosition = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
		}
		else
		{
			lastComboPosition.set(FlxG.mouse.x, FlxG.mouse.y);
		}

		// Create or update combo popup
		if (comboPopup == null || !comboPopup.alive)
		{
			comboPopup = new FlxText(0, 0, 0, "");
			comboPopup.setFormat(null, 20, FlxColor.YELLOW, "center");
			add(comboPopup);
		}

		// Position and update combo text
		comboPopup.x = lastComboPosition.x - comboPopup.width / 2;
		comboPopup.y = lastComboPosition.y - 40;
		comboPopup.text = "COMBO x" + comboMultiplier;
		comboPopup.alpha = 1;
		comboPopup.scale.set(1.5, 1.5);

		// Animate combo popup
		if (!isComboAnimating)
		{
			animateComboPopup();
		}

		// Show points popup
		var pointsPopup = new FlxText(lastComboPosition.x, lastComboPosition.y, 0, "+" + finalPoints);
		pointsPopup.setFormat(null, 16, FlxColor.YELLOW);
		add(pointsPopup);

		FlxTween.tween(pointsPopup, {y: pointsPopup.y - 30, alpha: 0}, 0.5, {
			ease: FlxEase.circOut,
			onComplete: function(_)
			{
				pointsPopup.destroy();
			}
		});
    }

	private function animateComboPopup():Void
	{
		isComboAnimating = true;

		// Scale animation
		FlxTween.tween(comboPopup.scale, {x: 1.0, y: 1.0}, 0.2, {
			ease: FlxEase.backOut
		});

		// Position animation
		FlxTween.tween(comboPopup, {y: comboPopup.y - 10}, 0.5, {
			ease: FlxEase.quadOut
		});

		// Fade out animation
		FlxTween.tween(comboPopup, {alpha: 0}, 0.5, {
			startDelay: 0.5,
			onComplete: function(_)
			{
				isComboAnimating = false;
			}
		});
	}
}

typedef ZombieType = {
    var color:Int;
    var health:Int;
    var speed:Float;
    var points:Int;
}