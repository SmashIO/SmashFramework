/*******************************************************************************
 * ZaaImbue
 * Copyright (c) 2011 ZaaLabs, Ltd.
 * For more information see http://www.zaalabs.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the license.txt file at the root directory of this library.
 * 
 * This file has been modified to reuse existing PBE type utility code and be
 * even simpler, which is why it is in com.pblabs.util instead of
 * com.zaalabs.imbue. This variant is maintained by the PBE team.
 * 
 * Other changes by PBE team:
 *      - Error if injection can't be fulfilled.
 *      - Parent injector support.
 ******************************************************************************/
package com.pblabs.util
{
    
    import com.pblabs.pb_internal;
    
    import flash.utils.Dictionary;
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;
    
    use namespace pb_internal;
    
    /**
     * The Default implementation for the IInjector interface. It provides
     * some basic functionality for getting an dependency injection system
     * going. Nothing fancy or magical going on here, Pretty straightforward
     */
    public class Injector
    {
        
        /**
         * Maps a value to a certain class, so when <code>apply()</code>
         * is called, the value will be injected into any property with the
         * [Inject] tag over it and that matches the class definition specified
         * in the <code>toClass</code> parameter.
         *
         * @param value The dependency that will be injected
         * @param toClass The class that the dependency will be injected into
         */
        public function mapValue(value:Object, toClass:Class):void
        {
            mappedValues[toClass] = value;
        }
        
        public function getMapping(clazz:Class):*
        {
            if(mappedValues[clazz])
                return mappedValues[clazz];
            
            if(parentInjector)
                return parentInjector.getMapping(clazz);
            
            return null;            
        }
        
        /**
         * Applies the injection to the specified object. If you wish to have a
         * property injected into the specified object, make sure that an [Inject]
         * metadata tag is added to the desired target property and the value is
         * mapped in this injector using the <code>mapValue()</code> method.
         *
         * @param value the object that will be injected
         */
        public function apply(value:Object):void
        {
            var definition:Class = TypeUtility.getClass(value);
            var targets:Vector.<InjectionTarget> = getInjectionTargets(definition) as Vector.<InjectionTarget>;
            var postConstruct:Vector.<PostInjectionTarget> = getPostConstructTargets(definition) as Vector.<PostInjectionTarget>;
            
            // apply injections to each target
            for each(var target:InjectionTarget in targets) 
            applyToTarget(target,value);
            
            if(targets.length)
            {
                // apply post construct
                for each(var pcTarget:PostInjectionTarget in postConstruct)
                {
                    var f:Function = value[pcTarget.method];
                    if(f != null) f();
                }
            }
        }
        
        /**
         * Set a parent injector to fulfill any injections this injector cannot. 
         */
        public function setParentInjector(injector:Injector):void
        {
            parentInjector = injector;
        }
        
        //_____________________________________________________________________
        //	Constructor
        //_____________________________________________________________________
        public function Injector()
        {
            // Initialize the member properties
            mappedValues = new Dictionary();
        }
        
        //_____________________________________________________________________
        //	Protected Properties
        //_____________________________________________________________________
        /**
         * @private
         */
        pb_internal var mappedValues:Dictionary;
        
        /**
         * @private
         */
        pb_internal var parentInjector:Injector;
        
        /**
         * @private
         */
        protected static var injectionTargetCache:Dictionary = new Dictionary();
        
        /**
         * @private
         */
        protected static var postConstructTargetCache:Dictionary = new Dictionary();
        
        //_____________________________________________________________________
        //	Protected methods
        //_____________________________________________________________________
        /**
         * Returns InjectionTargets for the specified class, from either a cached
         * instance or calculated on demand. This function also stores caches for
         * DescribeType calls.
         *
         * Structuring calls this way makes the Injectors api more extendable by
         * exposing our caching mechanisms and abstracting it.
         *
         * @param value
         * @return
         */
        public static function getInjectionTargets(value:Class):Vector.<InjectionTarget>
        {
            // Return it is we have it in the cache
            if (injectionTargetCache[value])
            {
                return injectionTargetCache[value] as Vector.<InjectionTarget>;
            }
            
            // Look over the xml type definition and create injector targets
            var result:Vector.<InjectionTarget> = new Vector.<InjectionTarget>();
            
            var definition:XML = TypeUtility.getTypeDescription(value);
            var target:InjectionTarget;
            
            for each (var node:XML in definition.factory.*.(name() == 'variable' || name() == 'accessor').metadata.(@name == 'Inject'))
            {
                target = new InjectionTarget();
                target.property = node.parent().@name;
                target.definition = getDefinitionByName(node.parent().@type) as Class;
                target.uri = node.parent().@uri;
                result.push(target);
            }
            
            return result;
        }
        
        public static function getPostConstructTargets(value:Class):Vector.<PostInjectionTarget>
        {
            // try to find it in the cache
            if(postConstructTargetCache[value])
            {
                return postConstructTargetCache[value] as Vector.<PostInjectionTarget>;
            }
            
            // Look over the xml type definition and create injector targets
            var result:Vector.<PostInjectionTarget> = new Vector.<PostInjectionTarget>();
            
            var definition:XML = TypeUtility.getTypeDescription(value);
            var target:PostInjectionTarget;
            
            for each (var node:XML in definition.factory.*.(name() == 'method').metadata.(@name == 'PostInject')) 
            {
                target = new PostInjectionTarget();
                target.method = node.parent().@name;
                result.push(target);
            }
            
            return result;
        }
        
        protected function applyToTarget(target:InjectionTarget,value:Object):void
        {
            var injectedValue:Object = mappedValues[target.definition];
            
            if(!injectedValue)
            {
                if(parentInjector)
                    parentInjector.applyToTarget(target, value);
                else
                    throw new Error("No rule for injecting " + target.definition + " into " + TypeUtility.getClass(value).toString() + "!");
                
                return;
            }
            
            if(target.uri.length == 0)
            {
                // Inject the regular way
                value[target.property] = injectedValue;
            }
            else
            {
                throw new Error("Cannot inject into namespaced variable " + target.property + ".");
            }
        }
    }
}

/**
 * Simple Class for holding Injection information
 */
class InjectionTarget
{
    public var property:String;
    public var definition:Class;
    public var uri:String;
}

/**
 * Simple Class for holding Post Injection information
 */
class PostInjectionTarget
{
    public var method:String;
}