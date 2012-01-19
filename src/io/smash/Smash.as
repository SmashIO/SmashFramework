package io.smash
{
    import io.smash.core.SmashGroup;
    
    import flash.display.Stage;

    /**
     * Helper class to track a few important bits of global state.
     */
    public class Smash
    {
        /**
         * Useful flag for disabling functionality in shipping builds. 
         */
        public static const IS_SHIPPING_BUILD:Boolean = false;
        
        /**
         * To facilitate debugging, any SmashGroup that you don't put in a group
         * is added here. The console lets you inspect this group with the tree
         * command. So, you can easily see the total object graph of your game
         * for debugging purposes. 
         */
        smash_internal static var _rootGroup:SmashGroup = new SmashGroup("_RootGroup");
    }
}