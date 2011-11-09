package demos.molehill
{
    import com.pblabs.core.PBGameObject;
    
    public class MolehillGameObject extends PBGameObject
    {
        public var render:QuadRenderer = new QuadRenderer();
        public var mover:RandomMover = new RandomMover();
    }
}