package com.pblabs.simpler
{
    import com.pblabs.core.PBComponent;
    import com.pblabs.time.AnimatedComponent;
    
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.geom.Point;
    
    public class SimpleSpriteRenderer extends AnimatedComponent
    {
        public var sprite:Sprite = new Sprite();
        protected var _position:Point = new Point();
        
        [Inject]
        public var stage:Stage;
        
        public function get position():Point
        {
            return _position;
        }
        
        public function set position(value:Point):void
        {
            _position = value;
            
            sprite.x = position.x;
            sprite.y = position.y;            
        }
        
        protected override function onAdd():void
        {
            super.onAdd();
            
            sprite.graphics.lineStyle(2, 0);
            sprite.graphics.beginFill(0xFF00FF);
            sprite.graphics.drawCircle(0, 0, 20);
            
            stage.addChild(sprite);
        }
        
        protected override function onRemove():void
        {
            stage.removeChild(sprite);
            
            super.onRemove();
        }
        
    }
}