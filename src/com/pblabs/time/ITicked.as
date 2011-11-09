/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.time
{
    /**
     * This interface should be implemented by objects that need to perform
     * actions every tick, such as moving, or processing collision. Performing
     * events every tick instead of every frame will give more consistent and
     * correct results. However, things related to rendering or animation should
     * happen every frame so the visual result appears smooth.
     * 
     * <p>Along with implementing this interface, the object needs to be added
     * to the ProcessManager via the addTickedObject method.</p>
     * 
     * @see TimeManager
     * @see IAnimated
     */
    public interface ITicked
    {
        /**
         * This method is called every tick by the TimeManager on any objects
         * that have been added to it with the addTickedObject method.
         * 
         * @see ProcessManager#AddTickedObject()
         */
        function onTick():void;
    }
}