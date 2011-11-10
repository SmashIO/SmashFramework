/*******************************************************************************
 * Smash Engine
 * Copyright (C) 2009 Smash Labs, LLC
 * For more information see http://www.Smashengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package io.smash.input
{
    import flash.utils.Dictionary;
    
    /**
     * Enumeration class that maps friendly key names to their key code equivalent. This class
     * should not be instantiated directly, rather, one of the constants should be used.
     */   
    public class KeyboardKey
    {
        public static const INVALID:KeyboardKey = new KeyboardKey(0);
        
        public static const BACKSPACE:KeyboardKey = new KeyboardKey(8);
        public static const TAB:KeyboardKey = new KeyboardKey(9);
        public static const ENTER:KeyboardKey = new KeyboardKey(13);
        public static const COMMAND:KeyboardKey = new KeyboardKey(15);
        public static const SHIFT:KeyboardKey = new KeyboardKey(16);
        public static const CONTROL:KeyboardKey = new KeyboardKey(17);
        public static const ALT:KeyboardKey = new KeyboardKey(18);
        public static const PAUSE:KeyboardKey = new KeyboardKey(19);
        public static const CAPS_LOCK:KeyboardKey = new KeyboardKey(20);
        public static const ESCAPE:KeyboardKey = new KeyboardKey(27);
        
        public static const SPACE:KeyboardKey = new KeyboardKey(32);
        public static const PAGE_UP:KeyboardKey = new KeyboardKey(33);
        public static const PAGE_DOWN:KeyboardKey = new KeyboardKey(34);
        public static const END:KeyboardKey = new KeyboardKey(35);
        public static const HOME:KeyboardKey = new KeyboardKey(36);
        public static const LEFT:KeyboardKey = new KeyboardKey(37);
        public static const UP:KeyboardKey = new KeyboardKey(38);
        public static const RIGHT:KeyboardKey = new KeyboardKey(39);
        public static const DOWN:KeyboardKey = new KeyboardKey(40);
        
        public static const INSERT:KeyboardKey = new KeyboardKey(45);
        public static const DELETE:KeyboardKey = new KeyboardKey(46);
        
        public static const ZERO:KeyboardKey = new KeyboardKey(48);
        public static const ONE:KeyboardKey = new KeyboardKey(49);
        public static const TWO:KeyboardKey = new KeyboardKey(50);
        public static const THREE:KeyboardKey = new KeyboardKey(51);
        public static const FOUR:KeyboardKey = new KeyboardKey(52);
        public static const FIVE:KeyboardKey = new KeyboardKey(53);
        public static const SIX:KeyboardKey = new KeyboardKey(54);
        public static const SEVEN:KeyboardKey = new KeyboardKey(55);
        public static const EIGHT:KeyboardKey = new KeyboardKey(56);
        public static const NINE:KeyboardKey = new KeyboardKey(57);
        
        public static const A:KeyboardKey = new KeyboardKey(65);
        public static const B:KeyboardKey = new KeyboardKey(66);
        public static const C:KeyboardKey = new KeyboardKey(67);
        public static const D:KeyboardKey = new KeyboardKey(68);
        public static const E:KeyboardKey = new KeyboardKey(69);
        public static const F:KeyboardKey = new KeyboardKey(70);
        public static const G:KeyboardKey = new KeyboardKey(71);
        public static const H:KeyboardKey = new KeyboardKey(72);
        public static const I:KeyboardKey = new KeyboardKey(73);
        public static const J:KeyboardKey = new KeyboardKey(74);
        public static const K:KeyboardKey = new KeyboardKey(75);
        public static const L:KeyboardKey = new KeyboardKey(76);
        public static const M:KeyboardKey = new KeyboardKey(77);
        public static const N:KeyboardKey = new KeyboardKey(78);
        public static const O:KeyboardKey = new KeyboardKey(79);
        public static const P:KeyboardKey = new KeyboardKey(80);
        public static const Q:KeyboardKey = new KeyboardKey(81);
        public static const R:KeyboardKey = new KeyboardKey(82);
        public static const S:KeyboardKey = new KeyboardKey(83);
        public static const T:KeyboardKey = new KeyboardKey(84);
        public static const U:KeyboardKey = new KeyboardKey(85);
        public static const V:KeyboardKey = new KeyboardKey(86);
        public static const W:KeyboardKey = new KeyboardKey(87);
        public static const X:KeyboardKey = new KeyboardKey(88);
        public static const Y:KeyboardKey = new KeyboardKey(89);
        public static const Z:KeyboardKey = new KeyboardKey(90);
        
        public static const NUM0:KeyboardKey = new KeyboardKey(96);
        public static const NUM1:KeyboardKey = new KeyboardKey(97);
        public static const NUM2:KeyboardKey = new KeyboardKey(98);
        public static const NUM3:KeyboardKey = new KeyboardKey(99);
        public static const NUM4:KeyboardKey = new KeyboardKey(100);
        public static const NUM5:KeyboardKey = new KeyboardKey(101);
        public static const NUM6:KeyboardKey = new KeyboardKey(102);
        public static const NUM7:KeyboardKey = new KeyboardKey(103);
        public static const NUM8:KeyboardKey = new KeyboardKey(104);
        public static const NUM9:KeyboardKey = new KeyboardKey(105);
        
        public static const MULTIPLY:KeyboardKey = new KeyboardKey(106);
        public static const ADD:KeyboardKey = new KeyboardKey(107);
        public static const NUMENTER:KeyboardKey = new KeyboardKey(108);
        public static const SUBTRACT:KeyboardKey = new KeyboardKey(109);
        public static const DECIMAL:KeyboardKey = new KeyboardKey(110);
        public static const DIVIDE:KeyboardKey = new KeyboardKey(111);
        
        public static const F1:KeyboardKey = new KeyboardKey(112);
        public static const F2:KeyboardKey = new KeyboardKey(113);
        public static const F3:KeyboardKey = new KeyboardKey(114);
        public static const F4:KeyboardKey = new KeyboardKey(115);
        public static const F5:KeyboardKey = new KeyboardKey(116);
        public static const F6:KeyboardKey = new KeyboardKey(117);
        public static const F7:KeyboardKey = new KeyboardKey(118);
        public static const F8:KeyboardKey = new KeyboardKey(119);
        public static const F9:KeyboardKey = new KeyboardKey(120);
        // F10 is considered 'reserved' by Flash
        public static const F11:KeyboardKey = new KeyboardKey(122);
        public static const F12:KeyboardKey = new KeyboardKey(123);
        
        public static const NUM_LOCK:KeyboardKey = new KeyboardKey(144);
        public static const SCROLL_LOCK:KeyboardKey = new KeyboardKey(145);
        
        public static const COLON:KeyboardKey = new KeyboardKey(186);
        public static const PLUS:KeyboardKey = new KeyboardKey(187);
        public static const COMMA:KeyboardKey = new KeyboardKey(188);
        public static const MINUS:KeyboardKey = new KeyboardKey(189);
        public static const PERIOD:KeyboardKey = new KeyboardKey(190);
        public static const BACKSLASH:KeyboardKey = new KeyboardKey(191);
        public static const TILDE:KeyboardKey = new KeyboardKey(192);
        
        public static const LEFT_BRACKET:KeyboardKey = new KeyboardKey(219);
        public static const SLASH:KeyboardKey = new KeyboardKey(220);
        public static const RIGHT_BRACKET:KeyboardKey = new KeyboardKey(221);
        public static const QUOTE:KeyboardKey = new KeyboardKey(222);
        
        /**
         * A dictionary mapping the string names of all the keys to the InputKey they represent.
         */
        public static function get staticTypeMap():Dictionary
        {
            if (!_typeMap)
            {
                _typeMap = new Dictionary();
                _typeMap["BACKSPACE"] = BACKSPACE;
                _typeMap["TAB"] = TAB;
                _typeMap["ENTER"] = ENTER;
                _typeMap["RETURN"] = ENTER;
                _typeMap["SHIFT"] = SHIFT;
                _typeMap["COMMAND"] = COMMAND;
                _typeMap["CONTROL"] = CONTROL;
                _typeMap["ALT"] = ALT;
                _typeMap["OPTION"] = ALT;
                _typeMap["ALTERNATE"] = ALT;
                _typeMap["PAUSE"] = PAUSE;
                _typeMap["CAPS_LOCK"] = CAPS_LOCK;
                _typeMap["ESCAPE"] = ESCAPE;
                _typeMap["SPACE"] = SPACE;
                _typeMap["SPACE_BAR"] = SPACE;
                _typeMap["PAGE_UP"] = PAGE_UP;
                _typeMap["PAGE_DOWN"] = PAGE_DOWN;
                _typeMap["END"] = END;
                _typeMap["HOME"] = HOME;
                _typeMap["LEFT"] = LEFT;
                _typeMap["UP"] = UP;
                _typeMap["RIGHT"] = RIGHT;
                _typeMap["DOWN"] = DOWN;
                _typeMap["LEFT_ARROW"] = LEFT;
                _typeMap["UP_ARROW"] = UP;
                _typeMap["RIGHT_ARROW"] = RIGHT;
                _typeMap["DOWN_ARROW"] = DOWN;
                _typeMap["INSERT"] = INSERT;
                _typeMap["DELETE"] = DELETE;
                _typeMap["ZERO"] = ZERO;
                _typeMap["ONE"] = ONE;
                _typeMap["TWO"] = TWO;
                _typeMap["THREE"] = THREE;
                _typeMap["FOUR"] = FOUR;
                _typeMap["FIVE"] = FIVE;
                _typeMap["SIX"] = SIX;
                _typeMap["SEVEN"] = SEVEN;
                _typeMap["EIGHT"] = EIGHT;
                _typeMap["NINE"] = NINE;
                _typeMap["0"] = ZERO;
                _typeMap["1"] = ONE;
                _typeMap["2"] = TWO;
                _typeMap["3"] = THREE;
                _typeMap["4"] = FOUR;
                _typeMap["5"] = FIVE;
                _typeMap["6"] = SIX;
                _typeMap["7"] = SEVEN;
                _typeMap["8"] = EIGHT;
                _typeMap["9"] = NINE;
                _typeMap["NUMBER_0"] = ZERO;
                _typeMap["NUMBER_1"] = ONE;
                _typeMap["NUMBER_2"] = TWO;
                _typeMap["NUMBER_3"] = THREE;
                _typeMap["NUMBER_4"] = FOUR;
                _typeMap["NUMBER_5"] = FIVE;
                _typeMap["NUMBER_6"] = SIX;
                _typeMap["NUMBER_7"] = SEVEN;
                _typeMap["NUMBER_8"] = EIGHT;
                _typeMap["NUMBER_9"] = NINE;
                _typeMap["A"] = A;
                _typeMap["B"] = B;
                _typeMap["C"] = C;
                _typeMap["D"] = D;
                _typeMap["E"] = E;
                _typeMap["F"] = F;
                _typeMap["G"] = G;
                _typeMap["H"] = H;
                _typeMap["I"] = I;
                _typeMap["J"] = J;
                _typeMap["K"] = K;
                _typeMap["L"] = L;
                _typeMap["M"] = M;
                _typeMap["N"] = N;
                _typeMap["O"] = O;
                _typeMap["P"] = P;
                _typeMap["Q"] = Q;
                _typeMap["R"] = R;
                _typeMap["S"] = S;
                _typeMap["T"] = T;
                _typeMap["U"] = U;
                _typeMap["V"] = V;
                _typeMap["W"] = W;
                _typeMap["X"] = X;
                _typeMap["Y"] = Y;
                _typeMap["Z"] = Z;
                _typeMap["NUM0"] = NUM0;
                _typeMap["NUM1"] = NUM1;
                _typeMap["NUM2"] = NUM2;
                _typeMap["NUM3"] = NUM3;
                _typeMap["NUM4"] = NUM4;
                _typeMap["NUM5"] = NUM5;
                _typeMap["NUM6"] = NUM6;
                _typeMap["NUM7"] = NUM7;
                _typeMap["NUM8"] = NUM8;
                _typeMap["NUM9"] = NUM9;
                _typeMap["NUMPAD_0"] = NUM0;
                _typeMap["NUMPAD_1"] = NUM1;
                _typeMap["NUMPAD_2"] = NUM2;
                _typeMap["NUMPAD_3"] = NUM3;
                _typeMap["NUMPAD_4"] = NUM4;
                _typeMap["NUMPAD_5"] = NUM5;
                _typeMap["NUMPAD_6"] = NUM6;
                _typeMap["NUMPAD_7"] = NUM7;
                _typeMap["NUMPAD_8"] = NUM8;
                _typeMap["NUMPAD_9"] = NUM9;
                _typeMap["MULTIPLY"] = MULTIPLY;
                _typeMap["ASTERISK"] = MULTIPLY;
                _typeMap["NUMMULTIPLY"] = MULTIPLY;
                _typeMap["NUMPAD_MULTIPLY"] = MULTIPLY;
                _typeMap["ADD"] = ADD;
                _typeMap["NUMADD"] = ADD;
                _typeMap["NUMPAD_ADD"] = ADD;
                _typeMap["SUBTRACT"] = SUBTRACT;
                _typeMap["NUMSUBTRACT"] = SUBTRACT;
                _typeMap["NUMPAD_SUBTRACT"] = SUBTRACT;
                _typeMap["DECIMAL"] = DECIMAL;
                _typeMap["NUMDECIMAL"] = DECIMAL;
                _typeMap["NUMPAD_DECIMAL"] = DECIMAL;
                _typeMap["DIVIDE"] = DIVIDE;
                _typeMap["NUMDIVIDE"] = DIVIDE;
                _typeMap["NUMPAD_DIVIDE"] = DIVIDE;
                _typeMap["NUMENTER"] = NUMENTER;
                _typeMap["NUMPAD_ENTER"] = NUMENTER;
                _typeMap["F1"] = F1;
                _typeMap["F2"] = F2;
                _typeMap["F3"] = F3;
                _typeMap["F4"] = F4;
                _typeMap["F5"] = F5;
                _typeMap["F6"] = F6;
                _typeMap["F7"] = F7;
                _typeMap["F8"] = F8;
                _typeMap["F9"] = F9;
                _typeMap["F11"] = F11;
                _typeMap["F12"] = F12;
                _typeMap["NUM_LOCK"] = NUM_LOCK;
                _typeMap["SCROLL_LOCK"] = SCROLL_LOCK;
                _typeMap["COLON"] = COLON;
                _typeMap["SEMICOLON"] = COLON;
                _typeMap["PLUS"] = PLUS;
                _typeMap["EQUAL"] = PLUS;
                _typeMap["COMMA"] = COMMA;
                _typeMap["LESS_THAN"] = COMMA;
                _typeMap["MINUS"] = MINUS;
                _typeMap["UNDERSCORE"] = MINUS;
                _typeMap["PERIOD"] = PERIOD;
                _typeMap["GREATER_THAN"] = PERIOD;
                _typeMap["BACKSLASH"] = BACKSLASH;
                _typeMap["QUESTION_MARK"] = BACKSLASH;
                _typeMap["TILDE"] = TILDE;
                _typeMap["BACK_QUOTE"] = TILDE;
                _typeMap["LEFT_BRACKET"] = LEFT_BRACKET;
                _typeMap["LEFT_BRACE"] = LEFT_BRACKET;
                _typeMap["SLASH"] = SLASH;
                _typeMap["FORWARD_SLASH"] = SLASH;
                _typeMap["PIPE"] = SLASH;
                _typeMap["RIGHT_BRACKET"] = RIGHT_BRACKET;
                _typeMap["RIGHT_BRACE"] = RIGHT_BRACKET;
                _typeMap["QUOTE"] = QUOTE;
            }
            
            return _typeMap;
        }
        
        /**
         * Converts a key code to the string that represents it.
         */
        public static function codeToString(value:int):String
        {
            var tm:Dictionary = staticTypeMap;
            for (var name:String in tm)
            {
                if (staticTypeMap[name.toUpperCase()].keyCode == value)
                    return name.toUpperCase();
            }
            
            return null;
        }
        
        /**
         * Converts the name of a key to the keycode it represents.
         */
        public static function stringToCode(value:String):int
        {
            if (!staticTypeMap[value.toUpperCase()])
                return 0;
            
            return staticTypeMap[value.toUpperCase()].keyCode;
        }
        
        /**
         * Converts the name of a key to the InputKey it represents.
         */
        public static function stringToKey(value:String):KeyboardKey
        {
            return staticTypeMap[value.toUpperCase()];
        }
        
        private static var _typeMap:Dictionary = null;
        
        /**
         * The key code that this wraps.
         */
        public function get keyCode():int
        {
            return _keyCode;
        }
        
        public function KeyboardKey(keyCode:int=0)
        {
            _keyCode = keyCode;
        }
        
        public function get typeMap():Dictionary
        {
            return staticTypeMap;
        }
        
        private var _keyCode:int = 0;
    }
}

