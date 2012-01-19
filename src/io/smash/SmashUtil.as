/*******************************************************************************
 * Smash Engine
 * Copyright (C) 2009 Smash Labs, LLC
 * For more information see http://www.Smashengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package io.smash
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    
    import io.smash.debug.Logger;
    import io.smash.util.TypeUtility;

    /**
     * Contains an assortment of useful utility methods.
     */
    public class SmashUtil
    {
        public static const FLIP_HORIZONTAL:String = "flipHorizontal";
        public static const FLIP_VERTICAL:String = "flipVertical";

        /**
         * Two times PI.
         */
        public static const TWO_PI:Number = 2.0 * Math.PI;

        /**
         * Converts an angle in radians to an angle in degrees.
         *
         * @param radians The angle to convert.
         *
         * @return The converted value.
         */
        public static function getDegreesFromRadians(radians:Number):Number
        {
            return radians * 180 / Math.PI;
        }

        /**
         * Converts an angle in degrees to an angle in radians.
         *
         * @param degrees The angle to convert.
         *
         * @return The converted value.
         */
        public static function getRadiansFromDegrees(degrees:Number):Number
        {
            return degrees * Math.PI / 180;
        }

        /**
         * Keep a number between a min and a max.
         */
        public static function clamp(v:Number, min:Number = 0, max:Number = 1):Number
        {
            if (v < min) return min;
            if (v > max) return max;
            return v;
        }

        /**
         * Clones an array.
         * @param array Array to clone.
         * @return a cloned array.
         */
        public static function cloneArray(array:Array):Array
        {
            var newArray:Array = [];

            for each (var item:* in array) {
                newArray.push(item);
            }

            return newArray;
        }

        /**
         * Take a radian measure and make sure it is between -pi..pi.
         */
        public static function unwrapRadian(r:Number):Number
        {
            r = r % Math.PI;
            if (r > Math.PI) {
                r -= TWO_PI;
            }
            if (r < -Math.PI) {
                r += TWO_PI;
            }
            return r;
        }

        /**
         * Take a degree measure and make sure it is between 0..360.
         */
        public static function unwrapDegrees(r:Number):Number
        {
            r = r % 360;
            if (r > 180) {
                r -= 360;
            }
            if (r < -180) {
                r += 360;
            }
            return r;
        }

        /**
         * Return the shortest distance to get from from to to, in radians.
         */
        public static function getRadianShortDelta(from:Number, to:Number):Number
        {
            // Unwrap both from and to.
            from = unwrapRadian(from);
            to = unwrapRadian(to);

            // Calc delta.
            var delta:Number = to - from;

            // Make sure delta is shortest path around circle.
            if (delta > Math.PI) {
                delta -= Math.PI * 2;
            }
            if (delta < -Math.PI) {
                delta += Math.PI * 2;
            }

            // Done
            return delta;
        }

        /**
         * Return the shortest distance to get from from to to, in degrees.
         */
        public static function getDegreesShortDelta(from:Number, to:Number):Number
        {
            // Unwrap both from and to.
            from = unwrapDegrees(from);
            to = unwrapDegrees(to);

            // Calc delta.
            var delta:Number = to - from;

            // Make sure delta is shortest path around circle.
            if (delta > 180) {
                delta -= 360;
            }
            if (delta < -180) {
                delta += 360;
            }

            // Done
            return delta;
        }

        /**
         * Get number of bits required to encode values from 0..max.
         *
         * @param max The maximum value to be able to be encoded.
         * @return Bitcount required to encode max value.
         */
        public static function getBitCountForRange(max:int):int
        {
            // TODO: Make this use bits and be fast.
            return Math.ceil(Math.log(max) / Math.log(2.0));
        }

        /**
         * Returns the power of a number which is a power of 2.
         */
        public static function getPowerOfTwo(value:uint):uint
        {
            // TODO: Find a faster way.
            return Math.log(value) * Math.LOG2E;
        }

        /**
         * Pick an integer in a range, with a bias factor (from -1 to 1) to skew towards
         * low or high end of range.
         *
         * @param min Minimum value to choose from, inclusive.
         * @param max Maximum value to choose from, inclusive.
         * @param bias -1 skews totally towards min, 1 totally towards max.
         * @return A random integer between min/max with appropriate bias.
         *
         */
        public static function pickWithBias(min:int, max:int, bias:Number = 0):int
        {
            return clamp((((Math.random() + bias) * (max - min + 1)) + min), min, max);
        }

        /**
         * Assigns parameters from source to destination by name.
         *
         * <p>This allows duck typing - you can accept a generic object
         * (giving you nice {foo:bar} syntax) and cast to a typed object for
         * easier internal processing and validation.</p>
         *
         * @param source Object to read fields from.
         * @param dest Object to assign fields to.
         * @param abortOnMismatch If true, throw an error if a field in source is absent in destination.
         * @param deepCopy If true, check for arrays of objects in the source object and copy them as well
         */
        public static function duckAssign(source:Object, destination:Object, abortOnMismatch:Boolean = false, deepCopy:Boolean = false):void
        {
            // Get the list of public fields.
            var sourceFields:XML = TypeUtility.getTypeDescription(source);

            for each(var fieldInfo:XML in sourceFields.*) {
                // Skip anything that is not a field.
                if (fieldInfo.name() != "variable" && fieldInfo.name() != "accessor") {
                    continue;
                }

                // Skip write-only stuff.
                if (fieldInfo.@access == "writeonly") {
                    continue;
                }

                var fieldName:String = fieldInfo.@name;

                attemptAssign(fieldName, source, destination, abortOnMismatch, deepCopy);
            }

            // Deal with dynamic fields, too.
            for (var field:String in source) {
                attemptAssign(field, source, destination, abortOnMismatch, deepCopy);
            }
        }

        /**
         * Assign a single field from the source object to the destination. Also handles assigning
         * nested typed vectors of objects. In the destination object class, add a TypeHint to the
         * field that contains the Vector like so:
         *
         * [TypeHint (type="example.models.BodyPartDescription")]
         * public var parts:Vector.<BodyPartDescription>;
         *
         * @param source Object to read fields from.
         * @param dest Object to assign fields to.
         * @param abortOnMismatch If true, throw an error if a field in source is absent in destination.
         * @param deepCopy If true, check for arrays of objects in the source object and copy them as well
         */
        private static function attemptAssign(fieldName:String, source:Object, destination:Object, abortOnMismatch:Boolean, deepCopy:Boolean):void
        {
            // Deep copy and source is an array?
            if (deepCopy && source[fieldName] is Array) {
                var tmpArray:Object = null;

                // See if we have a type hint for objects in the array
                // by looking at the destination field
                var typeName:String = TypeUtility.getTypeHint(destination, fieldName);

                if (typeName) {
                    var vectorType:String = "Vector.<" + typeName + ">";
                    tmpArray = TypeUtility.instantiate(vectorType);

                    for each (var val:Object in source[fieldName]) {
                        var obj:Object = null;
                        if (typeName) {
                            obj = TypeUtility.instantiate(typeName);
                        }
                        else {
                            obj = new Object();
                        }

                        duckAssign(val, obj, abortOnMismatch, deepCopy);

                        tmpArray.push(obj);
                    }
                }
                else {
                    tmpArray = source[fieldName];
                }


                destination[fieldName] = tmpArray;
            }
            else {
                try {
                    // Try to assign.
                    destination[fieldName] = source[fieldName];
                }
                catch(e:Error) {
                    // Abort or continue, depending on user settings.
                    if (!abortOnMismatch) {
                        return;
                    }
                    throw new Error("Field '" + fieldName + "' in source was not present in destination.");
                }
            }
        }

        /**
         * Calculate length of a vector.
         */
        public static function xyLength(x:Number, y:Number):Number
        {
            return Math.sqrt((x * x) + (y * y));
        }

        /**
         * Replaces instances of less then, greater then, ampersand, single and double quotes.
         * @param str String to escape.
         * @return A string that can be used in an htmlText property.
         */
        public static function escapeHTMLText(str:String):String
        {
            var chars:Array =
                    [
                        {char:"&", repl:"|amp|"},
                        {char:"<", repl:"&lt;"},
                        {char:">", repl:"&gt;"},
                        {char:"\'", repl:"&apos;"},
                        {char:"\"", repl:"&quot;"},
                        {char:"|amp|", repl:"&amp;"}
                    ];

            for (var i:int = 0; i < chars.length; i++) {
                while (str.indexOf(chars[i].char) != -1) {
                    str = str.replace(chars[i].char, chars[i].repl);
                }
            }

            return str;
        }

        /**
         * Converts a String to a Boolean. This method is case insensitive, and will convert
         * "true", "t" and "1" to true. It converts "false", "f" and "0" to false.
         * @param str String to covert into a boolean.
         * @return true or false
         */
        public static function stringToBoolean(str:String):Boolean
        {
            if (str == null) {
                return false;
            }
            switch (str.substring(1, 0).toUpperCase()) {
            case "F":
            case "0":
                return false;
                break;
            case "T":
            case "1":
                return true;
                break;
            }

            return false;
        }

        /**
         * Capitalize the first letter of a string
         * @param str String to capitalize the first leter of
         * @return String with the first letter capitalized.
         */
        public static function capitalize(str:String):String
        {
            return str.substring(1, 0).toUpperCase() + str.substring(1);
        }

        /**
         * Removes all instances of the specified character from
         * the beginning and end of the specified string.
         */
        public static function trim(str:String, char:String):String
        {
            return trimBack(trimFront(str, char), char);
        }

        /**
         * Recursively removes all characters that match the char parameter,
         * starting from the front of the string and working toward the end,
         * until the first character in the string does not match char and returns
         * the updated string.
         */
        public static function trimFront(str:String, char:String):String
        {
            char = stringToCharacter(char);
            if (str.charAt(0) == char) {
                str = trimFront(str.substring(1), char);
            }
            return str;
        }

        /**
         * Recursively removes all characters that match the char parameter,
         * starting from the end of the string and working backward,
         * until the last character in the string does not match char and returns
         * the updated string.
         */
        public static function trimBack(str:String, char:String):String
        {
            char = stringToCharacter(char);
            if (str.charAt(str.length - 1) == char) {
                str = trimBack(str.substring(0, str.length - 1), char);
            }
            return str;
        }

        /**
         * Returns the first character of the string passed to it.
         */
        public static function stringToCharacter(str:String):String
        {
            if (str.length == 1) {
                return str;
            }
            return str.slice(0, 1);
        }

        /**
         * Determine the file extension of a file.
         * @param file A path to a file.
         * @return The file extension.
         *
         */
        public static function getFileExtension(file:String):String
        {
            var extensionIndex:Number = file.lastIndexOf(".");
            if (extensionIndex == -1) {
                //No extension
                return "";
            } else {
                return file.substr(extensionIndex + 1, file.length);
            }
        }

        /**
         * Isolate the file name from a full file path
         * @param file A path to a file.
         * @return The file name without any path information.
         *
         */
        public static function getFileName(filePath:String):String
        {
            return filePath.substr(filePath.lastIndexOf("/") + 1);
        }

        /**
         * Method for flipping a DisplayObject
         * @param obj DisplayObject to flip
         * @param orientation Which orientation to use: SmashUtil.FLIP_HORIZONTAL or SmashUtil.FLIP_VERTICAL
         *
         */
        public static function flipDisplayObject(obj:DisplayObject, orientation:String):void
        {
            var m:Matrix = obj.transform.matrix;

            switch (orientation) {
            case FLIP_HORIZONTAL:
                m.a = -1;
                m.tx = obj.width + obj.x;
                break;
            case FLIP_VERTICAL:
                m.d = -1;
                m.ty = obj.height + obj.y;
                break;
            }

            obj.transform.matrix = m;
        }

        public static var dumpRecursionSafety:Dictionary = new Dictionary();

        /**
         * Log an object to the console. Based on http://dev.base86.com/solo/47/actionscript_3_equivalent_of_phps_printr.html
         * @param thisObject Object to display for logging.
         * @param obj Object to dump.
         */
        public static function dumpObjectToLogger(thisObject:*, obj:*, level:int = 0, output:String = ""):String
        {
            var tabs:String = "";
            for (var i:int = 0; i < level; i++) {
                tabs += "\t";
            }

            var fields:Array = TypeUtility.getListOfPublicFields(obj);

            for each(var child:* in fields) {
                // Only dump things once.
                if (dumpRecursionSafety[child] == 1) {
                    continue;
                }
                dumpRecursionSafety[child] = 1;

                output += tabs + "[" + child + "] => " + obj[child];

                var childOutput:String = dumpObjectToLogger(thisObject, obj[child], level + 1);
                if (childOutput != '') output += ' {\n' + childOutput + tabs + '}';

                output += "\n";
            }

            if (level == 0) {
                // Clear the recursion safety net.
                dumpRecursionSafety = new Dictionary();

                Logger.print(thisObject, output);
                return "";
            }

            return output;
        }

        /**
         * Make a deep copy of an object.
         *
         * Only really works well with all-public objects, private/protected
         * fields will not be respected.
         *
         * @param source Object to copy.
         * @return New instance of object with all public fields set.
         *
         */
        public static function clone(source:Object):Object
        {
            var clone:Object;
            if (!source) {
                return null;
            }

            clone = newSibling(source);

            if (clone) {
                copyData(source, clone);
            }

            return clone;
        }

        protected static function newSibling(sourceObj:Object):*
        {
            if (!sourceObj) {
                return null;
            }

            var objSibling:*;
            try {
                var classOfSourceObj:Class = getDefinitionByName(getQualifiedClassName(sourceObj)) as Class;
                objSibling = new classOfSourceObj();
            }
            catch(e:Object) {
            }

            return objSibling;
        }

        protected static function copyData(source:Object, destination:Object):void
        {

            //copies data from commonly named properties and getter/setter pairs
            if ((source) && (destination)) {
                try {
                    var sourceInfo:XML = describeType(source);
                    var prop:XML;

                    for each(prop in sourceInfo.variable) {
                        if (!destination.hasOwnProperty(prop.@name)) {
                            continue;
                        }
                        destination[prop.@name] = source[prop.@name];
                    }

                    for each(prop in sourceInfo.accessor) {
                        if (prop.@access != "readwrite") {
                            continue;
                        }

                        if (!destination.hasOwnProperty(prop.@name)) {
                            continue;
                        }

                        destination[prop.@name] = source[prop.@name];
                    }
                }
                catch (err:Object) {
                }
            }
        }

        /**
         * Recursively searches for an object with the specified name that has been added to the
         * display hierarchy.
         *
         * @param name The name of the object to find.
         *
         * @return The display object with the specified name, or null if it wasn't found.
         */
        public static function findChild(name:String, displayObjectToSearch:DisplayObject):DisplayObject
        {
            return _findChild(name, displayObjectToSearch);
        }

        protected static function _findChild(name:String, current:DisplayObject):DisplayObject
        {
            if (!current) {
                return null;
            }

            if (current.name == name) {
                return current;
            }

            var parent:DisplayObjectContainer = current as DisplayObjectContainer;

            if (!parent) {
                return null;
            }

            for (var i:int = 0; i < parent.numChildren; i++) {
                var child:DisplayObject = _findChild(name, parent.getChildAt(i));
                if (child) {
                    return child;
                }
            }

            return null;
        }

        /**
         * Return a function that calls a specified function with the provided arguments.
         *
         * For instance, function a(b,c) through closurize(a, b, c) becomes
         * a function() that calls function a(b,c);
         *
         * Thanks to Rob Sampson <www.calypso88.com>.
         */
        public static function closurize(func:Function, ...args):Function
        {
            // Create a new function...
            return function():*
            {
                // Call the original function with provided args.
                return func.apply(null, args);
            }
        }

        /**
         * Return a function that calls a specified function with the provided arguments
         * APPENDED to its provided arguments.
         *
         * For instance, function a(b,c) through closurizeAppend(a, c) becomes
         * a function(b) that calls function a(b,c);
         */
        public static function closurizeAppend(func:Function, ...additionalArgs):Function
        {
            // Create a new function...
            return function(...localArgs):*
            {
                // Combine parameter lists.
                var argsCopy:Array = localArgs.concat(additionalArgs);

                // Call the original function.
                return func.apply(null, argsCopy);
            }
        }

        /**
         * Return a sorted list of the keys in a dictionary
         */
        public static function getSortedDictionaryKeys(dict:Object):Array
        {
            var keylist:Array = new Array();
            for (var key:String in dict) {
                keylist.push(key);
            }
            keylist.sort();

            return keylist;
        }

        /**
         * Return a sorted list of the values in a dictionary
         */
        public static function getSortedDictionaryValues(dict:Dictionary):Array
        {
            var valuelist:Array = new Array();
            for each (var value:Object in dict) {
                valuelist.push(value);
            }
            valuelist.sort();

            return valuelist;
        }

        /**
         * Given an array of items and an array of weights,
         * select a random item. Items with higher weights
         * are more likely to be selected.
         *
         */
        public static function selectRandomWeightedItem(items:Array, weights:Array):Object
        {
            var total:int = 0;
            var ranges:Array = [];
            for (var i:int = 0; i < items.length; i++) {
                ranges[i] = { start: total, end: total + weights[i] };
                total += weights[i];
            }

            var rand:int = Math.random() * total;

            var item:Object = items[0];

            for (i = 0; i < ranges.length; i++) {
                if (rand >= ranges[i].start && rand <= ranges[i].end) {
                    item = items[i];
                    break;
                }
            }

            return item;
        }

        /**
         * Instantiate a new object of the same type passed in to this
         * function.
         *
         * This does not copy any properties from the object, it simply
         * instantiates a new object of the same type.
         *
         * @param obj The object to create an empty copy of
         * @return A new object of the type passed in to the function
         */
        public static function instantiateCloneObject(obj:Object):Object
        {
            var sourceClass:Class = Object(obj).constructor;
            return new sourceClass();
        }

        /**
         * A Regular expression to match special Regular expression characters
         */
        public static const MATCH_SPECIAL_REGEXP:RegExp = new RegExp("([{}\(\)\^$&.\/\+\|\[\\\\]|\]|\-)", "g");

        /**
         * A Regular Expression for matching * and ? wildcard characters
         */
        public static const MATCH_WILDCARDS_REGEXP:RegExp = new RegExp("([\*\?])", "g");

        /**
         * Match a wildcard pattern (*,?) with a given source string.
         *
         * @return True if the pattern matches the source string
         */
        public static function matchWildcard(source:String, wildcard:String):Boolean
        {
            var regexp:String = wildcard.replace(MATCH_SPECIAL_REGEXP, "\\$1");
            regexp = "^" + regexp.replace(MATCH_WILDCARDS_REGEXP, ".$1") + "$";
            return Boolean(source.search(regexp) != -1);
        }

        /**
         * Convert milliseconds to seconds
         **/
        public static function convertMillisecondsToSeconds(mil:int):Number
        {
            return mil / 1000;
        }

        /**
         * Convert seconds to milliseconds
         **/
        public static function convertSecondsToMilliseconds(seconds:int):Number
        {
            return seconds * 1000;
        }

        /**
         * Return a new string that replaces the given search string with
         * the replace string.
         * @param str String to search in
         * @param oldSubStr String to search for
         * @param newSubStr String to replace.
         */
        public static function replaceString(str:String, oldSubStr:String, newSubStr:String):String
        {
            return str.split(oldSubStr).join(newSubStr);
        }

        /**
         * Applies the given transformation matrix to the rectangle and returns
         * a new bounding box to the transformed rectangle.
         */
        public static function getBoundsAfterTransformation(bounds:Rectangle, m:Matrix):Rectangle
        {
            if (m == null) return bounds;

            var topLeft:Point = m.transformPoint(bounds.topLeft);
            var topRight:Point = m.transformPoint(new Point(bounds.right, bounds.top));
            var bottomRight:Point = m.transformPoint(bounds.bottomRight);
            var bottomLeft:Point = m.transformPoint(new Point(bounds.left, bounds.bottom));

            var left:Number = Math.min(topLeft.x, topRight.x, bottomRight.x, bottomLeft.x);
            var top:Number = Math.min(topLeft.y, topRight.y, bottomRight.y, bottomLeft.y);
            var right:Number = Math.max(topLeft.x, topRight.x, bottomRight.x, bottomLeft.x);
            var bottom:Number = Math.max(topLeft.y, topRight.y, bottomRight.y, bottomLeft.y);
            return new Rectangle(left, top, right - left, bottom - top);
        }

        /**
         * Returns a random int within a set range.
         * @param min
         * @param max
         * @return
         */
        public static function randomRange(min:int, max:int):int
        {
            return int(Math.random() * max) + min;
        }
    }
}