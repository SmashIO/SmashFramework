package com.pblabs.simpler
{
    import com.pblabs.time.TickedComponent;
    import com.pblabs.time.TimeManager;
    
    import flash.display.Stage;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    public class MouseFollowComponent extends TickedComponent
    {
        [Inject]
        public var stage:Stage;
        
        public var targetProperty:String;
        
        public override function onTick():void
        {
            owner.setProperty(targetProperty, new Point(stage.mouseX, stage.mouseY));
        }
    }
}