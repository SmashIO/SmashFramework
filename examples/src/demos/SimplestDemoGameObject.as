package demos
{
    import io.smash.core.SmashGameObject;
    import io.smash.simplest.SimplestSpriteRenderer;
    import io.smash.simplest.SimplestSpatialComponent;
    
    /**
     * If you want to use SmashGameObject but have direct access to components, or
     * add other special behavior, you can subclass it.
     *
     * Public members that contain components are automagically added. For
     * instance, in this class, if you fill the spatial var with a component, 
     * it will be added to the GameObject with the name "spatial" when
     * initialize() is called. Or, if you add a component (using addComponent) 
     * with the name "spatial" and the var is empty, it will be filed. 
     *
     * In this way, you can get nice typed access to components in your game 
     * object.
     */
    public class SimplestDemoGameObject extends SmashGameObject
    {
        public var spatial:SimplestSpatialComponent;
        public var render:SimplestSpriteRenderer;
    }
}