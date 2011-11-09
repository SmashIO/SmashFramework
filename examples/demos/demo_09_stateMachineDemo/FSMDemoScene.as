/**
 * Excruciating simple demo showing how we can implement complex movement of
 * an object using a simple finite state machine. Hold A or S to move the 
 * object.
 */
package demos.demo_09_stateMachineDemo
{
    
    import com.pblabs.core.PBGroup;
    import com.pblabs.input.KeyboardKey;
    import com.pblabs.input.KeyboardManager;
    import com.pblabs.time.ITicked;
    import com.pblabs.time.TimeManager;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.Dictionary;
    
    // ## Implementation
    public class FSMDemoScene extends PBGroup implements ITicked
    {
        [Inject]
        public var stage:Stage;
        
        [Inject]
        public var timeManager:TimeManager;
        
        [Inject]
        public var keyboardManager:KeyboardManager;
        
        /**
         * Variable to hold our current state. We use strings but a lot of times
         * you will want to hold a reference to the actual state description (if
         * your state machine is data driven) or to a numerical token. 
         */
        public var state:String = "Idle";
        
        /**
         * When did we enter the current state? Used for states that have a delay. 
         */
        public var stateEnterTime:int = 0;
        
        /**
         * Position on the X axis of our controlled object. 
         */
        public var position:int = 0;
        
        public var circleSprite:Sprite = new Sprite();
        public var stateIndicator:TextField = new TextField();
        
        // ## Initialize Demo
        public override function initialize():void
        {
            super.initialize();
            
            stage.addChild(circleSprite);
            stage.addChild(stateIndicator);
            
            // Set up a TextField to show our current state.
            stateIndicator.y = stage.stageHeight - 64;
            stateIndicator.autoSize = TextFieldAutoSize.LEFT;
            stateIndicator.mouseEnabled = false;
            stateIndicator.textColor = 0x0;
            stateIndicator.defaultTextFormat = new TextFormat(null, 48, 0x0, true);
            
            redrawCircle();
            
            timeManager.addTickedObject(this);
        }
        
        /**
         * ## Goto A State
         * Helper function to immediately change to a given state. 
         */
        public function gotoState(name:String):void 
        {
            state = name;
            stateEnterTime = timeManager.virtualTime;
        }
        
        /**
         * ## Advance FSM
         * This function advances the state machine. As you can see, every state
         * is represented in the switch() statement. Each state has a rule on how
         * to advance (for instance: wait a few ms, check for key down). If the
         * rule isn't met, the state does nothing and is called on the next tick.
         * If it is met, then gotoState() is called and the state is changed to
         * a new state.
         */
        public function advanceState():void
        {
            // Branch based on our current state. In a more powerful FSM system,
            // you might have a bunch of state descriptions and look them up
            // in a dictionary, and have a list of transition rules per state
            // kept in each state's description. But for simplicity we do this.
            switch(state)
            {
                case "Idle":
                    
                    // If we're idle, we can start going left or right based on
                    // user input. Else stay idle.
                    
                    if(keyboardManager.isKeyDown(KeyboardKey.A.keyCode))
                    {
                        gotoState("StartLeft");
                        return;
                    }
                    
                    if(keyboardManager.isKeyDown(KeyboardKey.S.keyCode))
                    {
                        gotoState("StartRight");
                        return;
                    }
                    break;
                
                case "StartLeft":
                    // Wait 100ms, then go to the Left state.
                    if(timeManager.virtualTime - stateEnterTime > 100)
                    {
                        gotoState("Left");
                        return;
                    }
                    break;
                
                case "StartRight":
                    // Wait 100ms, then go to the Right state.
                    if(timeManager.virtualTime - stateEnterTime > 100)
                    {
                        gotoState("Right");
                        return;
                    }
                    break;
                
                case "Left":
                    // Every tick we are in the left state, move -1 on the X
                    // axis. Additionally, if S is pressed, go to the StopLeft
                    // state.
                    position -= 1;
                    if(keyboardManager.isKeyDown(KeyboardKey.S.keyCode))
                    {
                        gotoState("StopLeft");
                        return;
                    }
                    break;
                
                case "Right":
                    // Every tick we are in the right state, move 1 on the X
                    // axis. Additionally, if A is pressed, go to the StopRight
                    // state.
                    position += 1;
                    if(keyboardManager.isKeyDown(KeyboardKey.A.keyCode))
                    {
                        gotoState("StopRight");
                        return;
                    }
                    break;
                
                case "StopLeft":
                    // Wait 250ms, then go back to Idle.
                    if(timeManager.virtualTime - stateEnterTime > 250)
                    {
                        gotoState("Idle");
                        return;
                    }
                    break;
                
                case "StopRight":
                    // Wait 250ms, then go back to Idle.
                    if(timeManager.virtualTime - stateEnterTime > 250)
                    {
                        gotoState("Idle");
                        return;
                    }
                    break;
            }    
        }
        
        /**
         * ## Tick Handler
         * Advance the state machine, then update the visuals. 
         */
        public function onTick():void
        {
            advanceState();
            
            redrawCircle();
            
            stateIndicator.text = state;
        }
        
        // ## Circle Drawer
        public function redrawCircle():void
        {
            circleSprite.graphics.clear();
            circleSprite.graphics.beginFill(state == "Idle" ? 0x00FF00 : 0xFF0000);
            circleSprite.graphics.drawCircle(100 + position * 4, 100, 50);            
        }
        
        // ## Destroy Demo
        public override function destroy():void
        {
            timeManager.removeTickedObject(this);
            
            stage.removeChild(stateIndicator);
            stage.removeChild(circleSprite);
            
            super.destroy();
        }
    }
}

// @docco-chapter 2. Building Gameplay
// @docco-order 5