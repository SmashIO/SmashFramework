package io.smash.core
{
    import io.smash.smash_internal;
    
    use namespace smash_internal
    
    /**
     * SmashSet provides safe references to one or more SmashObjects. When the
     * referenced SmashObjects are destroy()ed, then they are automatically removed
     * from any SmashSets. 
     */
    public class SmashSet extends SmashObject
    {
        protected var items:Vector.<SmashObject> = new Vector.<SmashObject>;
        
        public function SmashSet(_name:String = null)
        {
            super(_name);
        }

        /**
         * Add a SmashObject to the set. 
         */
        public function add(object:SmashObject):void
        {
            items.push(object);
            object.noteSetAdd(this);
        }
        
        /**
         * Remove a SmashObject from the set.
         */
        public function remove(object:SmashObject):void
        {
            var idx:int = items.indexOf(object);
            if(idx == -1)
                throw new Error("Requested SmashObject is not in this SmashSet.");
            items.splice(idx, 1);
            object.noteSetRemove(this);
        }
        
        /**
         * Does this SmashSet contain the specified object? 
         */
        public function contains(object:SmashObject):Boolean
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
        public function getSmashObjectAt(index:int):SmashObject
        {
            return items[index];
        }
    }
}