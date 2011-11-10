package io.smash.util
{
    import io.smash.debug.Logger;
    
    import flash.utils.Dictionary;
    
    internal final class ObjectTypeNamespace
    {
        public var name:String;
        
        /**
         * The number of object types that have been registered.
         */
        public var typeCount:uint = 0;
        public var typeList:Dictionary = new Dictionary();
        public var bitList:Array = new Array();	
        
        public function ObjectTypeNamespace(_name:String)
        {
            name = _name;
        }
        
        /**
         * Gets the number associated with a specified object type, registering it if
         * necessary.
         * 
         * @param typeName The name of the object type to retrieve.
         * 
         * @return The number associated with the specified type.
         */
        public function getType(typeName:String):uint
        {
            if (!typeList.hasOwnProperty(typeName))
            {
                if (typeCount == 64)
                {
                    Logger.warn(this, "GetObjectType", "Only 64 unique object types can be created.");
                    return 0;
                }
                
                typeList[typeName] = typeCount;
                bitList[1 << typeCount] = typeName;
                typeCount++;
            }
            
            return 1 << typeList[typeName];
        }
        
        /**
         * Gets the name of an object type based on the number it was assigned.
         * 
         * @param number The number of the type to find.
         * 
         * @return The name of the type with the specified number, or null if 
         * the number is not assigned to any type.
         */
        public function getTypeName(number:uint):String
        {
            return bitList[number];
        }
        
        /**
         * Forcibly register a specific flag. Throws an error if you overwrite an
         * existing flag.
         */
        public function registerFlag(bitIndex:int, name:String):void
        {
            // Sanity.
            if(getTypeName(bitIndex) != null) 
                throw new Error("Bit already in use!");
            if(typeList[name])
                throw new Error("Name already assigned to another bit!");
            
            // Update typeCount so subsequent updates still work. This may
            // cause wasted bits.
            if(bitIndex >= typeCount)
                typeCount = bitIndex + 1;
            
            // And stuff into our arrays.
            typeList[name] = bitIndex;
            bitList[bitIndex] = name;
        }
    }
}