package io.smash.core
{
    import avmplus.getQualifiedClassName;

    import flash.net.registerClassAlias;

    import io.smash.Smash;
    import io.smash.debug.Logger;
    import io.smash.smash_internal;
    import io.smash.util.Injector;


    use namespace smash_internal;

    /**
     * SmashGroup provides lifecycle functionality (SmashObjects in it are destroy()ed
     * when it is destroy()ed), as well as dependency injection (see
     * registerManager).
     *
     * SmashGroups are unique because they don't require an owningGroup to
     * be initialize()ed.
     */
    public class SmashGroup extends SmashObject
    {
        protected var _items:Vector.<SmashObject> = new Vector.<SmashObject>();
        protected var _injector:Injector = null;

        public function SmashGroup(_name:String = null)
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
         * Does this SmashGroup directly contain the specified object?
         */
        public final function contains(object:SmashObject):Boolean
        {
            return (object.owningGroup == this);
        }

        /**
         * How many SmashObjects are in this group?
         */
        public final function get length():int
        {
            return _items.length;
        }

        /**
         * Return the SmashObject at the specified index.
         */
        public final function getSmashObjectAt(index:int):SmashObject
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
				// todo add root group error
				
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
                getSmashObjectAt(length-1).destroy();

            // Shut down the managers we own.
            if(_injector)
            {
                for(var key:* in _injector.mappedValues)
                {
                    const val:* = _injector.mappedValues[key];
                    if(val is ISmashManager)
                        (val as ISmashManager).destroy();
                }
            }
        }

        smash_internal function noteRemove(object:SmashObject):void
        {
            // Get it out of the list.
            var idx:int = _items.indexOf(object);
            if(idx == -1)
                throw new Error("Can't find SmashObject in SmashGroup! Inconsistent group membership!");
            _items.splice(idx, 1);
        }

        smash_internal function noteAdd(object:SmashObject):void
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
         * clazz. If the "manager" implements the ISmashManager interface, then
         * initialize() is called at this time. When the SmashGroup's destroy()
         * method is called, then destroy() is called on the manager if it
         * implements ISmashManager. Injection is also done on the manager when it
         * is registered.
         */
        public function registerManager(clazz:Class, instance:*):void
        {
            // register a short name for the manager, this is mainly used for tooling
            var shortName:String = getQualifiedClassName(clazz).split("::")[1];
            registerClassAlias(shortName,clazz);

            initInjection();
            _injector.mapValue(instance, clazz);
            _injector.apply(instance);

            if(instance is ISmashManager)
                (instance as ISmashManager).initialize();
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
         * SmashGroup's injection mappings.
         */
        public function injectInto(object:*):void
        {
            injector.apply(object);
        }

        public function lookup(name:String):SmashObject
        {
            for each(var go:SmashObject in _items)
            {
                if(go.name == name)
                    return go;
            }

            Logger.error(SmashGroup, "lookup", "lookup failed! GameObject by the name of " + name + " does not exist");

            return null;
            //return owningGroup.lookup(name);
        }
    }
}