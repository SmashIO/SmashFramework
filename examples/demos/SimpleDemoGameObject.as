package demos
{
    import com.pblabs.core.PBGameObject;
    import com.pblabs.simpler.SimpleSpriteRenderer;
    import com.pblabs.simplest.SimplestSpatialComponent;
    
    /**
     * Same idea as SimplestDemoGameObject, but with different types. See
     * SimplestDemoGameObject for a fuller explanation.
     */
    public class SimpleDemoGameObject extends PBGameObject
    {
        public var spatial:SimplestSpatialComponent;
        public var render:SimpleSpriteRenderer;
    }
}