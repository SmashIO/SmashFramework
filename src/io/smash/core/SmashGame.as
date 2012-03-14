package io.smash.core
{
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    
    import io.smash.debug.Console;
    import io.smash.debug.ConsoleCommandManager;
    import io.smash.input.KeyboardManager;
    import io.smash.property.PropertyManager;
    import io.smash.time.TimeManager;
    import io.smash.util.TypeUtility;

    [SWF(frameRate="32",wmode="direct")]
    public class SmashGame extends Sprite
    {
        // Container for the active scene.
        public var rootGroup:SmashGroup = new SmashGroup();
        
        /**
         * Initialize the demo and show the first scene.
         */
        public function SmashGame()
        {
            // Set it so that the stage resizes properly.
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            // Set up the root group for the demo and register a few useful
            // managers. Managers are available via dependency injection to the
            // demo scenes and objects.
            rootGroup.initialize();
            rootGroup.name = TypeUtility.getObjectClassName(this) + "_Group";
            rootGroup.registerManager(Stage, stage);
            rootGroup.registerManager(PropertyManager, new PropertyManager());
            rootGroup.registerManager(ConsoleCommandManager, new ConsoleCommandManager());
            rootGroup.registerManager(TimeManager, new TimeManager());
            rootGroup.registerManager(KeyboardManager, new KeyboardManager());
            rootGroup.registerManager(Console, new Console());
        }
    }
}