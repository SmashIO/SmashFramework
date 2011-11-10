package io.smash.debug
{
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.text.AntiAliasType;
    import flash.text.GridFitType;
    import flash.text.TextField;
    import flash.text.TextFormat;
    
    /**
     * Helper class to cache glyphs as bitmaps and draw them fast, with color.
     */
    public class GlyphCache
    {
        public function GlyphCache()
        {
            // Set up the text field.
            _textField.setTextFormat(_textFormat);
            _textField.defaultTextFormat = _textFormat;
            
            // This makes a big difference in legibility.
            _textField.antiAliasType = AntiAliasType.ADVANCED;
            _textField.embedFonts = false;
        }
        
        public function drawLineToBitmap(line:String, x:int, y:int, color:uint, renderTarget:BitmapData):int
        {
            // Get the color bitmap.
            if(!_colorCache[color])
                _colorCache[color] = new BitmapData(128, 128, false, color);
            const colorBitmap:BitmapData = _colorCache[color] as BitmapData;
            
            // Keep track of current pos.
            var curPos:Point = new Point(x, y);
            var linesConsumed:int = 1;
            
            // Get each character.
            const glyphCount:int = line.length;
            for(var i:int=0; i<glyphCount; i++)
            {
                const char:int = line.charCodeAt(i);
                
                // Special cases...
                if(char == 10)
                {
                    // New line!
                    curPos.x = x;
                    curPos.y += 16;
                    linesConsumed++;
                    continue;
                }
                
                // Draw the glyph.
                const glyph:Glyph = getGlyph(char);
                renderTarget.copyPixels(colorBitmap, glyph.rect, curPos, glyph.bitmap, null, true);
                
                // Update position.
                curPos.x += glyph.rect.width - 1;
            }
            
            return linesConsumed;
        }
        
        protected function getGlyph(charCode:int):Glyph
        {
            if(_glyphCache[charCode] == null)
            {
                // Generate glyph.
                var newGlyph:Glyph = new Glyph();
                _textField.text = String.fromCharCode(charCode);
                
                newGlyph.bitmap = new BitmapData(_textField.textWidth + 1, 16, true, 0x0);
                
                newGlyph.bitmap.draw(_textField, null, null, null, null, true);
                newGlyph.rect = newGlyph.bitmap.rect;
                
                // Store it in cache.
                _glyphCache[charCode] = newGlyph;
            }
            
            return _glyphCache[charCode] as Glyph;
        }
        
        public function getLineHeight():int
        {
            // Do some tall characters.
            _textField.text = "HPI|y";
            return _textField.getLineMetrics(0).height;
        }
        
        protected const _textFormat:TextFormat = new TextFormat("_typewriter", 11, 0xFFFFFF); 
        protected const _textField:TextField = new TextField();
        protected const _glyphCache:Array = [];
        protected const _colorCache:Array = [];
    }
}

import flash.display.BitmapData;
import flash.geom.Rectangle;

class Glyph
{
    public var rect:Rectangle;
    public var bitmap:BitmapData;
}