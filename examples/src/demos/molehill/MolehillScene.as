package demos.molehill
{
    import io.smash.SmashUtil;
    import io.smash.core.SEGameObject;
    import io.smash.core.SEGroup;
    import io.smash.time.ITicked;
    import io.smash.time.TimeManager;
    
    import flash.display.Stage;
    import flash.geom.Point;
    
    /**
     * Demo showing how to do a little Molehill rendering. This is an 
     * advanced demo is light on the docs.
     * 
     * If you are getting a bad FPS (<20), make sure wmode = direct
     */
    public class MolehillScene extends SEGroup implements ITicked
    {
        [Inject]
        public var stage:Stage;
        
        [Inject]
        public var timeManager:TimeManager;
        
        public override function initialize():void
        {
            super.initialize();
            
            registerManager(QuadScene, new QuadScene());
            
            for(var i:int=0; i<1000; i++)
                createQuad();
            
            timeManager.addTickedObject(this);
        }
        
        public override function destroy():void
        {
            timeManager.removeTickedObject(this);
            
            super.destroy();
        }
        
        public function createQuad():void
        {
            var go:MolehillGameObject = new MolehillGameObject();
            go.owningGroup = this;
            
            go.render.size = new Point(SmashUtil.pickWithBias(10, 100), SmashUtil.pickWithBias(10, 100));
            go.render.addBinding("position", "@mover.position");

            go.initialize();
        }
        
        public function onTick():void
        {
            // Add some neat behavior here!
        }
    }
}