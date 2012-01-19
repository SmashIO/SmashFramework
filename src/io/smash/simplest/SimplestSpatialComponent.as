/**
 * SimplestSpatialComponent simply stores a position.
 * 
 * In a more complex game, it might tie into Box2D, or provide some
 * game-specific spatial behavior (like for a tile based game where everything 
 * has to be in the tile map). It might just add a notion of velocity and a
 * per-frame callback to update the position.
 *
 * You could think of SimplestSpatialComponent as being a "model" from an MVC
 * perspective.
 */
package io.smash.simplest
{
    import io.smash.core.SmashComponent;
    
    import flash.geom.Point;
    
    public class SimplestSpatialComponent extends SmashComponent
    {
        public var position:Point = new Point();
    }
}
// @docco-chapter 1. First Steps
// @docco-order 5
