/*******************************************************************************
 * Smash Engine
 * Copyright (C) 2009 Smash Labs, LLC
 * For more information see http://www.Smashengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package io.smash.time
{
    /**
     * This interface should be implemented by objects that need to perform
     * actions every frame. This is most often things directly related to
     * rendering, such as advancing frames of a sprite animation. For performing
     * physics, processing AI, or other things of that nature, responding to
     * ticks would be more appropriate.
     * 
     * <p>Along with implementing this interface, the object needs to be added
     * to the ProcessManager via the AddAnimatedObject method.</p>
     * 
     * @see ProcessManager
     * @see ITickedObject
     */
    public interface IAnimated
    {
        /**
         * This method is called every frame by the ProcessManager on any objects
         * that have been added to it with the AddAnimatedObject method.
         * 
         * @param deltaTime The amount of time (in seconds) that has elapsed since
         * the last frame.
         * 
         * @see ProcessManager#AddAnimatedObject()
         */
        function onFrame():void;
    }
}