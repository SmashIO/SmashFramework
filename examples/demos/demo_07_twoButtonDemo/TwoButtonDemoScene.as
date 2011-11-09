/**
 * Excruciatingly simple demo that shows how we can drive complex game 
 * state from a few inputs using a truth table. 
 */
package demos.demo_07_twoButtonDemo
{
    import com.pblabs.core.PBGroup;
    import com.pblabs.input.KeyboardKey;
    import com.pblabs.input.KeyboardManager;
    import com.pblabs.time.ITicked;
    import com.pblabs.time.TimeManager;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.display.Stage;

    // ## Implementation
    public class TwoButtonDemoScene extends PBGroup implements ITicked
    {
        [Inject]
        public var stage:Stage;
        
        [Inject]
        public var timeManager:TimeManager;
        
        [Inject]
        public var keyboardManager:KeyboardManager;
        
        /**
         * Array holding descriptions of output state based on input. The array
         * is indexed by adding 1 if the first input is true, and 2 if the second
         * (ie, converting input into a number starting with LSB). 
         */
        public var truthTable:Array = 
            [
                [ false, false, false, false, false  ],
                [ false, true, true, true, false ],
                [ true, false, false, false, true ],
                [ true, true, true, true, false]
            ];
        
        /**
         * Our current state. Copied out of truthTable based on current inputs.
         */
        public var state:Array = [ false, false, false, false, false ];
        
        /**
         * Sprite used to display current state. 
         */
        public var circleSprite:Sprite = new Sprite();
        
        // ## Initialize Demo
        public override function initialize():void
        {
            super.initialize();
            
            stage.addChild(circleSprite);
            
            redrawCircle();
            
            timeManager.addTickedObject(this);
        }
        
        /**
         * ## Tick Handler
         * Treating A and S as inputs, look up the right position in the truth
         * table and set our state. Then redraw our visuals.
         */
        public function onTick():void
        {
            var brake:Boolean = keyboardManager.isKeyDown(KeyboardKey.S.keyCode);
            var gas:Boolean = keyboardManager.isKeyDown(KeyboardKey.A.keyCode);
            var idx:int = (brake ? 1 : 0) + (gas ? 2 : 0);
            state = truthTable[idx];
            
            redrawCircle();
        }
        
        /**
         * ## Circle Drawer
         * Draw a circle for each state in the state vector. Green if true, red
         * if false.
         */
        public function redrawCircle():void
        {
            circleSprite.graphics.clear();
            
            for(var i:int=0; i<5; i++)
            {
                circleSprite.graphics.beginFill(state[i] ? 0x00FF00 : 0xFF0000);
                circleSprite.graphics.drawCircle(50 + 100 * i, 100, 50);                
            }
        }
        
        // ## Destroy Demo        
        public override function destroy():void
        {
            timeManager.removeTickedObject(this);
            
            stage.removeChild(circleSprite);
            
            super.destroy();
        }
    }
}

// @docco-chapter 2. Building Gameplay
// @docco-order 3