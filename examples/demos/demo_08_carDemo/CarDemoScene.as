/**
 * Excruciating simple demo showing how we can implement a numerical 
 * simulation of a car.
 */
package demos.demo_08_carDemo
{
    import com.pblabs.core.PBGroup;
    import com.pblabs.input.KeyboardKey;
    import com.pblabs.input.KeyboardManager;
    import com.pblabs.time.ITicked;
    import com.pblabs.time.TimeManager;
    
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    // ## Implementation
    public class CarDemoScene extends PBGroup implements ITicked
    {
        [Inject]
        public var stage:Stage;
        
        [Inject]
        public var timeManager:TimeManager;
        
        [Inject]
        public var keyboardManager:KeyboardManager;
        
        /**
         * How much gas is left? 
         */
        public var gas:int = 1000;
        
        /**
         * How fast are we moving on the X axis? 
         */
        public var velocity:Number = 0;
        
        /**
         * Where are we on the X axis? 
         */
        public var position:Number = 0;
        
        /**
         * Sprite used to display the car state. 
         */
        public var circleSprite:Sprite = new Sprite();
        
        /**
         * Used to show how much gas is left. 
         */
        public var gasIndicator:TextField = new TextField();
        
        // ## Initialize Demo
        public override function initialize():void
        {
            super.initialize();
            
            stage.addChild(circleSprite);
            stage.addChild(gasIndicator);
            
            gasIndicator.y = stage.stageHeight - 64;
            gasIndicator.autoSize = TextFieldAutoSize.LEFT;
            gasIndicator.mouseEnabled = false;
            gasIndicator.textColor = 0x0;
            gasIndicator.defaultTextFormat = new TextFormat(null, 48, 0x0, true);
            
            redrawCircle();
            
            timeManager.addTickedObject(this);
        }
        
        /**
         * ## Tick Handler
         * Every tick, if the A key is down, consume gas and add velocity. In
         * addition, apply drag and update our position based on velocity. Then
         * redraw the visuals.
         */
        public function onTick():void
        {
            if(keyboardManager.isKeyDown(KeyboardKey.A.keyCode))
            {
                gas -= 1;
                velocity += 1 * (stage.stageWidth / 800);
            }
            
            velocity *= 0.9;
            position += velocity;
            
            redrawCircle();
            
            gasIndicator.text = "Gas: " + gas;
        }
        
        // ## Circle Drawer
        public function redrawCircle():void
        {
            circleSprite.graphics.clear();
            circleSprite.graphics.beginFill(keyboardManager.isKeyDown(KeyboardKey.A.keyCode) ? 0x00FF00 : 0xFF0000);
            circleSprite.graphics.drawCircle(100 + position / 10, stage.stageHeight / 2, stage.stageHeight / 4);            
        }
        
        // ## Destroy Demo
        public override function destroy():void
        {
            timeManager.removeTickedObject(this);
            
            stage.removeChild(gasIndicator);
            stage.removeChild(circleSprite);
            
            super.destroy();
        }
    }
}

// @docco-chapter 2. Building Gameplay
// @docco-order 4