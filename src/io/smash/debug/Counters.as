package io.smash.debug
{
    import io.smash.util.sprintf;
    
    /**
     * A class for tracking the average of various counter values.
     * 
     * resetCounter must be called for a given counter before it is used
     * 
     */
    public class Counters
    {
        public static var sampleNames:Array = new Array();
        public static var criticalCounters:Array = new Array();
        public static var counters:Object = { };
        public static var criticalCounterColors:Object = { };
        
        /**
         * Initialize a counter and it's color if it is a 
         * critical counter.
         */        
        public static function initializeCounter(name:String,color:int = 0):void
        {
            sampleNames.push(name);
            counters[name] = 0;
            
            if (color > 0)
            {
                criticalCounters.push(name);
                criticalCounterColors[name] = color;                
            }
        }
        
        /**
         * Reset a counter back to 0
         */        
        public static function resetCounter(name:String):void
        {
            counters[name] = 0;
        }
        
        /**
         * Set a counter to the given number
         */
        public static function setCounter(name:String, amount:int):void
        {
            counters[name] = amount;
        } 
        
        /**
         * Increment a counter by the given amount.
         */
        public static function increment(name:String, amount:int=1):void
        {
            counters[name] += amount;
        } 
        
        /**
         * Decrement a counter by the given amount.
         */
        public static function decrement(name:String, amount:int=1):void
        {
            counters[name] -= amount;
        } 
        
        /**
         * Dump all the counters to the log.
         */
        public static function dumpCounters():void
        {
            // Sort keys
            sampleNames.sort();
            
            Logger.print(Counters,"Counter, value");
            for each (var key:String in sampleNames)
            {
                var msg:String = sprintf("%s, %d", key, counters[key]); 
                Logger.print(Counters,msg);
            }
        }
        
        /**
         * Return a multiline text string for all counters that can be displayed.
         */
        public static function getCounterText():String
        {
            var counterText:String = "";
            
            // Sort keys
            sampleNames.sort();
            
            for each (var key:String in sampleNames)
            {
                counterText += sprintf("%s: %d\n", key, counters[key]);                 
            }    
            
            return counterText;
        }       
        
        public static function getCriticalCounterColor(counterName:String):int
        {
            return criticalCounterColors[counterName];    
        }
        
        public static function getCriticalCounterSnapshot(obj:Object):void
        {
            for each (var key:String in criticalCounters)
            {
                obj[key] = counters[key];
            }            
        }
    }
}