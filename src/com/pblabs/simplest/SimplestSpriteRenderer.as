/**
 * Many games have very complex rendering systems.
 *
 * But rendering in Flash can be really simple. All you need is a 
 * DisplayObject, like a Sprite. SimplestRendererScene puts a Sprite with a
 * circle in it on the stage, and makes it easy to control the position.
 *
 * You could think of SimplestSpriteRenderer as being a "view" in an MVC
 * context.
 *
 * This component demonstrates three important parts of PBE:
 * 
 *  1. **Component lifecycle.** Components have onAdd called when they 
 *  are added to a PBGameObject, and onRemove called when they are
 *  are removed. They are automatically removed when the PBGameObject
 *  is destroy()ed. So they are ideal for doing setup/teardown of
 *  your component. We use them here to add and remove the Sprite to
 *  the Stage.
 *  2. **Dependency injection.** Values registered with the owning
 *  PBGroup are available for injection. Injection is really simple,
 *  you just make a public var of the type you want and annotate it
 *  with [Inject]. When the component is added to a PBGameObject,
 *  the PBGameObject automatically does injection using its owning
 *  PBGroup. We use this to get at the Stage we should be using.
 *  3. **Data bindings.** Many application frameworks (like Flex/MXML)
 *  allow you to automatically pull data from one place in your app
 *  to another. In PBE, every component has a list of "bindings" -
 *  sources to pull data into the component. We'll discuss bindings
 *  in more detail elsewhere, but it's important to call
 *  applyBindings() to make sure they are applied before your
 *  component does per-tick or per-frame processing.
 */
package com.pblabs.simplest
{
    import com.pblabs.core.PBComponent;
    
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.geom.Point;

    /**
     * ## SimplestSpriteRenderer
     * Every component inherits from PBComponent. Beyond that, everything
     * a component can do is optional.
     */
    public class SimplestSpriteRenderer extends PBComponent
    {
        // The Sprite instance we'll manage.
        public var sprite:Sprite = new Sprite();
        
        // We also want to have our own storage for the position, so that we're
        // not constantly touching the Sprite.
        protected var _position:Point = new Point();
        
        // Any public variable with [Inject] before it will be injected. stage
        // requires an instance of Stage be available; if one is not 
        // registered on the PBGroup that this component's PBGameObject belongs
        // to, then you'll get an error when you try to initialize this 
        // component.
        [Inject]
        public var stage:Stage;
        
        // ## Position
        // The main property we track in this renderer is position. A more
        // complex renderer might also store rotation, scale, skew, and so on.
        public function set position(value:Point):void
        {
            // We copy the Point to avoid bugs; it's easy to say
            //    renderer.position = somePoint;
            //    somePoint.y = 10;
            // which would result in modifying the Point that renderer is
            // referencing.
            _position.x = value.x;
            _position.y = value.y;
            
            // Update the Sprite's position to match.
            sprite.x = position.x;
            sprite.y = position.y;            
        }
        
        public function get position():Point
        {
            return _position;
        }

        // ## Initialization and Destruction
        // onAdd and onRemove are called by PBE when a component is added or
        // removed from a PBGameObject. They are the best places to do startup
        // and shutdown logic. The constructor is not as good of a place,
        // because injection won't have happened and if the user is setting
        // any properties on the component, they can't be set till after the
        // constructor is called.
        protected override function onAdd():void
        {
            // Always call the super class' onAdd to make sure the component
            // is fully initialized.
            super.onAdd();
            
            // Prepare the graphics in the sprite - we'll draw a simple circle.
            sprite.graphics.lineStyle(2, 0);
            sprite.graphics.beginFill(0xFF00FF);
            sprite.graphics.drawCircle(0, 0, 20);
            
            // A more advanced component might use ProcessManager, but we'll
            // just subscribe to ENTER_FRAME.
            stage.addEventListener(Event.ENTER_FRAME, onFrame);
            
            // Add the sprite to the stage (which is provided by dependency
            // injection).
            stage.addChild(sprite);
        }
        
        // In onRemove, you want to undo the actions in onAdd - so we
        // remove the sprite from the stage and unsubscribe from our 
        // ENTER_FRAME listener.
        protected override function onRemove():void
        {
            stage.removeChild(sprite);
            stage.removeEventListener(Event.ENTER_FRAME, onFrame);
            
            super.onRemove();
        }
        
        // ## Frame Callback
        // The basis of animation is updating your visuals every frame. This
        // callback doesn't need to do anything, because the renderer isn't
        // intrinsically animated (generally another component will tell it
        // how to move). But we want to support data binding, so we make sure
        // to call applyBindings() every frame, in case we have a binding that
        // updates our position.
        //
        // applyBindings() is very cheap if no bindings are present, so while
        // you don't want to call it more than you have to, you only pay for 
        // what you use.
        public function onFrame(e:*):void
        {
            applyBindings();
        }
    }
}
// @docco-chapter 1. First Steps
// @docco-order 3