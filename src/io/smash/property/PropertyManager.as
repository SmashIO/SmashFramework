package io.smash.property
{
    import io.smash.core.ISmashManager;
    import io.smash.smash_internal;
    
    use namespace smash_internal;
    
    public class PropertyManager implements ISmashManager
    {
        public function PropertyManager()
        {
            // Set up default plugins.
            registerPropertyType("@", new ComponentPlugin());
        }
        
        public function initialize():void
        {
        }
        
        public function destroy():void
        {
        }
        
        protected var propertyPlugins:Object = {};
        public function registerPropertyType(prefix:String, plugin:IPropertyPlugin):void
        {
            propertyPlugins[prefix] = plugin;
        }
        
        protected var parseCache:Object = {};
        protected var cachedPi:PropertyInfo = new PropertyInfo();
        smash_internal function findProperty(scope:*, property:String, providedInfo:PropertyInfo):PropertyInfo
        {
            if(property == null || property.length == 0)
                return null;
            
            // See if it is cached...
            if(!parseCache[property])
            {
                // Parse and store it.
                parseCache[property] = [property.charAt(0)].concat(property.substr(1).split("."));
            }
            
            // Either errored or cached at this point.
            
            // Awesome, switch off the type...
            const cached:Array = parseCache[property];
            const plugin:IPropertyPlugin = propertyPlugins[cached[0]];
            if(!plugin)
                throw new Error("Unknown prefix '" + cached[0] + "' in '" + property + "'.");
            
            // Let the plugin do its thing.
            plugin.resolve(scope, cached, providedInfo);
            
            return providedInfo;
        }
        
        protected var bindingCache:Object = {};        
        public function applyBinding(scope:*, binding:String):void
        {
            // Cache parsing if possible.
            if(!bindingCache[binding])
                bindingCache[binding] = binding.split("||");
            
            // Now do the mapping.
            const bindingCached:Array = bindingCache[binding];
            scope[bindingCached[0]] = findProperty(scope, bindingCached[1], cachedPi).getValue();
        }
        
        public function getProperty(scope:*, property:String, defaultValue:*):*
        {
            // Look it up.
            const resPi:PropertyInfo = findProperty(scope, property, cachedPi);
            
            // Get value or return default.
            if(resPi)
                return resPi.getValue();
            else
                return defaultValue;
        }
        
        public function setProperty(scope:*, property:String, value:*):void
        {
            // Look it up.
            const resPi:PropertyInfo = findProperty(scope, property, cachedPi);
            
            // Abort if not found, can't set nothing!
            if(resPi == null)
                return;
            
            resPi.setValue(value);
        }
        
    }
}
