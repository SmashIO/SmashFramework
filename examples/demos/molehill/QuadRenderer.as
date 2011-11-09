package demos.molehill
{
    import com.pblabs.time.AnimatedComponent;
    
    import flash.geom.Point;
    
    /**
     * Component that works with QuadScene to render a bunch of hardware quads.
     */
    public class QuadRenderer extends AnimatedComponent
    {
        [Inject]
        public var scene:QuadScene;

        public var texture:String = "*white";
        public var position:Point = new Point(100, 100);
        public var rotation:Number = 0;
        public var size:Point = new Point(10, 10);
        
        public override function onFrame():void
        {
            super.onFrame();
            
            scene.addQuad(texture, position.x, position.y, size.x, size.y, rotation);
        }
        
    }
}