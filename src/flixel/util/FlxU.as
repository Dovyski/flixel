package flixel.util
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import flixel.FlxG;
	
	public class FlxU
	{
		/**
		 * Opens a web page in a new tab or window.
		 * MUST be called from the UI thread or else badness.
		 * 
		 * @param	URL		The address of the web page.
		 */
		static public function openURL(URL:String):void
		{
			navigateToURL(new URLRequest(URL), "_blank");
		}
		
		/**
		 * Just grabs the current "ticks" or time in milliseconds that has passed since Flash Player started up.
		 * Useful for finding out how long it takes to execute specific blocks of code.
		 * 
		 * @return	A <code>uint</code> to be passed to <code>FlxU.endProfile()</code>.
		 */
		static public function getTicks():uint
		{
			return getTimer();
		}
		
		/**
		 * Takes two "ticks" timestamps and formats them into the number of seconds that passed as a String.
		 * Useful for logging, debugging, the watch window, or whatever else.
		 * 
		 * @param	StartTicks	The first timestamp from the system.
		 * @param	EndTicks	The second timestamp from the system.
		 * 
		 * @return	A <code>String</code> containing the formatted time elapsed information.
		 */
		static public function formatTicks(StartTicks:uint,EndTicks:uint):String
		{
			return ((EndTicks-StartTicks)/1000)+"s";
		}
		
		/**
		 * Generate a Flash <code>uint</code> color from RGBA components.
		 * 
		 * @param   Red     The red component, between 0 and 255.
		 * @param   Green   The green component, between 0 and 255.
		 * @param   Blue    The blue component, between 0 and 255.
		 * @param   Alpha   How opaque the color should be, either between 0 and 1 or 0 and 255.
		 * 
		 * @return  The color as a <code>uint</code>.
		 */
		static public function makeColor(Red:uint, Green:uint, Blue:uint, Alpha:Number=1.0):uint
		{
			return (((Alpha>1)?Alpha:(Alpha * 255)) & 0xFF) << 24 | (Red & 0xFF) << 16 | (Green & 0xFF) << 8 | (Blue & 0xFF);
		}

		/**
		 * Generate a Flash <code>uint</code> color from HSB components.
		 * 
		 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
		 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
		 * @param	Brightness	A number between 0 and 1, indicating how bright the color should be.  0 is black, 1 is full bright.
		 * @param   Alpha   	How opaque the color should be, either between 0 and 1 or 0 and 255.
		 * 
		 * @return	The color as a <code>uint</code>.
		 */
		static public function makeColorFromHSB(Hue:Number,Saturation:Number,Brightness:Number,Alpha:Number=1.0):uint
		{
			var red:Number;
			var green:Number;
			var blue:Number;
			if(Saturation == 0.0)
			{
				red   = Brightness;
				green = Brightness;        
				blue  = Brightness;
			}       
			else
			{
				if(Hue == 360)
					Hue = 0;
				var slice:int = Hue/60;
				var hf:Number = Hue/60 - slice;
				var aa:Number = Brightness*(1 - Saturation);
				var bb:Number = Brightness*(1 - Saturation*hf);
				var cc:Number = Brightness*(1 - Saturation*(1.0 - hf));
				switch (slice)
				{
					case 0: red = Brightness; green = cc;   blue = aa;  break;
					case 1: red = bb;  green = Brightness;  blue = aa;  break;
					case 2: red = aa;  green = Brightness;  blue = cc;  break;
					case 3: red = aa;  green = bb;   blue = Brightness; break;
					case 4: red = cc;  green = aa;   blue = Brightness; break;
					case 5: red = Brightness; green = aa;   blue = bb;  break;
					default: red = 0;  green = 0;    blue = 0;   break;
				}
			}
			
			return (((Alpha>1)?Alpha:(Alpha * 255)) & 0xFF) << 24 | uint(red*255) << 16 | uint(green*255) << 8 | uint(blue*255);
		}
		
		/**
		 * Loads an array with the RGBA values of a Flash <code>uint</code> color.
		 * RGB values are stored 0-255.  Alpha is stored as a floating point number between 0 and 1.
		 * 
		 * @param	Color	The color you want to break into components.
		 * @param	Results	An optional parameter, allows you to use an array that already exists in memory to store the result.
		 * 
		 * @return	An <code>Array</code> object containing the Red, Green, Blue and Alpha values of the given color.
		 */
		static public function getRGBA(Color:uint,Results:Array=null):Array
		{
			if(Results == null)
				Results = new Array();
			Results[0] = (Color >> 16) & 0xFF;
			Results[1] = (Color >> 8) & 0xFF;
			Results[2] = Color & 0xFF;
			Results[3] = Number((Color >> 24) & 0xFF) / 255;
			return Results;
		}
		
		/**
		 * Loads an array with the HSB values of a Flash <code>uint</code> color.
		 * Hue is a value between 0 and 360.  Saturation, Brightness and Alpha
		 * are as floating point numbers between 0 and 1.
		 * 
		 * @param	Color	The color you want to break into components.
		 * @param	Results	An optional parameter, allows you to use an array that already exists in memory to store the result.
		 * 
		 * @return	An <code>Array</code> object containing the Red, Green, Blue and Alpha values of the given color.
		 */
		static public function getHSB(Color:uint,Results:Array=null):Array
		{
			if(Results == null)
				Results = new Array();
			
			var red:Number = Number((Color >> 16) & 0xFF) / 255;
			var green:Number = Number((Color >> 8) & 0xFF) / 255;
			var blue:Number = Number((Color) & 0xFF) / 255;
			
			var m:Number = (red>green)?red:green;
			var dmax:Number = (m>blue)?m:blue;
			m = (red>green)?green:red;
			var dmin:Number = (m>blue)?blue:m;
			var range:Number = dmax - dmin;
			
			Results[2] = dmax;
			Results[1] = 0;
			Results[0] = 0;
			
			if(dmax != 0)
				Results[1] = range / dmax;
			if(Results[1] != 0) 
			{
				if (red == dmax)
					Results[0] = (green - blue) / range;
				else if (green == dmax)
					Results[0] = 2 + (blue - red) / range;
				else if (blue == dmax)
					Results[0] = 4 + (red - green) / range;
				Results[0] *= 60;
				if(Results[0] < 0)
					Results[0] += 360;
			}
			
			Results[3] = Number((Color >> 24) & 0xFF) / 255;
			return Results;
		}
		
		/**
		 * Format seconds as minutes with a colon, an optionally with milliseconds too.
		 * 
		 * @param	Seconds		The number of seconds (for example, time remaining, time spent, etc).
		 * @param	ShowMS		Whether to show milliseconds after a "." as well.  Default value is false.
		 * 
		 * @return	A nicely formatted <code>String</code>, like "1:03".
		 */
		static public function formatTime(Seconds:Number,ShowMS:Boolean=false):String
		{
			var timeString:String = int(Seconds/60) + ":";
			var timeStringHelper:int = int(Seconds)%60;
			if(timeStringHelper < 10)
				timeString += "0";
			timeString += timeStringHelper;
			if(ShowMS)
			{
				timeString += ".";
				timeStringHelper = (Seconds-int(Seconds))*100;
				if(timeStringHelper < 10)
					timeString += "0";
				timeString += timeStringHelper;
			}
			return timeString;
		}
		
		/**
		 * Generate a comma-separated string from an array.
		 * Especially useful for tracing or other debug output.
		 * 
		 * @param	AnyArray	Any <code>Array</code> object.
		 * 
		 * @return	A comma-separated <code>String</code> containing the <code>.toString()</code> output of each element in the array.
		 */
		static public function formatArray(AnyArray:Array):String
		{
			if((AnyArray == null) || (AnyArray.length <= 0))
				return "";
			var string:String = AnyArray[0].toString();
			var i:uint = 1;
			var l:uint = AnyArray.length;
			while(i < l)
				string += ", " + AnyArray[i++].toString();
			return string;
		}
		
		/**
		 * Automatically commas and decimals in the right places for displaying money amounts.
		 * Does not include a dollar sign or anything, so doesn't really do much
		 * if you call say <code>var results:String = FlxU.formatMoney(10,false);</code>
		 * However, very handy for displaying large sums or decimal money values.
		 * 
		 * @param	Amount			How much moneys (in dollars, or the equivalent "main" currency - i.e. not cents).
		 * @param	ShowDecimal		Whether to show the decimals/cents component. Default value is true.
		 * @param	EnglishStyle	Major quantities (thousands, millions, etc) separated by commas, and decimal by a period.  Default value is true.
		 * 
		 * @return	A nicely formatted <code>String</code>.  Does not include a dollar sign or anything!
		 */
		static public function formatMoney(Amount:Number,ShowDecimal:Boolean=true,EnglishStyle:Boolean=true):String
		{
			var helper:int;
			var amount:int = Amount;
			var string:String = "";
			var comma:String = "";
			var zeroes:String = "";
			while(amount > 0)
			{
				if((string.length > 0) && comma.length <= 0)
				{
					if(EnglishStyle)
						comma = ",";
					else
						comma = ".";
				}
				zeroes = "";
				helper = amount - int(amount/1000)*1000;
				amount /= 1000;
				if(amount > 0)
				{
					if(helper < 100)
						zeroes += "0";
					if(helper < 10)
						zeroes += "0";
				}
				string = zeroes + helper + comma + string;
			}
			if(ShowDecimal)
			{
				amount = int(Amount*100)-(int(Amount)*100);
				string += (EnglishStyle?".":",") + amount;
				if(amount < 10)
					string += "0";
			}
			return string;
		}
		
		/**
		 * Get the <code>String</code> name of any <code>Object</code>.
		 * 
		 * @param	Obj		The <code>Object</code> object in question.
		 * @param	Simple	Returns only the class name, not the package or packages.
		 * 
		 * @return	The name of the <code>Class</code> as a <code>String</code> object.
		 */
		static public function getClassName(Obj:Object,Simple:Boolean=false):String
		{
			var string:String = getQualifiedClassName(Obj);
			string = string.replace("::",".");
			if(Simple)
				string = string.substr(string.lastIndexOf(".")+1);
			return string;
		}
		
		/**
		 * Check to see if two objects have the same class name.
		 * 
		 * @param	Object1		The first object you want to check.
		 * @param	Object2		The second object you want to check.
		 * 
		 * @return	Whether they have the same class name or not.
		 */
		static public function compareClassNames(Object1:Object,Object2:Object):Boolean
		{
			return getQualifiedClassName(Object1) == getQualifiedClassName(Object2);
		}
		
		/**
		 * Look up a <code>Class</code> object by its string name.
		 * 
		 * @param	Name	The <code>String</code> name of the <code>Class</code> you are interested in.
		 * 
		 * @return	A <code>Class</code> object.
		 */
		static public function getClass(Name:String):Class
		{
			return getDefinitionByName(Name) as Class;
		}
		
		/**
		 * A tween-like function that takes a starting velocity
		 * and some other factors and returns an altered velocity.
		 * 
		 * @param	Velocity		Any component of velocity (e.g. 20).
		 * @param	Acceleration	Rate at which the velocity is changing.
		 * @param	Drag			Really kind of a deceleration, this is how much the velocity changes if Acceleration is not set.
		 * @param	Max				An absolute value cap for the velocity.
		 * 
		 * @return	The altered Velocity value.
		 */
		static public function computeVelocity(Velocity:Number, Acceleration:Number=0, Drag:Number=0, Max:Number=10000):Number
		{
			if(Acceleration != 0)
				Velocity += Acceleration*FlxG.elapsed;
			else if(Drag != 0)
			{
				var drag:Number = Drag*FlxG.elapsed;
				if(Velocity - drag > 0)
					Velocity = Velocity - drag;
				else if(Velocity + drag < 0)
					Velocity += drag;
				else
					Velocity = 0;
			}
			if((Velocity != 0) && (Max != 10000))
			{
				if(Velocity > Max)
					Velocity = Max;
				else if(Velocity < -Max)
					Velocity = -Max;
			}
			return Velocity;
		}
		
		
		/*     --- Deprecated members in Flixel v2.57 ---     */
		/*  To be removed after developers have had time to adjust to the new changes. */
		
		/**
		 * Generates a random number based on the seed provided.
		 * 
		 * @param	Seed	A number between 0 and 1, used to generate a predictable random number (very optional).
		 * 
		 * @return	A <code>Number</code> between 0 and 1.
		 * 
		 * @deprecated This property is deprecated. Use the <code>FlxRandom</code> class instead.
		 */
		static public function srand(Seed:Number):Number
		{
			FlxG.warnDeprecated('FlxU.srand()', 'FlxRandom');
			// I'll just keep using the old deprecated method for now. No use using FlxRandom since the RNG is slightly different.
			return ((69621 * int(Seed * 0x7FFFFFFF)) % 0x7FFFFFFF) / 0x7FFFFFFF;
		}
		
		/**
		 * Shuffles the entries in an array into a new random order.
		 * NOT deterministic and unsafe for use with replays/recordings.
		 * 
		 * @param	Objects			A Flash <code>Array</code> object containing...stuff.
		 * @param	HowManyTimes	How many swaps to perform during the shuffle operation.  Good rule of thumb is 2-4 times as many objects are in the list.
		 * 
		 * @return	The same Flash <code>Array</code> object that you passed in in the first place.
		 * 
		 * @deprecated This property is deprecated. Use the <code>shuffle()</code> method of the <code>FlxRandom</code> class instead.
		 */
		static public function shuffle(Objects:Array,HowManyTimes:uint):Array
		{
			FlxG.warnDeprecated('FlxU.shuffle()', 'FlxRandom#shuffle()');
			var i:uint = 0;
			var index1:uint;
			var index2:uint;
			var object:Object;
			while(i < HowManyTimes)
			{
				index1 = Math.random()*Objects.length;
				index2 = Math.random()*Objects.length;
				object = Objects[index2];
				Objects[index2] = Objects[index1];
				Objects[index1] = object;
				i++;
			}
			return Objects;
		}
		
		/**
		 * Fetch a random entry from the given array.
		 * Will return null if random selection is missing, or array has no entries.
		 * NOT deterministic and unsafe for use with replays/recordings.
		 * 
		 * @param	Objects		A Flash array of objects.
		 * @param	StartIndex	Optional offset off the front of the array. Default value is 0, or the beginning of the array.
		 * @param	Length		Optional restriction on the number of values you want to randomly select from.
		 * 
		 * @return	The random object that was selected.
		 * 
		 * @deprecated This property is deprecated. Use the <code>item()</code> method of the <code>FlxRandom</code> class instead.
		 */
		static public function getRandom(Objects:Array,StartIndex:uint=0,Length:uint=0):Object
		{
			FlxG.warnDeprecated('FlxU.getRandom()', 'FlxRandom#item()');
			if(Objects != null)
			{
				var l:uint = Length;
				if((l == 0) || (l > Objects.length - StartIndex))
					l = Objects.length - StartIndex;
				if(l > 0)
					return Objects[StartIndex + uint(Math.random()*l)];
			}
			return null;
		}
		
		
		/**
		 * Rotates a point in 2D space around another point by the given angle.
		 * 
		 * @param	X		The X coordinate of the point you want to rotate.
		 * @param	Y		The Y coordinate of the point you want to rotate.
		 * @param	PivotX	The X coordinate of the point you want to rotate around.
		 * @param	PivotY	The Y coordinate of the point you want to rotate around.
		 * @param	Angle	Rotate the point by this many degrees.
		 * @param	Point	Optional <code>FlxPoint</code> to store the results in.
		 * 
		 * @return	A <code>FlxPoint</code> containing the coordinates of the rotated point.
		 * 
		 * @deprecated This property is deprecated. Use <code>FlxPoint.rotate()</code> instead.
		 */
		static public function rotatePoint(X:Number, Y:Number, pivotX:Number, pivotY:Number, angle:Number, point:FlxPoint=null):FlxPoint
		{
			FlxG.warnDeprecated('FlxU.rotatePoint()', 'FlxPoint.rotate()');
			return FlxPoint.rotate(X, Y, pivotX, pivotY, angle, point);
		}
		
		/**
		 * Calculates the angle between two points.  0 degrees points straight up.
		 * 
		 * @param	Point1		The X coordinate of the point.
		 * @param	Point2		The Y coordinate of the point.
		 * 
		 * @return	The angle in degrees, between -180 and 180.
		 * 
		 * @deprecated This property is deprecated. Use <code>FlxPoint.angleBetween()</code> instead.
		 */
		static public function getAngle(point1:FlxPoint, point2:FlxPoint):Number
		{
			FlxG.warnDeprecated('FlxU.getAngle()', 'FlxPoint.angleBetween()');
			return FlxPoint.angleBetween(point1, point2);
		}
		
		/**
		 * Calculate the distance between two points.
		 * 
		 * @param Point1	A <code>FlxPoint</code> object referring to the first location.
		 * @param Point2	A <code>FlxPoint</code> object referring to the second location.
		 * 
		 * @return	The distance between the two points as a floating point <code>Number</code> object.
		 * 
		 * @deprecated This property is deprecated. Use <code>FlxPoint.distance()</code> instead.
		 */
		static public function getDistance(point1:FlxPoint, point2:FlxPoint):Number
		{
			FlxG.warnDeprecated('FlxU.getDistance()', 'FlxPoint.distance()');
			return FlxPoint.distance(point1, point2);
		}
		
		/**
		 * Calculate the absolute value of a number.
		 * 
		 * @deprecated This property is deprecated. Use <code>FlxMath.abs()</code> instead.
		 * 
		 * @param	Value	Any number.
		 * 
		 * @return	The absolute value of that number.
		 */
		static public function abs(Value:Number):Number
		{
			FlxG.warnDeprecated('FlxU.abs()', 'FlxMath.abs()');
			return FlxMath.abs(Value);
		}
		
		/**
		 * Round down to the next whole number. E.g. floor(1.7) == 1, and floor(-2.7) == -2.
		 * 
		 * @deprecated This property is deprecated. Use <code>FlxMath.floor()</code> instead.
		 * 
		 * @param	Value	Any number.
		 * 
		 * @return	The rounded value of that number.
		 */
		static public function floor(Value:Number):Number
		{
			FlxG.warnDeprecated('FlxU.floor()', 'FlxMath.floor()');
			return FlxMath.floor(Value);
		}
		
		/**
		 * Round up to the next whole number.  E.g. ceil(1.3) == 2, and ceil(-2.3) == -3.
		 * 
		 * @deprecated This property is deprecated. Use <code>FlxMath.ceil()</code> instead.
		 * 
		 * @param	Value	Any number.
		 * 
		 * @return	The rounded value of that number.
		 */
		static public function ceil(Value:Number):Number
		{
			FlxG.warnDeprecated('FlxU.ceil()', 'FlxMath.ceil()');
			return FlxMath.ceil(Value);
		}
		
		/**
		 * Round to the closest whole number. E.g. round(1.7) == 2, and round(-2.3) == -2.
		 * 
		 * @deprecated This property is deprecated. Use <code>FlxMath.round()</code> instead.
		 * 
		 * @param	Value	Any number.
		 * 
		 * @return	The rounded value of that number.
		 */
		static public function round(Value:Number):Number
		{
			FlxG.warnDeprecated('FlxU.round()', 'FlxMath.round()');
			return FlxU.round(Value);
		}
		
		/**
		 * Figure out which number is smaller.
		 * 
		 * @deprecated This property is deprecated. Use <code>FlxMath.min()</code> instead.
		 * 
		 * @param	Number1		Any number.
		 * @param	Number2		Any number.
		 * 
		 * @return	The smaller of the two numbers.
		 */
		static public function min(Number1:Number,Number2:Number):Number
		{
			FlxG.warnDeprecated('FlxU.min()', 'FlxMath.min()');
			return FlxMath.min(Number1, Number2);
		}
		
		/**
		 * Figure out which number is larger.
		 * 
		 * @deprecated This property is deprecated. Use <code>FlxMath.max()</code> instead.
		 * 
		 * @param	Number1		Any number.
		 * @param	Number2		Any number.
		 * 
		 * @return	The larger of the two numbers.
		 */
		static public function max(Number1:Number,Number2:Number):Number
		{
			FlxG.warnDeprecated('FlxU.max()', 'FlxMath.max()');
			return FlxMath.max(Number1, Number2);
		}
		
		/**
		 * Bound a number by a minimum and maximum.
		 * Ensures that this number is no smaller than the minimum,
		 * and no larger than the maximum.
		 * 
		 * @deprecated This property is deprecated. Use <code>FlxMath.clamp()</code> instead.
		 * 
		 * @param	Value	Any number.
		 * @param	Min		Any number.
		 * @param	Max		Any number.
		 * 
		 * @return	The bounded value of the number.
		 */
		static public function bound(Value:Number,Min:Number,Max:Number):Number
		{
			FlxG.warnDeprecated('FlxU.bound()', 'FlxMath.clamp()');
			return FlxMath.clamp(Value, Min, Max);
		}
	}
}
