package com.pblabs.core
{
    import com.pblabs.debug.Console;
    import com.pblabs.debug.ConsoleCommandManager;
    import com.pblabs.input.KeyboardManager;
    import com.pblabs.property.PropertyManager;
    import com.pblabs.time.TimeManager;
    import com.pblabs.util.TypeUtility;
    
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    
    [SWF(frameRate="32",wmode="direct")]
    public class PBGame extends Sprite
    {
        // Container for the active scene.
        public var rootGroup:PBGroup = new PBGroup();
        
        /**
         * Initialize the demo and show the first scene.
         */
        public function PBGame()
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