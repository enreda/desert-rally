package  
{
	import flash.display.BitmapData;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.text.engine.LineJustification;
	import flash.text.engine.RenderingMode;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextJustifier;
	import flash.text.engine.TextLine;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class TextObject extends GameObject
	{
		[Embed(source = "../media/ae_AlHor.ttf"
			, fontFamily = "AlHor"
			, mimeType = "application/x-font"
			, unicodeRange = "U+0621-U+063A, U+0641-U+064A, U+0660-U+0669" // reference: http://www.unicodemap.org/range/12/Arabic/
			, cff="true")]
		public static var AlHorFont:Class;
		
		private var textLines:Array = new Array();
		public var x:Number;
		public var y:Number;
		public var dir:String;
		
		private var blink:Number = 0;
		private var blinkingSpeed:Number = 1;
		
		public function TextObject(text:String, _x:Number, _y:Number, size:Number, color:uint, _blinkingSpeed:Number = 0, dropShadow:Boolean = false, dir:String = "rtl")
		{
			this.dir = dir;
			x = _x;
			y = _y;
			blinkingSpeed = _blinkingSpeed;
			var fd:FontDescription = new FontDescription("AlHor", FontWeight.NORMAL, FontPosture.NORMAL, FontLookup.EMBEDDED_CFF, RenderingMode.CFF);
			var elementFormat:ElementFormat = new ElementFormat(fd, size, color);
			var textElement:TextElement = new TextElement(text, elementFormat);
			var textBlock:TextBlock = new TextBlock(textElement);// , null, TextJustifier.getJustifierForLocale("ar"));
			textBlock.bidiLevel = 1;

			var t:TextLine = textBlock.createTextLine();
			while (t != null) {
				if (dropShadow) {
					var filters:Array = new Array();
					filters.push(new DropShadowFilter());
					t.filters = filters;
				}
				textLines.push(t);
				t = textBlock.createTextLine(t);
			}
		}
		
		public override function update(dTime:Number, queue:uint):uint
		{
			blink += blinkingSpeed * dTime;
			return Level.QUEUE_RENDER + queue;
		}
		
		public override function render(viewRect:Rectangle, buffer:BitmapData, bufferRect:Rectangle, queue:uint):uint
		{
			var yy:Number = y;
			for each (var t:TextLine in textLines) {
				var mat:Matrix = new Matrix();
				if (dir == "rtl")
					mat.translate(x - t.width, yy);
				else if (dir == "center")
					mat.translate(x - (t.width / 2), yy);
				else
					mat.translate(x, yy);
				
				buffer.draw(t, mat, new ColorTransform(1, 1, 1, Math.abs(Math.cos(blink))));
				yy += t.height;
			}
			return Level.QUEUE_UPDATE + queue;
		}
	}
	
}