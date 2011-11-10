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
    /**
     * Log entries are automatically created by the various methods on the Logger
     * class to store information related to an entry in the log. They are also
     * dispatched in the LogEvent when the entry is added to the log to pass
     * information about the entry to the listener.
     * 
     * @see Logger
     */
    public class LogEntry
    {
        /**
         * Entry type given to errors.
         * 
         * @see Logger#printError()
         */
        public static const ERROR:String = "ERROR";
        
        /**
         * Entry type given to warnings.
         * 
         * @see Logger#PrintWarning()
         */
        public static const WARNING:String = "WARNING";
        
        /**
         * Entry type given to debug messages.
         * 
         * @see Logger#PrintDebug()
         */
        public static const DEBUG:String = "DEBUG";
        
        /**
         * Entry type given to warnings.
         * 
         * @see Logger#PrintInfo()
         */
        public static const INFO:String = "INFO";
        
        /**
         * Entry type given to generic messages.
         * 
         * @see Logger#Print()
         */
        public static const MESSAGE:String = "MESSAGE";
        
        /**
         * Entry type given for echo of user commands. Internal use.
         * 
         * @see Logger#Print() 
         */
        public static const CMD:String = "CMD";
        
        /**
         * The object that printed the message to the log.
         */
        public var reporter:Class = null;
        
        /**
         * The method the entry was printed from.
         */
        public var method:String = "";
        
        /**
         * The message that was printed.
         */
        public var message:String = "";
        
        /**
         * The full message, formatted to include the reporter and method if they exist.
         */
        public function get formattedMessage():String
        {
            var deep:String = "";
            for (var i:int = 0; i < depth; i++)
                deep += "   ";
            
            var reporter:String = "";
            if (reporter)
                reporter = reporter + ": ";
            
            var method:String = "";
            if (method != null && method != "")
                method = method + " - ";
            
            return deep + reporter + method + message;
        }
        
        /**
         * The type of the message (message, warning, or error).
         * 
         * @see #ERROR
         * @see #WARNING
         * @see #MESSAGE
         */
        public var type:String = null;
        
        /**
         * The depth of the message.
         * 
         * @see Logger#Push()
         */
        public var depth:int = 0;
    }
}