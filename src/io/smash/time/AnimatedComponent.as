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
    
    import io.smash.core.SEComponent;
    import io.smash.time.TimeManager;
    
    /**
     * Base class for components that need to perform actions every frame. This
     * needs to be subclassed to be useful.
     */
    public class AnimatedComponent extends SEComponent implements IAnimated
    {
        /**
         * The update priority for this component. Higher numbered priorities have
         * OnFrame called before lower priorities.
         */
        [EditorData(ignore="true")]
        public var updatePriority:Number = 0.0;
        
        private var _registerForUpdates:Boolean = true;
        private var _isRegisteredForUpdates:Boolean = false;
        
        [Inject]
        public var timeManager:TimeManager;
        
        /**
         * Set to register/unregister for frame updates.
         */
        [EditorData(ignore="true")]
        public function set registerForUpdates(value:Boolean):void
        {
            _registerForUpdates = value;
            
            if(_registerForUpdates && !_isRegisteredForUpdates)
            {
                // Need to register.
                _isRegisteredForUpdates = true;
                timeManager.addAnimatedObject(this, updatePriority);
            }
            else if(!_registerForUpdates && _isRegisteredForUpdates)
            {
                // Need to unregister.
                _isRegisteredForUpdates = false;
                timeManager.removeAnimatedObject(this);
            }
        }
        
        /**
         * @private
         */
        public function get registerForUpdates():Boolean
        {
            return _registerForUpdates;
        }
        
        /**
         * @inheritDoc
         */
        public function onFrame():void
        {
            applyBindings();
        }
        
        override protected function onAdd():void
        {
            super.onAdd();
            
            // This causes the component to be registerd if it isn't already.
            registerForUpdates = registerForUpdates;
        }
        
        override protected function onRemove():void
        {
            super.onRemove();
            
            // Make sure we are unregistered.
            registerForUpdates = false;
        }
    }
}