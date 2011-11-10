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
    /**
     * Utility class to parse Flex SDK version strings.  
     */
    public class FlexSDKVersion
    {
        public var major:uint;
        public var minor:uint;
        public var update:uint;
        public var build:uint;
        
        protected var _versionString:String;
        
        public function FlexSDKVersion(versionString:String)
        {
            parseVersionString(versionString);
            _versionString = versionString;
        }
        
        protected function parseVersionString(value:String):void
        {
            var pieces:Array = value.split(".");
            
            major = parseInt(pieces[0]);
            minor = parseInt(pieces[1]);
            update = parseInt(pieces[2]);
            build = parseInt(pieces[3]);
        }
        
        public function toString():String
        {
            return _versionString;
        }
    }
}