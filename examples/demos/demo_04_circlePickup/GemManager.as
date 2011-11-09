/**
 * The GemManager is a simple manager class to kill objects in a set when
 * another object moves close to them. We could have put all of this logic
 * in the CirclePickupScene, and for this example, it would probably have 
 * been just fine. However, PBE is meant to be industrial strength - and in
 * a large project with many game mechanics, you would have to have abstraction
 * like this to survive!
 *
 * In other words, consider this a building block that you can use or not as
 * it fits your project.
 */
package demos.demo_04_circlePickup
{
    import com.pblabs.core.PBSet;
    
    import flash.geom.Point;
    import demos.SimplestDemoGameObject;

    // ## Implementation
    public class GemManager
    {
        /**
         * Reference to the PBSet holding the gems - the game objects we want
         * to pick up. This is set by whoever creates us.
         */
        public var gemSet:PBSet;
        
        /**
         * Reference to the game object that is gonna do the picking up.
         */
        public var pickerUpper:SimplestDemoGameObject;
        
        /**
         * How close do we have to be to one of the gem game objects before we
         * pick it up?
         */
        public var collisionRadius:Number = 35;
        
        /**
         * Called every frame by the CirclePickupScene to check if we should
         * pick something up.
         */
        public function process():void
        {
            // Find all circles within radius px of the pickerupper
            // and destroy() them.
            const pickerPos:Point = pickerUpper.spatial.position;
            
            // We could accelerate this with a more advanced data structure 
            // (like a loose quadtree) but for small numbers of objects this
            // works just fine.
            //
            // Iterate over every gem.
            for(var i:int=0; i<gemSet.length; i++)
            {
                // See if the gem is in range...
                const circle:SimplestDemoGameObject = gemSet.getPBObjectAt(i) as SimplestDemoGameObject;
                if(Point.distance(circle.spatial.position, pickerPos) > collisionRadius)
                    continue;
                
                // It was, so nuke it! And decrement i so we don't skip 
                // anything.
                circle.destroy();
                i--;
            }
        }
    }
}
// @docco-chapter 1. First Steps
// @docco-order 9