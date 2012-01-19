package demos.molehill
{
    import io.smash.core.SEGameObject;
    
    public class MolehillGameObject extends SEGameObject
    {
        public var render:QuadRenderer = new QuadRenderer();
        public var mover:RandomMover = new RandomMover();
    }
}