/**
 * Hi-ReS! Stats
 *
 * Released under MIT license:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * How to use:
 *
 *      addChild( new Stats() );
 *
 * version log:
 *
 *      08.12.14                1.4             Mr.doob                 + Code optimisations and version info on MOUSE_OVER
 *      08.07.12                1.3             Mr.doob                 + Some speed and code optimisations
 *      08.02.15                1.2             Mr.doob                 + Class renamed to Stats (previously FPS)
 *      08.01.05                1.2             Mr.doob                 + Click changes the fps of flash (half up increases,
 *                                                                                        half down decreases)
 *      08.01.04                1.1             Mr.doob and Theo        + Log shape for MEM
 *                                                                      + More room for MS
 *                                                                      + Shameless ripoff of Alternativa's FPS look :P
 *      07.12.13                1.0             Mr.doob                 + First version
 **/

package io.smash.debug
{
    import io.smash.time.TimeManager;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Rectangle;
    import flash.system.Capabilities;
    import flash.system.System;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.getTimer;
    
    public class Stats extends Sprite
    {
        public function Stats()
        {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        public var timeManager:TimeManager;
        
        private var timer:int, ms:int, msPrev:int = 0;
        
        private var fpsText:TextField, msText:TextField, memText:TextField, verText:TextField, format:TextFormat;
        
        private var graph:BitmapData;
        
        private var mem:Number = 0;
        
        private var rectangle:Rectangle;
        
        private var ver:Sprite;
        
        private var counterText:TextField;
        private var counters:Sprite;
        private var criticalCounterLastValues:Object = new Object();        
        private var criticalCounterCurrentValues:Object = new Object();        
        
        private function onAddedToStage(e:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
            
            graphics.beginFill(0x33);
            graphics.drawRect(0, 0, 65, 40);
            graphics.endFill();
            
            ver = new Sprite();
            ver.graphics.beginFill(0x33);
            ver.graphics.drawRect(0, 0, 65, 30);
            ver.graphics.endFill();
            ver.y = 90;
            ver.visible = false;
            addChild(ver);
            
            counters = new Sprite();
            counters.graphics.beginFill(0x33);
            counters.graphics.drawRect(0, 0, 400, 300);
            counters.graphics.endFill();
            counters.y = 110;
            counters.visible = false;
            addChild(counters);
            
            verText = new TextField();
            fpsText = new TextField();
            msText = new TextField();
            memText = new TextField();
            counterText = new TextField();
            
            format = new TextFormat("_sans", 9);
            
            verText.defaultTextFormat = fpsText.defaultTextFormat = msText.defaultTextFormat = memText.defaultTextFormat = format;
            verText.width = fpsText.width = msText.width = memText.width = 65;
            verText.selectable = fpsText.selectable = msText.selectable = memText.selectable = false;
            
            verText.textColor = 0xFFFFFF;
            verText.text = Capabilities.version.split(" ")[0] + "\n" + Capabilities.version.split(" ")[1];
            ver.addChild(verText);
            
            counterText.defaultTextFormat = format;
            counterText.width = 400;
            counterText.height = 300;
            counterText.selectable = fpsText.selectable = msText.selectable = memText.selectable = false;
            
            counterText.textColor = 0xFFFFFF;
            counterText.text = "";
            counters.addChild(counterText);
            
            fpsText.textColor = 0xFFFF00;
            fpsText.text = "FPS: ";
            addChild(fpsText);
            
            msText.y = 10;
            msText.textColor = 0x00FF00;
            msText.text = "MS: ";
            addChild(msText);
            
            memText.y = 20;
            memText.textColor = 0x00FFFF;
            memText.text = "MEM: ";
            addChild(memText);
            
            graph = new BitmapData(65, 50, false, 0x33);
            var gBitmap:Bitmap = new Bitmap(graph);
            gBitmap.y = 40;
            addChild(gBitmap);
            
            rectangle = new Rectangle(0, 0, 1, graph.height);
            
            addEventListener(MouseEvent.CLICK, onClick);
            addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            timeManager.timer.addEventListener(TimerEvent.TIMER, update);
            
            fpsTimes.length = 15;
            
            stage.invalidate();
        }
        
        private function onRemovedFromStage(event:Event):void
        {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            
            removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
            removeEventListener(MouseEvent.CLICK, onClick);
            removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            timeManager.timer.removeEventListener(TimerEvent.TIMER, update);	
        }
        
        private function onClick(event:MouseEvent):void
        {
            (this.mouseY > this.height * .35) ? stage.frameRate-- : stage.frameRate++;
            fpsText.text = "FPS: X / " + stage.frameRate;
            stage.invalidate();
        }
        
        private function onMouseOut(event:MouseEvent):void
        {
            ver.visible = false;
            counters.visible = false;
            stage.invalidate();
        }
        
        private function onMouseOver(event:MouseEvent):void
        {
            ver.visible = true;
            counters.visible = true;
            stage.invalidate();
        }
        
        public var fpsTimes:Vector.<Number> = new Vector.<Number>();
        public var fpsTimesIndex:int = 0;
        
        private function update(e:Event):void
        {
            timer = getTimer();
            
            const frameTime:Number = (timer - ms);
            const stageFps:Number = stage ? stage.frameRate : 0;
            fpsTimesIndex = (fpsTimesIndex + 1) % 15;
            fpsTimes[fpsTimesIndex] = frameTime;
            const avgTime:Number = (fpsTimes[0] + fpsTimes[1] + fpsTimes[2] + fpsTimes[3] + fpsTimes[4] 
                + fpsTimes[5] + fpsTimes[6] + fpsTimes[7] + fpsTimes[8] + fpsTimes[9] 
                + fpsTimes[10] + fpsTimes[11] + fpsTimes[12] + fpsTimes[13] + fpsTimes[14]) / 15.0;
            
            msPrev = timer;
            mem = Number((System.totalMemory * 0.000000954).toFixed(3));
            
            var fpsGraph:int = Math.min(50, 50 / stageFps * avgTime);
            var memGraph:Number = Math.min(50, Math.sqrt(Math.sqrt(mem * 5000))) - 2;
            
            graph.scroll(1, 0);
            
            graph.fillRect(rectangle, 0x33);
            
            // Do a vertical line if the time was over 100ms
            if (timer - ms > 100)
            {
                for (var i:int = 0; i < graph.height; i++)
                    graph.setPixel32(0, graph.height - i, 0xFF0000);
            }          
            
            graph.setPixel32(0, graph.height - fpsGraph, 0xFFFF00);
            graph.setPixel32(0, graph.height - (frameTime >> 1), 0x00FF00);
            graph.setPixel32(0, graph.height - memGraph, 0x00FFFF);
            
            fpsText.text = "FPS: " + (1000 / avgTime).toFixed(0) + " / " + stageFps;
            memText.text = "MEM: " + mem;
            
            msText.text = "MS: " + frameTime;
            ms = timer;
            
            // Update counters
            if (counters.visible)
            {
                counterText.text = Counters.getCounterText();
            }
            
            // See if any of the critical counters changed and draw a line for that counter if it did.
            Counters.getCriticalCounterSnapshot(criticalCounterCurrentValues);
            for (var key:String in criticalCounterCurrentValues)
            {
                var newCounterVal:int = criticalCounterCurrentValues[key];
                if (criticalCounterLastValues[key] != null && criticalCounterLastValues[key] != newCounterVal)
                {
                    for (i = 0; i < graph.height; i++)
                    {
                        graph.setPixel32(0, graph.height - i, Counters.getCriticalCounterColor(key));
                    }
                    break;
                }
            }
            // Copy current counter values into old counter values
            for (key in criticalCounterCurrentValues)
            {
                criticalCounterLastValues[key] = criticalCounterCurrentValues[key];   
            }
            
            stage.invalidate();
        }
    }
}