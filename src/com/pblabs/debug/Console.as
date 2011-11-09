/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.debug
{
    import com.pblabs.PBE;
    import com.pblabs.PBUtil;
    import com.pblabs.core.IPBManager;
    import com.pblabs.core.PBComponent;
    import com.pblabs.core.PBGameObject;
    import com.pblabs.core.PBGroup;
    import com.pblabs.core.PBObject;
    import com.pblabs.core.PBSet;
    import com.pblabs.debug.ConsoleCommandManager;
    import com.pblabs.debug.ILogAppender;
    import com.pblabs.debug.LogColor;
    import com.pblabs.debug.Logger;
    import com.pblabs.debug.Profiler;
    import com.pblabs.input.KeyboardKey;
    import com.pblabs.input.KeyboardManager;
    import com.pblabs.pb_internal;
    import com.pblabs.time.IAnimated;
    import com.pblabs.time.ITicked;
    import com.pblabs.time.TimeManager;
    import com.pblabs.util.TypeUtility;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.system.Security;
    import flash.system.System;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.ui.Keyboard;
    import flash.utils.getDefinitionByName;
    
    use namespace pb_internal;
    
    /**
     * UI to display Logger output and process simple commands from the user.
     * Commands are registered via ConsoleCommandManager.
     */ 
    public class Console extends Sprite implements ILogAppender, ITicked, IPBManager
    {
        protected var _messageQueue:Array = [];
        protected var _maxLength:uint = 200000;
        protected var _truncating:Boolean = false;
        protected var logCache:Array = [];
        protected var _dirtyConsole:Boolean = true;
        
        protected var _width:uint = 500;
        protected var _height:uint = 150;
        
        protected var _consoleHistory:Array = [];
        protected var _historyIndex:uint = 0;
        
        protected var glyphCache:GlyphCache = new GlyphCache();
        protected var _outputBitmap:Bitmap;
        protected var _input:TextField;
        protected var bottomLineIndex:int = int.MAX_VALUE;
        
        protected var tabCompletionPrefix:String = "";
        protected var tabCompletionCurrentStart:int = 0;
        protected var tabCompletionCurrentEnd:int = 0;
        protected var tabCompletionCurrentOffset:int = 0;
        
        protected var _currentGroup:PBGroup = PBE._rootGroup;
        protected var _currentCommandManager:ConsoleCommandManager = null;
        
        protected var keyBindings:Vector.<KeyBindingEntry> = new Vector.<KeyBindingEntry>();
        
        public var verbosity:int = 0;
        public var showStackTrace:Boolean = true;
        
        [Inject]
        public var keyboardManager:KeyboardManager= null;
        
        [Inject]
        public var timeManager:TimeManager = null;
        
        [Inject]
        public var owningStage:Stage = null;
        
        public function Console():void
        {
            name = "Console";
            
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
            
            registerKeyBinding("tilde", null, "toggleConsole"); 
            registerKeyBinding("p", "profilerOn", "profilerOff"); 
        }
        
        public function initialize():void
        {
            Logger.registerListener(this);
            Logger.startup(owningStage);
            
            timeManager.addTickedObject(this);
            
            _currentGroup = PBE._rootGroup;
            
            // Set up the default console command manager.
            _currentCommandManager = new ConsoleCommandManager();
            _currentGroup.registerManager(ConsoleCommandManager, _currentCommandManager);
            
            // Set up FPS display.
            _fps = new Stats();
            _fps.timeManager = timeManager;
            
            // Set up some handy helper commands.
            _currentCommandManager.init();
            _currentCommandManager.registerCommand("toggleConsole", toggleConsole, "Hide or show the console.");
            _currentCommandManager.registerCommand("cd", changeDirectory, ".. to go up to parent, otherwise index or name to change to subgroup.");
            _currentCommandManager.registerCommand("ls", listDirectory, "Show the PBGroups in the current PBGroup.");
            _currentCommandManager.registerCommand("tree", tree, "Dump all objects in current group or below.");
            _currentCommandManager.registerCommand("fps", showFps, "Toggle FPS/Memory display.");
            _currentCommandManager.registerCommand("profilerOn", profilerOn, "Turn profiler on.");
            _currentCommandManager.registerCommand("profilerOff", profilerOff, "Turn profiler off and dump results.");
        }
        
        public function destroy():void
        {
            timeManager.removeTickedObject(this);
        }
        
        protected var _fps:Stats;
        protected function showFps():void
        {
            if(_fps.parent)
                _fps.parent.removeChild(_fps);
            else
                stage.addChild(_fps);
        }
        
        protected function profilerOn():void
        {
            Profiler.enabled = true;
        }
        
        protected function profilerOff():void
        {
            Profiler.enabled = false;
            Profiler.report();
            Profiler.wipe();
        }
        
        public function tree():void
        {
            var count:int = _listPBObjects(_currentGroup, 0);
            Logger.print(this, "Found " + count + " PBObjects.");
        }
        
        protected function _listPBObjects(current:PBObject, indent:int):int
        {
            if (!current)
                return 0;
            
            var type:String = " ("+ TypeUtility.getObjectClassName(current) +")";
            if(current.name)
            {
                Logger.print(this, Console.generateIndent(indent) + current.name + type);
            }
            else
            {
                Logger.print(this, Console.generateIndent(indent) + "[anonymous]" + type);                
            }
            
            // Recurse if it's a known type.
            var parentSet:PBSet = current as PBSet;
            var parentGroup:PBGroup = current as PBGroup;
            var parentEntity:PBGameObject = current as PBGameObject;
            
            var sum:int = 1;
            var i:int = 0;
            
            if(parentSet)
            {
                for(i=0; i<parentSet.length; i++)
                    sum += _listPBObjects(parentSet.getPBObjectAt(i), indent+1);
            }
            else if(parentGroup)
            {
                for(i=0; i<parentGroup.length; i++)
                    sum += _listPBObjects(parentGroup.getPBObjectAt(i), indent+1);
            }
            else if(parentEntity)
            {
                // Get all the components. Components don't count for the sum.
                var c:Vector.<PBComponent> = parentEntity.getAllComponents();
                for(i=0; i<c.length; i++)
                {
                    var iec:PBComponent = c[i] as PBComponent;
                    type = " ("+ TypeUtility.getObjectClassName(iec) +")";
                    Logger.print(this, Console.generateIndent(indent + 1) + iec.name + type);
                }
            }
            
            return sum;
        }
        
        protected static function generateIndent(indent:int):String
        {
            var str:String = "";
            for(var i:int=0; i<indent; i++)
            {
                // Add 2 spaces for indent
                str += "  ";
            }
            
            return str;
        }        
        
        public function listDirectory():void
        {
            for(var i:int=0; i<_currentGroup.length; i++)
            {
                var potentialGroup:PBGroup = _currentGroup.getPBObjectAt(i) as PBGroup;
                if(potentialGroup == null)
                    continue;
                
                Logger.print(this, "#" + i + ". " + TypeUtility.getClass(_currentGroup) + " name = " + _currentGroup.name);
            }            
        }
        
        public function changeDirectory(dir:String = null):void
        {
            if(dir == null)
            {
                Logger.print(this, "Returning to root.");
                _currentGroup = PBE._rootGroup;
                return;
            }
            
            dir = dir.toLocaleLowerCase();
            
            if(dir == "..")
            {
                if(_currentGroup.owningGroup)
                {
                    Logger.print(this, "Going to parent group.");
                    _currentGroup = _currentGroup.owningGroup;
                }
                else
                {
                    Logger.print(this, "Already at root.");
                }
            }
            else
            {
                // Is a child group named as specified?
                
                // Look for exact name.
                for(var i:int=0; i<_currentGroup.length; i++)
                {
                    var potentialGroup:PBGroup = _currentGroup.getPBObjectAt(i) as PBGroup;
                    if(potentialGroup == null)
                        continue;
                    
                    if(!potentialGroup.name || potentialGroup.name.toLocaleLowerCase() != dir)
                        continue;
                    
                    _currentGroup = potentialGroup;
                    Logger.print(this, "Changed to " + _currentGroup);
                    return;
                }
                
                // Look for a class name match.
                for(i=0; i<_currentGroup.length; i++)
                {
                    potentialGroup = _currentGroup.getPBObjectAt(i) as PBGroup;
                    if(potentialGroup == null)
                        continue;
                    
                    if(TypeUtility.getClass(potentialGroup).toString().toLocaleLowerCase() != dir)
                        continue;
                    
                    _currentGroup = potentialGroup;
                    Logger.print(this, "Changed to " + _currentGroup);
                    return;
                }
                
                // Try numerical lookup.
                var dirAsNumber:int = parseInt(dir);
                if(dirAsNumber >= 0 && dirAsNumber < _currentGroup.length)
                {
                    _currentGroup = _currentGroup.getPBObjectAt(dirAsNumber) as PBGroup;
                    if(_currentGroup)
                    {
                        Logger.print(this, "Changed to " + _currentGroup);
                        return;                        
                    }
                }
                
                Logger.warn(this, "cd", "Could not find a group called '" + dir + "'");
            }
        }
        
        public function toggleConsole():void
        {
            if(stage)
            {
                stage.removeChild(this);
                deactivate();
            }
            else
            {
                owningStage.addChild(this);
                activate();
            }
        }
        
        protected function onAddedToStage(e:Event):void
        {
            _outputBitmap = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x0));
            
            layout();
            addListeners();
        }
        
        protected function onRemovedFromStage(e:Event):void
        {
        }
        public function registerKeyBinding(keyName:String, downCommand:String, upCommand:String):void
        {
            // Parse the key.
            var key:KeyboardKey = KeyboardKey.stringToKey(keyName);
            if(key == null || key == KeyboardKey.INVALID)
                throw new Error("Couldn't identify key '" + key + "'!");
            
            const kbe:KeyBindingEntry = new KeyBindingEntry();
            kbe.key = key;
            kbe.downCommand = downCommand;
            kbe.upCommand = upCommand;
            
            keyBindings.push(kbe);
        }
        
        /**
         * Take a line of console input and process it, executing any command.
         * @param line String to parse for command.
         */
        public function processLine(line:String):void
        {
            if(!_currentCommandManager)
            {
                Logger.warn(this, "processLine", "No active ConsoleCommandManager, cannot process command '" + line + "'");
                return;
            }
            
            // Match Tokens, this allows for text to be split by spaces excluding spaces between quotes.
            // TODO Allow escaping of quotes
            var pattern:RegExp = /[^\s"']+|"[^"]*"|'[^']*'/g;
            var args:Array = [];
            var test:Object = {};
            while (test)
            {
                test = pattern.exec(line);
                if(test)
                {
                    var str:String = test[0];
                    str = PBUtil.trim(str, "'");
                    str = PBUtil.trim(str, "\"");
                    args.push(str);	// If no more matches can be found, test will be null	
                }
            }
            
            // Look up the command.
            if(args.length == 0)
                return;
            var potentialCommand:ConsoleCommand = _currentCommandManager.commands[args[0].toString().toLowerCase()]; 
            
            if(!potentialCommand)
            {
                Logger.warn(Console, "processLine", "No such command '" + args[0].toString() + "'!");
                return;
            }
            
            // Now call the command.
            try
            {
                potentialCommand.callback.apply(null, args.slice(1));                
            }
            catch(e:Error)
            {
                if(e is ArgumentError)
                {
                    Logger.error(this, args[0], "Argument count mismatch.");
                    return;
                }
                
                var errorStr:String = "Error: " + e.toString();
                if(showStackTrace)
                {
                    errorStr += " - " + e.getStackTrace();
                }
                Logger.error(this, args[0], errorStr);
            }
        }
        
        protected function layout():void
        {
            if (!_input)
                createInputField();
            
            resize();
            
            _outputBitmap.name = "ConsoleOutput";
            addEventListener(MouseEvent.CLICK, onBitmapClick);
            addEventListener(MouseEvent.DOUBLE_CLICK, onBitmapDoubleClick);
            
            addChild(_outputBitmap);
            addChild(_input);
            
            graphics.clear();
            graphics.beginFill(0x111111, .95);
            graphics.drawRect(0, 0, _width + 1, _height);
            graphics.endFill();
            
            // Necessary for click listeners.
            mouseEnabled = true;
            doubleClickEnabled = true;
            
            _dirtyConsole = true;
        }
        
        protected function addListeners():void
        {
            _input.addEventListener(KeyboardEvent.KEY_DOWN, onInputKeyDown, false, 1, true);
        }
        
        protected function removeListeners():void
        {
            _input.removeEventListener(KeyboardEvent.KEY_DOWN, onInputKeyDown);
        }
        
        protected function onBitmapClick(me:MouseEvent):void
        {
            // Give focus to input.
            if(stage)
                stage.focus = _input;
        }
        
        protected function onBitmapDoubleClick(me:MouseEvent = null):void
        {
            // Put everything into a monster string.
            var logString:String = "";
            for (var i:int = 0; i < logCache.length; i++)
                logString += logCache[i].text + "\n";
            
            // Copy content.
            System.setClipboard(logString);
            
            Logger.print(this, "Copied console contents to clipboard.");
        }
        
        /**
         * Wipe the displayed console output.
         */
        protected function onClearCommand():void
        {
            logCache = [];
            bottomLineIndex = -1;
            _dirtyConsole = true;
        }
        
        protected function resize():void
        {
            _outputBitmap.x = 5;
            _outputBitmap.y = 0;
            _input.x = 5;
            
            if (stage)
            {
                _width = stage.stageWidth - 1;
                _height = (stage.stageHeight / 3) * 2;
            }
            
            // Resize display surface.
            Profiler.enter("LogViewer_resizeBitmap");
            _outputBitmap.bitmapData.dispose();
            _outputBitmap.bitmapData = new BitmapData(_width - 10, _height - 30, false, 0x0);
            Profiler.exit("LogViewer_resizeBitmap");
            
            _input.height = 18;
            _input.width = _width - 10;
            
            _input.y = _outputBitmap.height + 7;
            
            _dirtyConsole = true;
        }
        
        protected function createInputField():TextField
        {
            _input = new TextField();
            _input.type = TextFieldType.INPUT;
            _input.border = true;
            _input.borderColor = 0xCCCCCC;
            _input.multiline = false;
            _input.wordWrap = false;
            _input.condenseWhite = false;
            var format:TextFormat = _input.getTextFormat();
            format.font = "_typewriter";
            format.size = 11;
            format.color = 0xFFFFFF;
            _input.setTextFormat(format);
            _input.defaultTextFormat = format;
            _input.restrict = "^`"; // Tilde's are not allowed in the input since they close the window
            _input.name = "ConsoleInput";
            
            return _input;
        }
        
        protected function setHistory(old:String):void
        {
            _input.text = old;
            timeManager.callLater(function():void
            {
                _input.setSelection(_input.length, _input.length);
            });
        }
        
        protected function onInputKeyDown(event:KeyboardEvent):void
        {
            // If this was a non-tab input, clear tab completion state.
            if (event.keyCode != Keyboard.TAB && event.keyCode != Keyboard.SHIFT)
            {
                tabCompletionPrefix = _input.text;
                tabCompletionCurrentStart = -1;
                tabCompletionCurrentOffset = 0;
            }
            
            if (event.keyCode == Keyboard.ENTER)
            {
                // Execute an entered command.
                if (_input.text.length <= 0)
                {
                    // display a blank line
                    addLogMessage("CMD", ">", _input.text);
                    return;
                }
                
                // If Enter was pressed, process the command
                processCommand();
            }
            else if (event.keyCode == Keyboard.UP)
            {
                // Go to previous command.
                if (_historyIndex > 0)
                {
                    setHistory(_consoleHistory[--_historyIndex]);
                }
                else if (_consoleHistory.length > 0)
                {
                    setHistory(_consoleHistory[0]);
                }
                
                event.preventDefault();
            }
            else if (event.keyCode == Keyboard.DOWN)
            {
                // Go to next command.
                if (_historyIndex < _consoleHistory.length - 1)
                {
                    setHistory(_consoleHistory[++_historyIndex]);
                }
                else if (_historyIndex == _consoleHistory.length - 1)
                {
                    _input.text = "";
                }
                
                event.preventDefault();
            }
            else if (event.keyCode == Keyboard.PAGE_UP)
            {
                // Page the console view up.
                if (bottomLineIndex == int.MAX_VALUE)
                    bottomLineIndex = logCache.length - 1;
                
                bottomLineIndex -= getScreenHeightInLines() - 2;
                
                if (bottomLineIndex < 0)
                    bottomLineIndex = 0;
            }
            else if (event.keyCode == Keyboard.PAGE_DOWN)
            {
                // Page the console view down.
                if (bottomLineIndex != int.MAX_VALUE)
                {
                    bottomLineIndex += getScreenHeightInLines() - 2;
                    
                    if (bottomLineIndex + getScreenHeightInLines() >= logCache.length)
                        bottomLineIndex = int.MAX_VALUE;
                }
            }
            else if (event.keyCode == Keyboard.TAB)
            {
                // We are doing tab searching.
                var list:Vector.<ConsoleCommand> = _currentCommandManager.getCommandList();
                
                // Is this the first step?
                var isFirst:Boolean = false;
                if (tabCompletionCurrentStart == -1)
                {
                    tabCompletionPrefix = _input.text.toLowerCase();
                    tabCompletionCurrentStart = int.MAX_VALUE;
                    tabCompletionCurrentEnd = -1;
                    
                    for (var i:int = 0; i < list.length; i++)
                    {
                        // If we found a prefix match...
                        const potentialPrefix:String = list[i].name.substr(0, tabCompletionPrefix.length); 
                        if (potentialPrefix.toLowerCase() != tabCompletionPrefix)
                            continue;
                        
                        // Note it.
                        if (i < tabCompletionCurrentStart)
                            tabCompletionCurrentStart = i;
                        if (i > tabCompletionCurrentEnd)
                            tabCompletionCurrentEnd = i;
                        
                        isFirst = true;
                    }
                    
                    tabCompletionCurrentOffset = tabCompletionCurrentStart;
                }
                
                // If there is a match, tab complete.
                if (tabCompletionCurrentEnd != -1)
                {
                    // Update offset if appropriate.
                    if (!isFirst)
                    {
                        if (event.shiftKey)
                            tabCompletionCurrentOffset--;
                        else
                            tabCompletionCurrentOffset++;
                        
                        // Wrap the offset.
                        if (tabCompletionCurrentOffset < tabCompletionCurrentStart)
                        {
                            tabCompletionCurrentOffset = tabCompletionCurrentEnd;
                        }
                        else if (tabCompletionCurrentOffset > tabCompletionCurrentEnd)
                        {
                            tabCompletionCurrentOffset = tabCompletionCurrentStart;
                        }
                    }
                    
                    // Get the match.
                    var potentialMatch:String = list[tabCompletionCurrentOffset].name;
                    
                    // Update the text with the current completion, caret at the end.
                    _input.text = potentialMatch;
                    _input.setSelection(potentialMatch.length + 1, potentialMatch.length + 1);
                }
                
                // Make sure we keep focus. TODO: This is not ideal, it still flickers the yellow box.
                var oldfr:* = stage.stageFocusRect;
                stage.stageFocusRect = false;
                timeManager.callLater(function():void
                {
                    stage.focus = _input;
                    stage.stageFocusRect = oldfr;
                });
            }
            else if (event.keyCode == KeyboardKey.TILDE.keyCode)
            {
                // Hide the console window, have to check here due to 
                // propagation stop at end of function.
                parent.removeChild(this);
                deactivate();
            }
            
            _dirtyConsole = true;
            
            // Keep console input from propagating up to the stage and messing up the game.
            event.stopImmediatePropagation();
        }
        
        protected function processCommand():void
        {
            addLogMessage("CMD", ">", _input.text);
            processLine(_input.text);
            _consoleHistory.push(_input.text);
            _historyIndex = _consoleHistory.length;
            _input.text = "";
            
            _dirtyConsole = true;
        }
        
        public function getScreenHeightInLines():int
        {
            var roundedHeight:int = _outputBitmap.bitmapData.height;
            return Math.floor(roundedHeight / glyphCache.getLineHeight());
        }
        
        public function onTick():void
        {
            // Check the keybindings.
            for(var i:int=0; i<keyBindings.length; i++)
            {
                const kbe:KeyBindingEntry = keyBindings[i];
                if(keyboardManager.wasKeyJustPressed(kbe.key.keyCode) && kbe.isDown == false)
                {
                    if(kbe.downCommand)
                        processLine(kbe.downCommand);
                    kbe.isDown = true;
                }
                else if(keyboardManager.wasKeyJustReleased(kbe.key.keyCode) && kbe.isDown == true)
                {
                    if(kbe.upCommand)
                        processLine(kbe.upCommand);
                    kbe.isDown = false;
                }
            }
            
            // Don't draw if we are clean or invisible.
            if (_dirtyConsole == false || parent == null)
                return;
            _dirtyConsole = false;
            
            Profiler.enter("LogViewer.redrawLog");
            
            // Figure our visible range.
            var lineHeight:int = getScreenHeightInLines() - 1;
            var startLine:int = 0;
            var endLine:int = 0;
            if (bottomLineIndex == int.MAX_VALUE)
                startLine = PBUtil.clamp(logCache.length - lineHeight, 0, int.MAX_VALUE);
            else
                startLine = PBUtil.clamp(bottomLineIndex - lineHeight, 0, int.MAX_VALUE);
            
            endLine = PBUtil.clamp(startLine + lineHeight, 0, logCache.length - 1);
            
            startLine--;
            
            // Wipe it.
            var bd:BitmapData = _outputBitmap.bitmapData;
            bd.fillRect(bd.rect, 0x0);
            
            // Draw lines.
            for (i = endLine; i >= startLine; i--)
            {
                // Skip empty.
                if (!logCache[i])
                    continue;
                
                glyphCache.drawLineToBitmap(logCache[i].text, 0, 
                    _outputBitmap.height - (endLine + 1 - i) * glyphCache.getLineHeight() - 6, 
                    logCache[i].color, _outputBitmap.bitmapData);
            }
            
            Profiler.exit("LogViewer.redrawLog");
        }
        
        public function addLogMessage(level:String, loggerName:String, message:String):void
        {
            var color:String = LogColor.getColor(level);
            
            // Cut down on the logger level if verbosity requests.
            if (verbosity < 2)
            {
                var dotIdx:int = loggerName.lastIndexOf("::");
                if (dotIdx != -1)
                    loggerName = loggerName.substr(dotIdx + 2);
            }
            
            // Split message by newline and add to the list.
            var messages:Array = message.split("\n");
            for each (var msg:String in messages)
            {
                var text:String = ((verbosity > 0) ? level + ": " : "") + loggerName + " - " + msg;
                logCache.push({ "color": parseInt(color.substr(1), 16), "text": text });
            }
            
            _dirtyConsole = true;
        }
        
        public function activate():void
        {
            layout();
            _input.text = "";
            addListeners();
            
            timeManager.callLater(function():void
            {
                owningStage.focus = _input;                
            });
        }
        
        public function deactivate():void
        {
            removeListeners();
            
            owningStage.focus = owningStage;
        }
        
        public function set restrict(value:String):void
        {
            _input.restrict = value;
        }
        
        public function get restrict():String
        {
            return _input.restrict;
        }
    }
}

import com.pblabs.input.KeyboardKey;

class KeyBindingEntry
{
    public var key:KeyboardKey;
    public var isDown:Boolean;
    public var downCommand:String;
    public var upCommand:String;
}