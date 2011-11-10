package io.smash.property
{
    import io.smash.core.SEComponent;
    import io.smash.core.SEGameObject;
    
    public class ComponentPlugin implements IPropertyPlugin
    {
        protected var fieldResolver:FieldPlugin = new FieldPlugin();
        
        public function resolve(context:*, cached:Array, propertyInfo:PropertyInfo):void
        {
            // Context had better be an entity.
            var entity:SEGameObject;
            if(context is SEGameObject)
                entity = context;
            else if(context is SEComponent)
                entity = context.owner;
            else
                throw new Error("Can't find entity to do lookup!");
            
            // Look up the component.
            const component:SEComponent = entity.lookupComponent(cached[1]);
            
            if(cached.length > 2)
            {
                // Look further into the object. 
                fieldResolver.resolveFull(component, cached, propertyInfo, 2);
            }
            else
            {
                propertyInfo.object = component;
                propertyInfo.field = null;
            }
        }
    }
}