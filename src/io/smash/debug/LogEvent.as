/*******************************************************************************
 * Smash Engine
 * Copyright (C) 2009 Smash Labs, LLC
 * For more information see http://www.Smashengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package io.smash.debug
{
    import io.smash.debug.LogEntry;
    
    import flash.events.Event;
    
    /**
     * A LogEvent is an event used by the Logger to dispatch log related information.
     */
    public class LogEvent extends Event
    {
        /**
         * The entry added event is dispatched by the Logger whenever a new
         * message is printed to the log.
         * 
         * @eventType ENTRY_ADDED_EVENT
         */
        public static const ENTRY_ADDED_EVENT:String = "ENTRY_ADDED_EVENT";
        
        /**
         * The LogEntry associated with this event.
         */
        public var entry:LogEntry = null;
        
        public function LogEvent(type:String, entry:LogEntry, bubbles:Boolean=false, cancelable:Boolean=false) 
        {
            entry = entry;
            super(type, bubbles, cancelable);
        }
    }
}