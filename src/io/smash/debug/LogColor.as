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
    public class LogColor
    {
        public static const DEBUG:String        = "#AAAAAA";
        public static const INFO:String         = "#DDDDDD";
        public static const WARN:String         = "#BB6600";
        public static const ERROR:String        = "#BB4400";
        public static const MESSAGE:String      = "#DDDDDD";
        public static const CMD:String          = "#22AA22";
        
        public static function getColor(level:String):String
        {
            switch(level)
            {
                case LogEntry.DEBUG:
                    return DEBUG;
                case LogEntry.INFO:
                    return INFO;
                case LogEntry.WARNING:
                    return WARN;
                case LogEntry.ERROR:
                    return ERROR;
                case LogEntry.MESSAGE:
                    return MESSAGE;
                case LogEntry.CMD:
                    return CMD;
                default:
                    return MESSAGE;
            }
        }
    }
}