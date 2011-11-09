/**
 * SimplestMouseFollowComponent shows off slightly more complex behavior. It
 * checks the position of the mouse every frame, then stores it into a property
 * of the user's choice.
 *
 * Notice how this is a light weight, reusable, data driven building block. 
 * You could use it almost unmodified in any number of different games.
 */
package com.pblabs.simplest
{
    import com.pblabs.core.PBComponent;
    
    import flash.display.Stage;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    // ## Implementation
    public class SimplestMouseFollowComponent extends PBComponent
    {
        
        // Make sure we have access to the stage (via dependency injection).
        [Inject]
        public var stage:Stage;
        
        // Specify the property we'll write the mouse position to. This will
        // use the same syntax as we say in the BindingDemoScene.
        public var targetProperty:String;
        
        // ## Setup
        // Register for mouse move events.
        protected override function onAdd():void
        {
            super.onAdd();
            
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
        }
        
        // ## MOUSE_MOVE Handler
        // Store the observed mouse position on every event.
        protected function onMove(me:MouseEvent):void
        {
            owner.setProperty(targetProperty, new Point(me.stageX, me.stageY));
        }
        
        // ## Teardown
        // Clean ourselves up when we're removed.
        protected override function onRemove():void
        {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
            
            super.onRemove();
        }
    }
}
// @docco-chapter 1. First Steps
// @docco-order 7
