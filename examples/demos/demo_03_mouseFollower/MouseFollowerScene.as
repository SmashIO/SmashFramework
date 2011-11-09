/**
 * Static demos are boring! Let's add some interaction. This demo will make
 * our renderer follow the mouse.
 *
 * Notice how this demo builds very directly on the previous demo. We really 
 * only make one change - we add a third component that tracks the mouse.
 */
package demos.demo_03_mouseFollower
{
    import com.pblabs.core.PBGroup;
    import com.pblabs.simplest.SimplestMouseFollowComponent;
    import com.pblabs.simplest.SimplestSpatialComponent;
    import com.pblabs.simplest.SimplestSpriteRenderer;
    import demos.SimplestDemoGameObject;
    
    public class MouseFollowerScene extends PBGroup
    {
        // ## Implementation
        // Notice that for simplicy we make a helper function to set up our
        // "mouse follower" game object. This will help later on when we
        // want to make a single object more than once, or we have multiple
        // complex kinds of objects to create.
        public override function initialize():void
        {
            super.initialize();

            // Just create our object. We pull it into its own subroutine
            // for clarity.
            createPartyObject();
        }
        
        /**
         * ## Create A Mouse Follower Object
         * Helper function to create an object for our demo.
         */
        protected function createPartyObject():void
        {
            // Allocate our PBGameObject subclass.
            var go:SimplestDemoGameObject = new SimplestDemoGameObject();
            go.owningGroup = this;
            
            // Set up the spatial.
            go.spatial = new SimplestSpatialComponent();
            
            // Initialize the renderer - notice this is identical to the example
            // in BindingDemoScene.
            go.render = new SimplestSpriteRenderer();
            go.render.addBinding("position", "@spatial.position");
            
            // Now, let's add the new part - a component which is designed to set
            // a specified property every frame. The SimplestMouseFollowComponent
            // reads the mouse's position and sets the specified property on 
            // the spatial component.
            const mfc:SimplestMouseFollowComponent = new SimplestMouseFollowComponent();
            mfc.targetProperty = "@spatial.position";
            
            // Since we don't have a field on the SimplestPartyGameObject for
            // this component, we can add it in the generic way, ie, by using
            // addComponent and specifying a name.
            go.addComponent(mfc, "mouse");
            
            // Let the object live and be free!
            go.initialize();
        }
    }
}
// @docco-chapter 1. First Steps
// @docco-order 6