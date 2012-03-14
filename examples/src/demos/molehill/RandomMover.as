package demos.molehill
{
    import flash.geom.Point;
    
    import io.smash.core.SmashComponent;
    
    /**
     * Simple component that returns a new random position every time you ask.
     */
    public class RandomMover extends SmashComponent
    {
        protected var _position:Point = new Point();
        
        public function get position():Point
        {
            _position.x = Math.random() * 1024;
            _position.y = Math.random() * 1024;
            
            return _position;
        }
    }
}