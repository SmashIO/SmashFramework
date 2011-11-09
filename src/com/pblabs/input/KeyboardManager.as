package com.pblabs.input
{
    import com.pblabs.core.IPBManager;
    import com.pblabs.time.ITicked;
    import com.pblabs.time.TimeManager;
    
    import flash.display.Stage;
    import flash.events.KeyboardEvent;
    
    public class KeyboardManager implements ITicked, IPBManager
    {
        [Inject]
        public var stage:Stage;
        
        [Inject]
        public var timeManager:TimeManager;
        
        protected var _keyState:Array = new Array();     // The most recent information on key states
        protected var _keyStateOld:Array = new Array();  // The state of the keys on the previous tick
        protected var _justPressed:Array = new Array();  // An array of keys that were just pressed within the last tick.
        protected var _justReleased:Array = new Array(); // An array of keys that were just released within the last tick.
        
        public function initialize():void
        {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            timeManager.addTickedObject(this, 10.0);
        }
        
        public function destroy():void
        {
            timeManager.removeTickedObject(this);
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        }
        
        protected function onKeyDown(ke:KeyboardEvent):void
        {
            _keyState[ke.keyCode] = true;
        }
        
        protected function onKeyUp(ke:KeyboardEvent):void
        {
            _keyState[ke.keyCode] = false;
        }
        
        public function onTick():void
        {
            for (var cnt:int = 0; cnt < _keyState.length; cnt++)
            {
                if (_keyState[cnt] && !_keyStateOld[cnt])
                    _justPressed[cnt] = true;
                else
                    _justPressed[cnt] = false;
                
                if (!_keyState[cnt] && _keyStateOld[cnt])
                    _justReleased[cnt] = true;
                else
                    _justReleased[cnt] = false;
                
                _keyStateOld[cnt] = _keyState[cnt];
            }
        }
        
        /**
         * Returns whether or not a key was pressed since the last tick.
         */
        public function wasKeyJustPressed(keyCode:int):Boolean
        {
            return _justPressed[keyCode];
        }
        
        /**
         * Returns whether or not a key was released since the last tick.
         */
        public function wasKeyJustReleased(keyCode:int):Boolean
        {
            return _justReleased[keyCode];
        }
        
        /**
         * Returns whether or not a specific key is down.
         */
        public function isKeyDown(keyCode:int):Boolean
        {
            return _keyState[keyCode];
        }
        
        /**
         * Returns true if any key is down.
         */
        public function isAnyKeyDown():Boolean
        {
            for each(var b:Boolean in _keyState)
            {
                if(b)
                {
                    return true;
                }
            }
            
            return false;
        }
    }
}