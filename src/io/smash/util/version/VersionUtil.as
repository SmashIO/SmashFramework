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
    import io.smash.util.TypeUtility;
    
    import flash.display.DisplayObject;
    import flash.system.Capabilities;
    import flash.utils.getDefinitionByName;
    
    use namespace mx_internal;
    
    /**
     * Utility class to determine the version of the Flex SDK we are compiled
     * against, and what runtime we are on. 
     */
    public class VersionUtil
    {
        public static function checkVersion(mainClass:DisplayObject):VersionDetails
        {
            var detail:VersionDetails = new VersionDetails();
            var testObj:*;
            var testClass:Object;
            
            detail.playerVersion = Capabilities.version + " " + (Capabilities.isDebugger ? "DEBUG" : "RELEASE");
            
            // Test for Spark AIR Application
            testObj = TypeUtility.instantiate("spark.components::WindowedApplication",true);
            if(testObj)
            {
                detail.type = VersionType.AIR;
                testClass = getDefinitionByName("spark.components::WindowedApplication");
                detail.flexVersion = new FlexSDKVersion(testClass.VERSION);
                return detail;
            }
            
            // Test for Halo AIR Application
            testObj = TypeUtility.instantiate("mx.core::WindowedApplication",true);
            if(testObj)
            {
                detail.type = VersionType.AIR;
                testClass = getDefinitionByName("mx.core::WindowedApplication");
                detail.flexVersion = new FlexSDKVersion(testClass.VERSION);
                return detail;
            }
            
            // Test for Flex Spark Application
            testObj = TypeUtility.instantiate("spark.components::Application",true);
            if(testObj)
            {
                detail.type = VersionType.FLEX;
                testClass = getDefinitionByName("spark.components::Application");
                detail.flexVersion = new FlexSDKVersion(testClass.VERSION);
                return detail;
            }
            
            // Test for Flex Halo Application
            testObj = TypeUtility.instantiate("mx.core::Application",true);
            if(testObj)
            {
                detail.type = VersionType.FLEX;
                testClass = getDefinitionByName("mx.core::Application");
                detail.flexVersion = new FlexSDKVersion(testClass.VERSION);
                return detail;
            }
            
            detail.type = VersionType.FLASH;
            
            return detail;
        }
    }
}