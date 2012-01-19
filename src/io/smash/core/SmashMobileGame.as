package io.smash.core
{
    import flash.desktop.NativeApplication;
    import flash.desktop.SystemIdleMode;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.TimerEvent;
    import flash.ui.Keyboard;
    import flash.utils.Timer;

    import io.smash.Smash;
    import io.smash.debug.Console;
    import io.smash.debug.ConsoleCommandManager;
    import io.smash.debug.Logger;
    import io.smash.input.KeyboardManager;
    import io.smash.property.PropertyManager;
    import io.smash.smash_internal;
    import io.smash.time.TimeManager;
    import io.smash.util.TypeUtility;

    use namespace smash_internal;
    
    [SWF(frameRate="32")]
    public class SmashMobileGame extends Sprite
    {
        private static const DEACTIVATE_TIMEOUT:Number = 500;

        // Container for the active scene.
        public var rootGroup:SmashGroup = Smash._rootGroup;

        protected var _deactivateTimer:Timer;
        
        /**
         * Initialize the demo and show the first scene.
         */
        public function SmashMobileGame()
        {
            // Set it so that the stage resizes properly.
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;

            // Handle Deactivates
            _deactivateTimer = new Timer(DEACTIVATE_TIMEOUT, 1);
            _deactivateTimer.addEventListener(TimerEvent.TIMER, onDeactivateTick);
            NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactivate, false, 0, true);
            NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate, false, 0, true);

            NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            
            // Set up the root group for the demo and register a few useful
            // managers. Managers are available via dependency injection to the
            // demo scenes and objects.
            rootGroup.initialize();
            rootGroup.name = TypeUtility.getObjectClassName(this) + "_Group";
            rootGroup.registerManager(Stage, stage);
            rootGroup.registerManager(PropertyManager, new PropertyManager());
            //rootGroup.registerManager(ConsoleCommandManager, new ConsoleCommandManager());
            rootGroup.registerManager(TimeManager, new TimeManager());
            //rootGroup.registerManager(KeyboardManager, new KeyboardManager());
            //rootGroup.registerManager(Console, new Console());
        }
        
        protected function onKeyDown(event:KeyboardEvent):void
        {
            switch(event.keyCode)
            {
                case Keyboard.BACK:
                        onBackButton();
                    break;
                default:
                    Logger.debug(this, "onKeyDown", "Not handling: "+event.keyCode);
            }
        }
        
        protected function onBackButton():void
        {
            Logger.debug(this, "onBackButton", "Back button clicked");
        }

        protected function onActivate(event:Event):void
        {
            Logger.debug(this, "onActivate", "activated");
            NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
            _deactivateTimer.reset();
        }

        protected function onDeactivate(event:Event):void
        {
            Logger.debug(this, "onDeactivate", "Deactivated");
            _deactivateTimer.start();
        }

        protected function onDeactivateTick(event:TimerEvent):void
        {
            Logger.debug(this, "onDeactivateTick", "THIS WAS A REAL DEACTIVATE");

            NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
        }
    }
}