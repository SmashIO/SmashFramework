package io.smash.core
{
    import io.smash.smash_internal;
    
    use namespace smash_internal
    
    /**
     * PBSet provides safe references to one or more PBObjects. When the
     * referenced PBObjects are destroy()ed, then they are automatically removed
     * from any PBSets. 
     */
    public class SESet extends SEObject
    {
        protected var items:Vector.<SEObject> = new Vector.<SEObject>;
        
        public function SESet(_name:String = null)
        {
            super(_name);
        }

        /**
         * Add a PBObject to the set. 
         */
        public function add(object:SEObject):void
        {
            items.push(object);
            object.noteSetAdd(this);
        }
        
        /**
         * Remove a PBObject from the set.
         */
        public function remove(object:SEObject):void
        {
            var idx:int = items.indexOf(object);
            if(idx == -1)
                throw new Error("Requested PBObject is not in this PBSet.");
            items.splice(idx, 1);
            object.noteSetRemove(this);
        }
        
        /**
         * Does this PBSet contain the specified object? 
         */
        public function contains(object:SEObject):Boolean
        {
            return (items.indexOf(object) != -1);
        }
        
        /**
         * How many objects are in the set?
         */
        public function get length():int
        {
            return items.length;
        }
        
        /**
         * Return the object at the specified index of the set.
         */
        public function getPBObjectAt(index:int):SEObject
        {
            return items[index];
        }
    }
}