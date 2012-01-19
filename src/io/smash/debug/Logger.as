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
    
    import io.smash.Smash;
    import io.smash.smash_internal;
    import io.smash.util.TypeUtility;
    import io.smash.util.version.VersionDetails;
    import io.smash.util.version.VersionUtil;
    
    import flash.display.Stage;
    
    /**
     * The Logger class provides mechanisms to print and listen for errors, warnings,
     * and general messages. The built in 'trace' command will output messages to the
     * console, but this allows you to differentiate between different types of
     * messages, give more detailed information about the origin of the message, and
     * listen for log events so they can be displayed in a UI component.
     * 
     * You can use Logger for localized logging by instantiating an instance and
     * referencing it. For instance:
     * 
     * <code>protected static var logger:Logger = new Logger(MyClass);
     * logger.print("Output for MyClass.");</code>
     *  
     * @see LogEntry
     */
    public class Logger
    {
        static protected var listeners:Array = [];
        static protected var started:Boolean = false;
        static protected var pendingEntries:Array = [];
        static protected var disabled:Boolean = false;
        
        /**
         * Register a ILogAppender to be called back whenever log messages occur.
         */
        public static function registerListener(listener:ILogAppender):void
        {
            listeners.push(listener);
        }
        
        /**
         * Initialize the logging system.
         */
        public static function startup(stage:Stage):void
        {
            // Don't start more than once!
            if(started)
                return;
            
            // Put default listeners into the list.
            registerListener(new TraceAppender());
            
            // Process pending messages.
            started = true;
            
            // Print out a helpful version string.
            var vd:VersionDetails = VersionUtil.checkVersion(stage);
            Logger.print(Logger, vd.toString());
            Logger.print(Logger, new Date().toString());
            
            // Then print out any logging.
            if (pendingEntries) 
            {
                for(var i:int=0; i<pendingEntries.length; i++)
                    processEntry(pendingEntries[i]);
                
                // Free up the pending entries.
                pendingEntries.length = 0;
                pendingEntries = null;				
            }			
        }
        
        /**
         * Call to destructively disable logging. This is useful when going
         * to production, when you want to remove all logging overhead.
         */
        public static function disable():void
        {
            pendingEntries = null;
            started = false;
            listeners = null;
            disabled = true;
        }
        
        protected static function processEntry(entry:LogEntry):void
        {
            // Early out if we are disabled.
            if(disabled)
                return;
            
            // If we aren't started yet, just store it up for later processing.
            if(!started)
            {
                pendingEntries.push(entry);
                return;
            }
            
            // Let all the listeners process it.
            for(var i:int=0; i<listeners.length; i++)
                (listeners[i] as ILogAppender).addLogMessage(entry.type, TypeUtility.getObjectClassName(entry.reporter), entry.message);
        }
        
        /**
         * Prints a general message to the log. Log entries created with this method
         * will have the MESSAGE type.
         * 
         * @param reporter The object that reported the message. This can be null.
         * @param message The message to print to the log.
         */
        public static function print(reporter:*, message:String):void
        {
            // Early out if we are disabled.
            if(disabled)
                return;
            
            var entry:LogEntry = new LogEntry();
            entry.reporter = TypeUtility.getClass(reporter);
            entry.message = message;
            entry.type = LogEntry.MESSAGE;
            processEntry(entry);
        }
        
        /**
         * Prints an info message to the log. Log entries created with this method
         * will have the INFO type.
         * 
         * @param reporter The object that reported the warning. This can be null.
         * @param method The name of the method that the warning was reported from.
         * @param message The warning to print to the log.
         */
        public static function info(reporter:*, method:String, message:String):void
        {
            // Early out if we are disabled.
            if(disabled)
                return;
            
            var entry:LogEntry = new LogEntry();
            entry.reporter = TypeUtility.getClass(reporter);
            entry.method = method;
            entry.message = method + " - " + message;
            entry.type = LogEntry.INFO;
            processEntry(entry);
        }
        
        /**
         * Prints a debug message to the log. Log entries created with this method
         * will have the DEBUG type.
         * 
         * @param reporter The object that reported the debug message. This can be null.
         * @param method The name of the method that the debug message was reported from.
         * @param message The debug message to print to the log.
         */
        public static function debug(reporter:*, method:String, message:String):void
        {
            // Early out if we are disabled.
            if(disabled)
                return;
            
            var entry:LogEntry = new LogEntry();
            entry.reporter = TypeUtility.getClass(reporter);
            entry.method = method;
            entry.message = method + " - " + message;
            entry.type = LogEntry.DEBUG;
            processEntry(entry);
        }
        
        /**
         * Prints a warning message to the log. Log entries created with this method
         * will have the WARNING type.
         * 
         * @param reporter The object that reported the warning. This can be null.
         * @param method The name of the method that the warning was reported from.
         * @param message The warning to print to the log.
         */
        public static function warn(reporter:*, method:String, message:String):void
        {
            // Early out if we are disabled.
            if(disabled)
                return;
            
            var entry:LogEntry = new LogEntry();
            entry.reporter = TypeUtility.getClass(reporter);
            entry.method = method;
            entry.message = method + " - " + message;
            entry.type = LogEntry.WARNING;
            processEntry(entry);
        }
        
        /**
         * Prints an error message to the log. Log entries created with this method
         * will have the ERROR type.
         * 
         * @param reporter The object that reported the error. This can be null.
         * @param method The name of the method that the error was reported from.
         * @param message The error to print to the log.
         */
        public static function error(reporter:*, method:String, message:String):void
        {
            // Early out if we are disabled.
            if(disabled)
                return;
            
            var entry:LogEntry = new LogEntry();
            entry.reporter = TypeUtility.getClass(reporter);
            entry.method = method;
            entry.message = method + " - " + message;
            entry.type = LogEntry.ERROR;
            processEntry(entry);
        }
        
        /**
         * Prints a message to the log. Log enthries created with this method will have
         * the type specified in the 'type' parameter.
         * 
         * @param reporter The object that reported the message. This can be null.
         * @param method The name of the method that the error was reported from.
         * @param message The message to print to the log.
         * @param type The custom type to give the message.
         */
        public static function printCustom(reporter:*, method:String, message:String, type:String):void
        {
            // Early out if we are disabled.
            if(disabled)
                return;
            
            var entry:LogEntry = new LogEntry();
            entry.reporter = TypeUtility.getClass(reporter);
            entry.method = method;
            entry.message = method + " - " + message;
            entry.type = type;
            processEntry(entry);
        }
        
        /**
         * Utility function to get the current callstack. Only works in debug build.
         * Useful for noting who called what. Empty when in release build.
         */
        public static function getCallStack():String
        {
            try
            {
                var e:Error = new Error();
                return e.getStackTrace();
            }
            catch(e:Error)
            {
            }
            return "[no callstack available]";
        }
        
        public static function printHeader(report:*, message:String):void
        {
            print(report, message);
        }
        
        public static function printFooter(report:*, message:String):void
        {
            print(report, message);
        }
        
        public var enabled:Boolean;
        protected var owner:Class;
        
        public function Logger(_owner:Class, defaultEnabled:Boolean = true)
        {
            owner = _owner;
            enabled = defaultEnabled;
        }
        
        public function info(method:String, message:String):void
        {
            if(enabled)
                Logger.info(owner, method, message);
        }
        
        public function warn(method:String, message:String):void
        {
            if(enabled)
                Logger.warn(owner, method, message);
        }
        
        public function error(method:String, message:String):void
        {
            if(enabled)
                Logger.error(owner, method, message);
        }
        
        public function print(message:String):void
        {
            if(enabled)
                Logger.print(owner, message);
        }
        
    }
}