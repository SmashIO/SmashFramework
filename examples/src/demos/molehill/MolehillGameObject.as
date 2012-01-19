package demos.molehill
{
    import io.smash.core.SmashGameObject;
    
    public class MolehillGameObject extends SmashGameObject
    {
        public var render:QuadRenderer = new QuadRenderer();
        public var mover:RandomMover = new RandomMover();
    }
}