/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.time
{
    import com.pblabs.util.IPrioritizable;
    
    /**
     * Helper class for internal use by ProcessManager. This is used to 
     * track scheduled callbacks from schedule().
     */
    internal final class ScheduleEntry implements IPrioritizable
    {
        public var dueTime:Number = 0.0;
        public var thisObject:Object = null;
        public var callback:Function = null;
        public var arguments:Array = null;
        
        public function get priority():int
        {
            return -dueTime;
        }
        
        public function set priority(value:int):void
        {
            throw new Error("Unimplemented.");
        }
    }
}