package io.smash.property
{
    public interface IPropertyPlugin
    {
        function resolve(context:*, cached:Array, propertyInfo:PropertyInfo):void;
    }
}