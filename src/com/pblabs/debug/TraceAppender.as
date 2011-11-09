/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.debug
{
    
    /**
     * Simply dump log activity via trace(). 
     */
    public class TraceAppender implements ILogAppender
    {
        public function addLogMessage(level:String, loggerName:String, message:String):void
        {
            trace(level + ": " + loggerName + " - " + message);
        }
    }
}