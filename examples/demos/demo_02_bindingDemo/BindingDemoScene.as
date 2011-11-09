/**
 * Bulding off of SimplestRendererScene.as, this demo demonstrates the PBE
 * data binding system.
 *
 * It's often necessary to get data from one component to another in a dynamic
 * way. It's easy enough to hand-write code to copy values around, but it can
 * be error-prone and hard to maintain. It's also not data driven.
 *
 * This demo will show how to use the binding system built into PBComponent to
 * shuffle data around, specifically, to position the renderer based on a value
 * stored in a spatial component.
 *
 * This demo uses <a href="SimplestSpatialComponent.html">SimplestSpatialComponent</a> 
 * in addition to the classes used in the previous demo.
 */
package demos.demo_02_bindingDemo
{
    import com.pblabs.core.PBGroup;
    import com.pblabs.simplest.SimplestMouseFollowComponent;
    import com.pblabs.simplest.SimplestSpatialComponent;
    import com.pblabs.simplest.SimplestSpriteRenderer;
    import demos.SimplestDemoGameObject;
    
    public class BindingDemoScene extends PBGroup
    {
        // ## Demo Implementation
        public override function initialize():void
        {
            // Always let the superclass initialize! Otherwise you will have
            // a broken game.
            super.initialize();
            
            // Allocate the game object for this demo.
            var go:SimplestDemoGameObject = new SimplestDemoGameObject();
            go.owningGroup = this;
            
            // Set up the spatial component. See <a href="SimplestSpatialComponent.html">SimplestSpatialComponent</a> 
            // for more information; basically this exists just to store a
            // position value.
            go.spatial = new SimplestSpatialComponent();
            go.spatial.position.x = 100;
            go.spatial.position.y = 100;
            
            // Set up the renderer, and...
            go.render = new SimplestSpriteRenderer();
            
            // ...use component data binding to map the position field on the renderer
            // to the position field on the spatial component. Now, every time
            // applyBindings() is called, the value on the spatial will be copied
            // over. If you look in SimplestSpriteRenderer, you'll see this is
            // done every frame.
            //
            // The weird @ syntax is actually really simple. @ tells the 
            // binding system that you are going to reference a component on
            // the same PBGameObject as the PBComponent the binding is on. Then
            // you tell it the component to look up by name, and the field on
            // that component to look up. In other words, "find the spatial 
            // component, get the value of its position field, then assign that
            // value to my position field."
            go.render.addBinding("position", "@spatial.position");
            
            // And tell the SimplestDemoGameObject it's good to go!
            go.initialize();
            
            // Now you will see the renderer's circle appearing at the location
            // specified on the spatial.
            //
            // Let's go to MouseFollowerScene next to see this in action!
        }
    }
}
// @docco-chapter 1. First Steps
// @docco-order 4
