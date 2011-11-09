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
    import com.pblabs.core.PBComponent;
    import com.pblabs.time.TimeManager;
    
    /**
     * Base class for components which want to use think notifications.
     * 
     * <p>"Think notifications" allow a component to specify a time and
     * callback function which should be called back at that time. In this
     * way you can easily build complex behavior (by changing which callback
     * you pass) which is also efficient (because it is only called when 
     * needed, not every tick/frame). It is also light on the GC because
     * no allocations are required beyond the initial allocation of the
     * ThinkingComponent.</p>
     */
    public class QueuedComponent extends PBComponent implements IQueued
    {
        protected var _nextThinkTime:int;
        protected var _nextThinkCallback:Function;
        
        [Inject]
        public var timeManager:TimeManager;
        
        /**
         * Schedule the next time this component should think. 
         * @param nextCallback Function to be executed.
         * @param timeTillThink Time in ms from now at which to execute the function (approximately).
         */
        public function think(nextCallback:Function, timeTillThink:int):void
        {
            _nextThinkTime = timeManager.virtualTime + timeTillThink;
            _nextThinkCallback = nextCallback;
            
            timeManager.queueObject(this);
        }
        
        public function unthink():void
        {
            timeManager.dequeueObject(this);
        }
        
        override protected function onRemove() : void
        {
            super.onRemove();
            
            // Do not allow us to be called back if we are still
            // in the queue.
            _nextThinkCallback = null;
        }
        
        public function get nextThinkTime():Number
        {
            return _nextThinkTime;
        }
        
        public function get nextThinkCallback():Function
        {
            return _nextThinkCallback;
        }
        
        public function get priority():int
        {
            return -_nextThinkTime;
        }
        
        public function set priority(value:int):void
        {
            throw new Error("Unimplemented.");
        }
    }
}