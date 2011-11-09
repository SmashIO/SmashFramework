package com.pblabs.core
{
    import com.pblabs.pb_internal;
    
    use namespace pb_internal;
    
    /**
     * Base class for things that have names, lifecycles, and exist in a PBSet or
     * PBGroup.
     * 
     * To use a PBObject:
     * 
     * 1. Instantiate one. (var foo = new PBGroup();)
     * 2. Set the owning group. (foo.owningGroup = rootGroup;)
     * 3. Call initialize(). (foo.initialize();) 
     * 4. Use the object!
     * 5. When you're done, call destroy(). (foo.destroy();)
     */
    public class PBObject
    {
        private var _name:String;
        private var _active:Boolean = false;
        
        pb_internal var _owningGroup:PBGroup;
        pb_internal var _sets:Vector.<PBSet>;
        
        public function PBObject(_name:String = null)
        {
            name = _name;
        }
        
        /**
         * Name of the PBObject. Used for dynamic lookups and debugging.
         */
        public function get name():String
        {
            return _name;
        }

        /**
         * @private
         */
        public function set name(value:String):void
        {
            if(_active && _owningGroup)
                throw new Error("Cannot change PBObject name after initialize() is called and while in a PBGroup.");
            
            _name = value;
        }

        /**
         * What PBSets reference this PBObject?
         */
        public function get sets():Vector.<PBSet>
        {
            return _sets;
        }
        
        /**
         * @private
         */
        public function get owningGroup():PBGroup
        {
            return _owningGroup;
        }
        
        /**
         * The PBGroup that contains us. All PBObjects must be in a PBGroup,
         * and the owningGroup has to be set before calling initialize().
         */
        public function set owningGroup(value:PBGroup):void
        {
            if(!value)
                throw new Error("A PBObject must always be in a PBGroup.");
            
            if(_owningGroup)
                _owningGroup.noteRemove(this);
            
            _owningGroup = value;
            _owningGroup.noteAdd(this);
        }
        
        pb_internal function noteSetAdd(set:PBSet):void
        {
            if(_sets == null)
                _sets = new Vector.<PBSet>();
            _sets.push(set);            
        }
        
        pb_internal function noteSetRemove(set:PBSet):void
        {
            var idx:int = _sets.indexOf(set);
            if(idx == -1)
                throw new Error("Tried to remove PBObject from a PBSet it didn't know it was in!");
            _sets.splice(idx, 1);            
        }
        
        /**
         * Called to initialize the PBObject. The PBObject must be in a PBGroup
         * before calling this (ie, set owningGroup).
         */
        public function initialize():void
        {
            // Error if not in a group.
            if(_owningGroup == null)
                throw new Error("Can't initialize a PBObject without an owning PBGroup!");
            
            _active = true;
        }
        
        /**
         * Called to destroy the PBObject: remove it from sets and groups, and do
         * other end of life cleanup.
         */
        public function destroy():void
        {
            // Remove from sets.
            if(_sets)
            {
                while(_sets.length)
                    _sets[_sets.length-1].remove(this);
            }
            
            // Remove from owning group.
            if(_owningGroup)
            {
                _owningGroup.noteRemove(this);
                _owningGroup = null;                
            }
            
            _active = false;            
        }
    }
}