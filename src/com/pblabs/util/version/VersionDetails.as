/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.util.version
{
    import flash.system.Security;
    
    /**
     * Utility class to store version information. 
     */
    public class VersionDetails
    {
        public var type:String;
        public var flexVersion:FlexSDKVersion;
        public var playerVersion:String = "unknown";
        
        public function toString():String
        {
            return "PushButton Engine - " + BuildVersion.BUILD_NUMBER +" - "
                + type + (flexVersion ? " ("+flexVersion+")" : "")
                + " - " + playerVersion
                + " - " + Security.sandboxType;	
        }
    }
}