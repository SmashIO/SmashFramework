package io.smash.core
{
    /**
     * Optional interface for managers registered with a SmashGroup. If this
     * interface is implemented, then the manager will receive lifecycle
     * callbacks so it can set itself up or tear itself down.
     */
    public interface ISmashManager
    {
        /**
         * Called when the manager is register with the SmashGroup.
         */
        function initialize():void;

        /**
         * Called when the manager is unregistered from the SmashGroup or the
         * SmashGroup is destroyed.
         */
        function destroy():void;
    }
}