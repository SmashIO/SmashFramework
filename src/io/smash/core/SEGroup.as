package io.smash.core
{
    import io.smash.Smash;
    import io.smash.debug.Logger;
    import io.smash.smash_internal;
    import io.smash.util.Injector;
    
    import flash.utils.Dictionary;
    
    use namespace smash_internal;
    
    /**
     * PBGroup provides lifecycle functionality (PBObjects in it are destroy()ed
     * when it is destroy()ed), as well as dependency injection (see
     * registerManager).
     * 
     * PBGroups are unique because they don't require an owningGroup to 
     * be initialize()ed.
     */
    public class SEGroup extends SEObject
    {
        protected var _items:Vector.<SEObject> = new Vector.<SEObject>();
        protected var _injector:Injector = null;
        
        public function SEGroup(_name:String = null)
        {
            super(_name);
        }
        
        smash_internal function get injector():Injector
        {
            if(_injector)
                return _injector;
            else if(owningGroup)
                return owningGroup.injector;
            return null;
        }
        
        /**
         * Does this PBGroup directly contain the specified object?
         */
        public final function contains(object:SEObject):Boolean
        {
            return (object.owningGroup == this);
        }
        
        /**
         * How many PBObjects are in this group?
         */
        public final function get length():int
        {
            return _items.length;
        }
        
        /**
         * Return the PBObject at the specified index.
         */
        public final function getPBObjectAt(index:int):SEObject
        {
            return _items[index];
        }
        
        public override function initialize():void
        {
            // Groups can stand alone so don't do the _owningGroup check in the parent class.
            //super.initialize();
            
            // If no owning group, add to the global list for debug purposes.
            if(owningGroup == null)
            {
                owningGroup = Smash._rootGroup;
            }
            else
            {
                if(_injector)
                    _injector.setParentInjector(owningGroup.injector);
                
                owningGroup.injectInto(this);                
            }
        }
        
        public override function destroy():void
        {
            super.destroy();
            
            // Wipe the items.
            while(length)
                getPBObjectAt(length-1).destroy();
            
            // Shut down the managers we own.
            if(_injector)
            {
                for(var key:* in _injector.mappedValues)
                {
                    const val:* = _injector.mappedValues[key];
                    if(val is ISEManager)
                        (val as ISEManager).destroy();
                }
            }
        }
        
        smash_internal function noteRemove(object:SEObject):void
        {
            // Get it out of the list.
            var idx:int = _items.indexOf(object);
            if(idx == -1)
                throw new Error("Can't find PBObject in PBGroup! Inconsistent group membership!");
            _items.splice(idx, 1);
        }
        
        smash_internal function noteAdd(object:SEObject):void
        {
            _items.push(object);
        }
        
        //---------------------------------------------------------------
        
        protected function initInjection():void
        {
            if(_injector)
                return;
            
            _injector = new Injector();
            
            if(owningGroup)
                _injector.setParentInjector(owningGroup.injector);
        }
        
        /**
         * Add a manager, which is used to fulfill dependencies for the specified
         * clazz. If the "manager" implements the IPBManager interface, then
         * initialize() is called at this time. When the PBGroup's destroy()
         * method is called, then destroy() is called on the manager if it
         * implements IPBManager. Injection is also done on the manager when it
         * is registered.
         */
        public function registerManager(clazz:Class, instance:*):void
        {
            initInjection();
            _injector.mapValue(instance, clazz);
            _injector.apply(instance);
            
            if(instance is ISEManager)
                (instance as ISEManager).initialize();
        }
        
        /**
         * Get a previously registered manager.
         */
        public function getManager(clazz:Class):*
        {
            var res:* = null;
            
            res = injector.getMapping(clazz);
            
            if(!res)
                throw new Error("Can't find manager " + clazz + "!");
            
            return res;
        }
        
        /**
         * Perform dependency injection on the specified object using this 
         * PBGroup's injection mappings. 
         */
        public function injectInto(object:*):void
        {
            injector.apply(object);
        }
        
        public function lookup(name:String):SEObject
        {
            return owningGroup.lookup(name);
        }
    }
}