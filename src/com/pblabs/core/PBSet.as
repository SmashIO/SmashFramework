package com.pblabs.core
{
    import com.pblabs.pb_internal;
    
    use namespace pb_internal
    
    /**
     * PBSet provides safe references to one or more PBObjects. When the
     * referenced PBObjects are destroy()ed, then they are automatically removed
     * from any PBSets. 
     */
    public class PBSet extends PBObject
    {
        protected var items:Vector.<PBObject> = new Vector.<PBObject>;
        
        public function PBSet(_name:String = null)
        {
            super(_name);
        }

        /**
         * Add a PBObject to the set. 
         */
        public function add(object:PBObject):void
        {
            items.push(object);
            object.noteSetAdd(this);
        }
        
        /**
         * Remove a PBObject from the set.
         */
        public function remove(object:PBObject):void 
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
        public function contains(object:PBObject):Boolean
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
        public function getPBObjectAt(index:int):PBObject
        {
            return items[index];
        }
    }
}