package io.smash.debug
{
    import io.smash.smash_internal;
    
    import flash.utils.Dictionary;
    
    use namespace smash_internal;
    
    public class ConsoleCommandManager
    {
        smash_internal var commands:Dictionary = new Dictionary();
        protected var commandList:Vector.<ConsoleCommand> = new Vector.<ConsoleCommand>();
        protected var commandListOrdered:Boolean = false;
        
        public function getCommandList():Vector.<ConsoleCommand>
        {
            ensureCommandsOrdered();
            return commandList;
        }
        
        /**
         * Register a command which the user can execute via the console.
         * 
         * <p>Arguments are parsed and cast to match the arguments in the user's
         * function. Command names must be alphanumeric plus underscore with no
         * spaces.</p>
         *  
         * @param name The name of the command as it will be typed by the user. No spaces.
         * @param callback The function that will be called. Can be anonymous.
         * @param docs A description of what the command does, its arguments, etc.
         * 
         */
        public function registerCommand(name:String, callback:Function, docs:String = null):void
        {
            // Sanity checks.
            if(callback == null)
                Logger.error(this, "registerCommand", "Command '" + name + "' has no callback!");
            
            if(!name || name.length == 0)
                Logger.error(this, "registerCommand", "Command has no name!");
            
            if(name.indexOf(" ") != -1)
                Logger.error(this, "registerCommand", "Command '" + name + "' has a space in it, it will not work.");
            
            // Fill in description.
            var c:ConsoleCommand = new ConsoleCommand();
            c.name = name;
            c.callback = callback;
            c.docs = docs;
            
            if(commands[name.toLowerCase()])
                Logger.warn(this, "registerCommand", "Replacing existing command '" + name + "'.");
            
            // Set it.
            commands[name.toLowerCase()] = c;
            
            // Update the list.
            commandList.push(c);
            commandListOrdered = false;
        }
        
        protected function ensureCommandsOrdered():void
        {
            // Avoid extra work.
            if(commandListOrdered == true)
                return;
            
            // Register default commands.
            if(commands.help == null)
                init();
            
            // Note we are done.
            commandListOrdered = true;
            
            // Do the sort.
            commandList.sort(function(a:ConsoleCommand, b:ConsoleCommand):int
            {
                if(a.name > b.name)
                    return 1;
                else
                    return -1;
            });
        }
        
        public function init():void
        {
            registerCommand("help", function(prefix:String = null):void
            {
                // Get commands in alphabetical order.
                ensureCommandsOrdered();
                
                if(prefix == null)
                {
                    Logger.print(Console, "Keyboard shortcuts: ");
                    Logger.print(Console, "[SHIFT]-TAB - Cycle through autocompleted commands.");
                    Logger.print(Console, "PGUP/PGDN   - Page log view up/down a page.");
                    Logger.print(Console, "");                    
                }
                
                // Display results.
                Logger.print(Console, "Commands:");
                for(var i:int=0; i<commandList.length; i++)
                {
                    var cc:ConsoleCommand = commandList[i] as ConsoleCommand;
                    
                    // Do prefix filtering.
                    if(prefix && prefix.length > 0 && cc.name.substr(0, prefix.length) != prefix)
                        continue;
                    
                    Logger.print(Console, "   " + cc.name + " - " + (cc.docs ? cc.docs : ""));
                }
                
                // List input options.
            }, "[prefix] - List known commands, optionally filtering by prefix.");
        }
    }
}