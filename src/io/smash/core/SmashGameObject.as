package io.smash.core
{
    import io.smash.smash_internal;
    import io.smash.property.PropertyManager;
    import io.smash.util.TypeUtility;
    
    import flash.utils.Dictionary;
    
    use namespace smash_internal;
    
    /**
     * Container class for SmashComponent. Most game objects are made by 
     * instantiating SmashGameObject and filling it with one or more SmashComponent
     * instances.
     */
    public class SmashGameObject extends SmashObject
    {
        private var _deferring:Boolean = true;
        private var _components:Dictionary = new Dictionary();
        
        public function SmashGameObject(_name:String = null)
        {
            super(_name);
        }

        public function get deferring():Boolean
        {
            return _deferring;
        }
        
        /**
         * If true, then components that are added aren't registered until 
         * deferring is set to false. This is used when you are adding a lot of
         * components, or you are adding components with cyclical dependencies
         * and need them to all be present on the SmashGameObject before their
         * onAdd methods are called.
         */
        public function set deferring(value:Boolean):void
        {
            if(_deferring && value == false)
            {
                // Loop as long as we keep finding deferred stuff, the 
                // dictionary delete operations can mess up ordering so we have
                // to check to avoid missing stuff. This is a little lame but
                // our previous implementation involved allocating lots of 
                // temporary helper objects, which this avoids, so there you go.
                var foundDeferred:Boolean = true;
                
                while(foundDeferred)
                {
                    foundDeferred = false;
                    
                    // Initialize deferred components.
                    for(var key:String in _components)
                    {
                        // Normal entries just have alphanumeric.
                        if(key.charAt(0) != "!")
                            continue;
                        
                        // It's a deferral, so init it...
                        doInitialize(_components[key] as SmashComponent);
                        
                        // ... and nuke the entry.
                        _components[key] = null;
                        delete _components[key];
                        
                        // Indicate we found stuff so keep looking. Otherwise
                        // we may miss some.
                        foundDeferred = true;
                    }
                }
            }
            
            _deferring = value;
        }
        
        protected function doInitialize(component:SmashComponent):void
        {
            component._owner = this;
            owningGroup.injectInto(component);
            component.doAdd();
        }
        
        /**
         * Add a component to the SmashGameObject. Subject to the deferring flag,
         * the component will be initialized immediately.
         * 
         * If there is a public var on this SmashGameObject (ie, you've subclassed
         * SmashGameObject) with the same name as the component has, it will be
         * populated with a reference to the component. This way you can get
         * typed access to components on your game objects.
         */
        public function addComponent(component:SmashComponent, name:String = null):void
        {
            if(name)
                component.name = name;
            
            if(component.name == null || component.name == "")
                throw new Error("Can't add component with no name.");
            
            // Stuff in dictionary.
            _components[component.name] = component;
            
            // Set component owner.
            component._owner = this;
            
            // Directly set field if present.
            if(hasOwnProperty(component.name))
                this[component.name] = component;
            
            // Defer or add now.
            if(_deferring)
                _components["!" + component.name] = component;
            else
                doInitialize(component);
        }
        
        /**
         * Remove a component from this game object.
         */
        public function removeComponent(component:SmashComponent):void
        {
            if(component.owner != this)
                throw new Error("Tried to remove a component that does not belong to this SmashGameObject.");
            
            if(this.hasOwnProperty(component.name) && this[component.name] == component)
                this[component.name] = null;
            
            _components[component.name] = null;
            delete _components[component.name];            
            component.doRemove();
            component._owner = null;
        }
        
        /**
         * Look up a component by name.
         */
        public function lookupComponent(name:String):*
        {
            return _components[name] as SmashComponent;
        }
        
        /**
         * Get a fresh Vector with references to all the components in this
         * game object.
         */
        public function getAllComponents():Vector.<SmashComponent>
        {
            var out:Vector.<SmashComponent> = new Vector.<SmashComponent>();
            for(var key:String in _components)
                out.push(_components[key]);
            return out;
        }
        
        /**
         * Initialize the game object! This is done in a couple of stages.
         * 
         * First, the SmashObject initialization is performed.
         * Second, we look for any components in public vars on the SmashGameObject.
         * This allows you to get at them by direct typed references instead of
         * doing lookups. If we find any, we add them to the game object.
         * Third, we turn off the deferring flag, so any components you've added
         * via addComponent get initialized.
         * Fourth, dependency injection is performed on ourselves and our components. 
         * Finally, we call applyBindings to make sure we have the latest data
         * for any registered data bindings.
         */
        public override function initialize():void
        {
            super.initialize();
            
            // Look for un-added members.
            for each(var key:String in TypeUtility.getListOfPublicFields(this))
            {
                // Only consider components.
                if(!(this[key] is SmashComponent))
                    continue;
                
                // Don't double initialize.
                if(this[key].owner != null)
                    continue;
                
                // OK, add the component.
                const nc:SmashComponent = this[key] as SmashComponent;
                
                if(nc.name != null && nc.name != "" && nc.name != key)
                    throw new Error("SmashComponent has name '" + nc.name + "' but is set into field named '" + key + "', these need to match!");
                
                nc.name = key;
                addComponent(nc);
            }
            
            // Inject ourselves.
            owningGroup.injectInto(this);
            
            // Stop deferring and let init happen.
            deferring = false;
            
            // Propagate bindings on everything.
            for(var key2:String in _components)
            {
                if(!_components[key2].propertyManager)
                    throw new Error("Failed to inject component properly.");
                _components[key2].applyBindings();
            }
        }
        
        /**
         * Removes any components on this game object, then does normal SmashObject
         * destruction (ie, remove from any groups or sets).
         */
        public override function destroy():void
        {
            for(var key:String in _components)
                removeComponent(_components[key]);
            
            super.destroy();
        }
        
        /**
         * Get a value from this game object in a data driven way. 
         * @param property Property string to look up, ie "@componentName.fieldName"
         * @param defaultValue A default value to return if the desired property is absent.
         */
        public function getProperty(property:String, defaultValue:* = null):*
        {
            return owningGroup.getManager(PropertyManager).getProperty(this, property, defaultValue);
        }
        
        /**
         * Set a value on this game object in a data driven way. 
         * @param property Property string to look up, ie "@componentName.fieldName"
         * @param value Value to set if the property is found.
         */
        public function setProperty(property:String, value:*):void
        {
            owningGroup.getManager(PropertyManager).setProperty(this, property, value);            
        }
    }
}