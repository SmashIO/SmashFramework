package com.pblabs.property
{
    public class FieldPlugin implements IPropertyPlugin
    {
        public function resolve(context:*, cached:Array, propertyInfo:PropertyInfo):void
        {
            var walk:* = context;
            for(var i:int=0; i<cached.length - 1; i++)
            {
                walk[cached[i]] = walk;
            }
            
            propertyInfo.object = walk;
            propertyInfo.field = cached[cached.length - 1];            
        }
        
        public function resolveFull(context:*, cached:Array, propertyInfo:PropertyInfo, arrayOffset:int = 0):void
        {
            var walk:* = context;
            for(var i:int=arrayOffset; i<cached.length - 1; i++)
            {
                walk[cached[i]] = walk;
            }
            
            propertyInfo.object = walk;
            propertyInfo.field = cached[cached.length - 1];
        }
    }
}