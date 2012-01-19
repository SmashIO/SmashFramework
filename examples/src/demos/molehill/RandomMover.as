package demos.molehill
{
    import io.smash.core.SEComponent;
    
    import flash.geom.Point;
    
    /**
     * Simple component that returns a new random position every time you ask.
     */
    public class RandomMover extends SEComponent
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