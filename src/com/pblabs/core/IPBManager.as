package com.pblabs.core
{
    /**
     * Optional interface for managers registered with a PBGroup. If this
     * interface is implemented, then the manager will receive lifecycle
     * callbacks so it can set itself up or tear itself down.
     */
    public interface IPBManager
    {
        /**
         * Called when the manager is register with the PBGroup.
         */
        function initialize():void;

        /**
         * Called when the manager is unregistered from the PBGroup or the
         * PBGroup is destroyed.
         */
        function destroy():void;
    }
}