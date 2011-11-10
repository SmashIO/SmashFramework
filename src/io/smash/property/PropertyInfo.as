/*******************************************************************************
 * Smash Engine
 * Copyright (C) 2009 Smash Labs, LLC
 * For more information see http://www.Smashengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package io.smash.property
{
    /**
     * Internal class used by Entity to service property lookups.
     */
    internal final class PropertyInfo
    {
        public var object:* = null;
        public var field:String = null;
        
        final public function getValue():*
        {
            try
            {
                if(field)
                    return object[field];
                else
                    return object;
            }
            catch(e:Error)
            {
                return null;
            }
        }
        
        final public function setValue(value:*):void
        {
            object[field] = value;
        }
        
        final public function clear():void
        {
            object = null;
            field = null;
        }
    }
}