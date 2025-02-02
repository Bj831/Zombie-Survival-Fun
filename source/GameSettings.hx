package;

class GameSettings
{
    // Static instance for singleton pattern
    public static var instance(get, null):GameSettings;

	public var playerHealthMultiplier:Float = 1.0;
	public var zombieSpeedMultiplier:Float = 1.0;
	public var scoreMultiplier:Float = 1.0;
    
    private static function get_instance():GameSettings
    {
        if (instance == null)
            instance = new GameSettings();
        return instance;
    }

    // Settings properties
    public var difficulty(default, set):String;
    public var gameMode(default, set):String;

    // Private constructor for singleton
    private function new()
    {
        // Default settings
        difficulty = "Normal";
        gameMode = "Classic";
    }

    // Setters with validation
    private function set_difficulty(value:String):String
    {
        if (["Easy", "Normal", "Hard"].indexOf(value) != -1)
            return difficulty = value;
        return difficulty;
    }

    private function set_gameMode(value:String):String
    {
        if (["Classic", "Time Attack", "Survival"].indexOf(value) != -1)
            return gameMode = value;
        return gameMode;
    }

    // Helper method to apply difficulty settings
    public function getDifficultyMultiplier():Float
    {
        return switch(difficulty) {
            case "Easy": 0.75;
            case "Normal": 1.0;
            case "Hard": 1.5;
            default: 1.0;
        }
    }

    // Helper method for game mode specific logic
    public function isTimeAttackMode():Bool
    {
        return gameMode == "Time Attack";
    }

    public function isSurvivalMode():Bool
    {
        return gameMode == "Survival";
    }
}