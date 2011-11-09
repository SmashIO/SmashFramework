package com.pblabs.property
{
    public interface IPropertyPlugin
    {
        function resolve(context:*, cached:Array, propertyInfo:PropertyInfo):void;
    }
}