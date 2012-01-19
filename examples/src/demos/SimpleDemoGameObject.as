package demos
{
    import io.smash.core.SmashGameObject;
    import io.smash.simpler.SimpleSpriteRenderer;
    import io.smash.simplest.SimplestSpatialComponent;
    
    /**
     * Same idea as SimplestDemoGameObject, but with different types. See
     * SimplestDemoGameObject for a fuller explanation.
     */
    public class SimpleDemoGameObject extends SmashGameObject
    {
        public var spatial:SimplestSpatialComponent;
        public var render:SimpleSpriteRenderer;
    }
}