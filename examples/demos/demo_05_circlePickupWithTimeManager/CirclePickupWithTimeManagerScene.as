/**
 * This demo is identical to the CirclePickupScene, but shows how we can use
 * the TimeManager instead of directly listening for ENTER_FRAME events.
 * 
 * Why would we want to do this?
 * 
 * Because the TimeManager gives us a better model for building our game's
 * simulation, one that works more reliably even if the game is running slow
 * or fast. It gives us two kinds of callbacks, ticks and frames. Ticks are
 * guaranteed to be run at 32Hz, so they are a good basis for building game
 * logic. Frames are called every time Flash renders, so they let us do
 * visual rendering in a specific place.
 * 
 * Using the TimeManager, we can also pause, slow down, or speed up our game's
 * logic without having to worry about our rendering code getting in the way.
 * 
 * The TimeManager also lets us assign a priority to things that listen to
 * frames or ticks, so that we can e.g. make sure scene rendering code
 * is run after all the individual bits of logic that update the positions
 * of all the things in the scene.
 * 
 * To demonstrate how this is handy, we get rid of the GemManager, and fold
 * its code right into the scene by implementing the ITicked interface and
 * adding ourselves to the TimeManager.
 */
package demos.demo_05_circlePickupWithTimeManager
{
    import com.pblabs.core.PBGameObject;
    import com.pblabs.core.PBGroup;
    import com.pblabs.core.PBSet;
    import com.pblabs.simpler.MouseFollowComponent;
    import com.pblabs.simpler.SimpleSpriteRenderer;
    import com.pblabs.simplest.SimplestSpatialComponent;
    import com.pblabs.time.ITicked;
    import com.pblabs.time.TimeManager;
    
    import flash.display.Stage;
    import flash.events.Event;
    import flash.geom.Point;
    import demos.SimpleDemoGameObject;
    
    // ## Implementation
    // 
    // Notice we implement ITicked so that we can add ourselves to the 
    // TimeManager directly.
    public class CirclePickupWithTimeManagerScene extends PBGroup implements ITicked
    {
        // You will recognize this code from the GemManager in the previous
        // demo.
        public var gemSet:PBSet;
        public var pickerUpper:SimpleDemoGameObject;
        public const collisionRadius:Number = 35;
        
        // And this is the same as what's in the CiclePickupScene.
        [Inject]
        public var stage:Stage;
        
        // Get the root group's TimeManager (instantiated in PBEDemos.as). The
        // TimeManager provides callbacks as frames and ticks occur, lets you 
        // schedule callbacks, allows scaling/pausing time, and does all this 
        // much more cheaply than the usual event listener/setTimeout patterns
        // found in AS3 projects.
        [Inject]
        public var timeManager:TimeManager;
        
        // ## Initialize Demo
        public override function initialize():void
        {
            super.initialize();
            
            // Set up the PBSet for the gems.
            gemSet = new PBSet();
            gemSet.owningGroup = this;
            gemSet.initialize();
            
            // Make the guy that follows the mouse.
            pickerUpper = makeMouseFollower();
            
            // Make the gems.
            for(var i:int=0; i<20; i++)
                makeGem(new Point(stage.stageWidth * Math.random(), stage.stageHeight * Math.random()));
            
            // We add ourselves to the TimeManager, so that it will tick us.
            timeManager.addTickedObject(this);
        }
        
        // ## Tear Down Demo
        public override function destroy():void
        {
            timeManager.removeTickedObject(this);
            
            super.destroy();
        }
        
        /**
         * ## Tick Handler
         * Called by the TimeManager 32 times per second. Ideal place to run
         * our game logic.
         */
        public function onTick():void
        {
            // Find all circles within 20px of the pickerupper
            // and destroy() them.
            const pickerPos:Point = pickerUpper.spatial.position;
            
            for(var i:int=0; i<gemSet.length; i++)
            {
                // See if it's in range.
                const circle:SimpleDemoGameObject = gemSet.getPBObjectAt(i) as SimpleDemoGameObject;
                if(Point.distance(circle.spatial.position, pickerPos) > collisionRadius)
                    continue;
                
                // Nuke it! And decrement i so we don't skip any.
                circle.destroy();
                i--;
            }
        } 
        
        /**
         * ## Make Mouse Follower
         * Creates the mouse follower game object. Same as in previous demos.
         */
        public function makeMouseFollower():SimpleDemoGameObject
        {
            // Create the mouse follower.
            var go:SimpleDemoGameObject = new SimpleDemoGameObject();
            go.owningGroup = this;
            
            go.spatial = new SimplestSpatialComponent();
            
            go.render = new SimpleSpriteRenderer();
            go.render.addBinding("position", "@spatial.position");
            
            const mfc:MouseFollowComponent = new MouseFollowComponent();
            mfc.targetProperty = "@spatial.position";
            go.addComponent(mfc, "mouse");
            
            go.initialize();
            
            return go;
        }
        
        /**
        * ## Make Gem
         * Creates the gem game object. Same as in previous demos.
         */
        public function makeGem(pos:Point):SimpleDemoGameObject
        {
            var go:SimpleDemoGameObject = new SimpleDemoGameObject();
            go.owningGroup = this;
            
            go.spatial = new SimplestSpatialComponent();
            go.spatial.position = pos.clone();
            
            go.render = new SimpleSpriteRenderer();
            go.render.addBinding("position", "@spatial.position");
            
            go.initialize(); 
            
            // Don't forget to add it to the gem set!
            gemSet.add(go);
            
            return go;
        }
    }
}

// @docco-chapter 2. Building Gameplay
// @docco-order 1