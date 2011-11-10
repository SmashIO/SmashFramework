/*******************************************************************************
 * Smash Engine
 * Copyright (C) 2009 Smash Labs, LLC
 * For more information see http://www.Smashengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package io.smash.util.version
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
            return "Smash Engine - " + BuildVersion.BUILD_NUMBER +" - "
                + type + (flexVersion ? " ("+flexVersion+")" : "")
                + " - " + playerVersion
                + " - " + Security.sandboxType;	
        }
    }
}