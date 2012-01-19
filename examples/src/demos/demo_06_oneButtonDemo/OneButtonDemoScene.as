/**
 * Excruciating simple, self-contained demo showing how you can drive game
 * state off of a button. Does not use any components at all, demonstrating
 * a convenient way to build simple gameplay prototypes. 
 */
package demos.demo_06_oneButtonDemo
{
    import flash.display.Sprite;
    import flash.display.Stage;
    
    import io.smash.SmashUtil;
    import io.smash.core.SmashGroup;
    import io.smash.input.KeyboardKey;
    import io.smash.input.KeyboardManager;
    import io.smash.time.ITicked;
    import io.smash.time.TimeManager;
    
    // ## Implementation
    public class OneButtonDemoScene extends SmashGroup implements ITicked
    {
        [Inject]
        public var stage:Stage;
        
        [Inject]
        public var timeManager:TimeManager;
        
        [Inject]
        public var keyboardManager:KeyboardManager;
        
        /**
         * Variable that holds our current state. 
         */
        public var state:Boolean;
        
        /**
         * Sprite used to display that state. 
         */
        public var circleSprite:Sprite = new Sprite();
        
        /**
         * ## Initialize Demo
         */
        public override function initialize():void
        {
            super.initialize();
            
            stage.addChild(circleSprite);
            
            redrawCircle();
            
            timeManager.addTickedObject(this);
        }
        
        /**
         * ## Tick Handler
         * On every tick, we sample the state and update our visuals.
         */
        public function onTick():void
        {
            state = keyboardManager.isKeyDown(KeyboardKey.A.keyCode);
            
            redrawCircle();
        }
        
        /**
        * ## Circle Drawer
         * Simple method to display a circle in the center of the stage. 
         */
        public function redrawCircle():void
        {
            circleSprite.graphics.clear();
            circleSprite.graphics.beginFill(state ? 0x00FF00 : 0xFF0000);
            circleSprite.graphics.drawCircle(
                stage.stageWidth / 2, 
                stage.stageHeight / 2, 
                Math.min(stage.stageHeight, stage.stageWidth) / 3.5);
            circleSprite.graphics.endFill();
        }
        
        /**
        * ## Tear Down Demo
         * Clean everything up.
         */
        public override function destroy():void
        {
            timeManager.removeTickedObject(this);
            
            stage.removeChild(circleSprite);
            
            super.destroy();
        }
    }
}

// @docco-chapter 2. Building Gameplay
// @docco-order 2