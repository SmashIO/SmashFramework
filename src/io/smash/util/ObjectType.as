/*******************************************************************************
 * Smash Engine
 * Copyright (C) 2009 Smash Labs, LLC
 * For more information see http://www.Smashengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package io.smash.util
{
    import io.smash.debug.Logger;
    
    import flash.utils.Dictionary;
    
    [EditorData(editAs="Array", typeHint="String")]
    
    /**
     * An ObjectType is an abstraction of a bitmask that can be used to associate
     * objects with type names. ObjectTypes are namespaced so that we can separate
     * flags that are unrelated.
     */
    public class ObjectType /*implements ISerializable*/
    {
        protected var _namespace:ObjectTypeNamespace;
        protected var _bits:int = 0;
        
        public function ObjectType(...arguments)
        {
            _namespace = getNamespace("global", true);
            
            if(arguments.length == 1)
            {
                if(arguments[0] is Array)
                    typeNames = arguments[0];
                else
                    typeName = arguments[0];
            }
            else if(arguments.length > 1)
            {
                typeNames = arguments;
            }
        }
        
        public function get namespace():String
        {
            return _namespace.name;
        }
        
        public function set namespace(value:String):void
        {
            _namespace = getNamespace(value, true);
            
            // TODO: Remap the bit names when we switch?
            if(_bits != 0)
                Logger.warn(this, "set namespace", "Discarding bits due to change in namespace!"); 
            _bits = 0;
        }
        
        /**
         * The bitmask that this type wraps. This should not be used directly. Instead,
         * use the various test methods on the ObjectTypeManager.
         * 
         * @see io.smash.engine.core.ObjectTypeManager.doesTypeMatch()
         * @see io.smash.engine.core.ObjectTypeManager.doesTypeOverlap()
         * @see io.smash.engine.core.ObjectTypeManager.doTypesMatch()
         * @see io.smash.engine.core.ObjectTypeManager.doTypesOverlap()
         */
        public function get bits():int
        {
            return _bits;
        }
        
        /**
         * The name of the type associated with this object type. If multiple names have
         * been assigned, the one with the least significant bit is returned.
         */
        public function get typeName():String
        {
            for (var i:int = 0; i < _namespace.typeCount; i++)
            {
                if (_bits & (1 << i))
                    return _namespace.getTypeName(1 << i);
            }
            
            return "";
        }
        
        /**
         * @private
         */
        public function set typeName(value:String):void
        {
            _bits = _namespace.getType(value);
        }
        
        /**
         * A list of all the type names associated with this object type.
         */
        public function get typeNames():Array
        {
            var array:Array = new Array();
            for (var i:int = 0; i < _namespace.typeCount; i++)
            {
                if (_bits & (1 << i))
                    array.push(_namespace.getTypeName(1 << i));
            }
            
            return array;
        }
        
        /**
         * @private
         */
        public function set typeNames(value:Array):void
        {
            _bits = 0;
            for each (var typeName:String in value)
            _bits |= _namespace.getType(typeName);
        }
        
        
        /**
         * Add typeName to current ObjectType
         */
        public function add(typeName:String):void
        {
            _bits |= _namespace.getType(typeName);	  	
        }      
        
        /**
         * Remove typeName from current ObjectType
         */
        public function remove(typeName:String):void
        { 		
            _bits &= (wildcard.bits - _namespace.getType(typeName));	  		  	
        }
        
        /**
         * Perform a bitwise-and against another ObjectType and return true if they match.
         */
        public function and(other:ObjectType):Boolean
        {
            if((other.bits & bits) != 0)
                return true;
            else
                return false;
        }
        
        /**
         * Determines whether an object type is of the specified type.
         
         * @param typeName The name of the type to check.
         * 
         * @return True if the specified type is of the specified type name. Keep in
         * mind, the type must match exactly, meaning, if it has multiple type names
         * associated with it, this will always return false.
         * 
         * @see #DoesTypeOverlap()
         */
        public function match(typeName:String):Boolean
        {
            var t:* = _namespace.typeList[typeName];
            return (t != null) && _bits == 1 << t;
        }
        
        /**
         * Determines whether an object type contains the specified type.
         * 
         * @param type The type to check.
         * @param typeName The name of the type to check.
         * 
         * @return True if the specified type is of the specified type name. Keep in
         * mind, the type must only contain the type name, meaning, if it has multiple
         * type names associated with it, only one of them has to match.
         * 
         * @see #DoesTypeMatch()
         */
        public function overlap(typeName:String):Boolean
        {
            var t:* = _namespace.typeList[typeName];
            return (t != null) && (_bits & (1 << t)) != 0;
        }
        
        /**
         * Determines whether two object types are of the same type.
         * 
         * @param type1 The type to check.
         * @param type2 The type to check against.
         * 
         * @return True if type1 and type2 contain the exact same types.
         */
        public function matches(other:ObjectType):Boolean
        {
            return _bits == other._bits;
        }
        
        /**
         * Determines whether two object types have overlapping types.
         * 
         * @param type1 The type to check.
         * @param type2 The type to check against.
         * 
         * @return True if type1 has any of the type contained in type2.
         */
        public function overlaps(other:ObjectType):Boolean
        {
            if (!other)
                return false;
            
            return (_bits & other._bits) != 0;
        }
        
        protected static var _namespaces:Dictionary = new Dictionary();
        protected static function getNamespace(name:String, createIfAbsent:Boolean = false):ObjectTypeNamespace
        {
            if(createIfAbsent)
            {
                if(_namespaces.hasOwnProperty(name) == false)
                    _namespaces[name] = new ObjectTypeNamespace(name);					
                
                return _namespaces[name] as ObjectTypeNamespace;
            }
            else
            {
                return _namespaces[name] as ObjectTypeNamespace;
            }
        }
        
        public static function getFlag(flag:String, namespace:String = "global", createIfAbsent:Boolean = false):uint
        {
            var ns:ObjectTypeNamespace = getNamespace(namespace, createIfAbsent);
            if(!ns)
                return 0xFFFFFFFF;
            return ns.getType(flag);
        }
        
        private static var _wildcard:ObjectType;
        public static function get wildcard():ObjectType
        {
            if(!_wildcard)
                _wildcard = new ObjectType();
            
            _wildcard._bits = 0xFFFFFFFF;
            
            return _wildcard;         
        }
        
        
        public static function registerFlag(flag:String, bitIndex:uint, namespace:String = "global"):void
        {
            var ns:ObjectTypeNamespace = getNamespace(namespace, true);
            if (!ns)
            {
                return;
            }
            
            ns.registerFlag(bitIndex, flag);
        }
    }
}