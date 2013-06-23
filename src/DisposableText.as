package  
{
	import flash.display.BitmapData;
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
	public class DisposableText extends GameObject
	{		
		private var textLines:Array = new Array();
		public var x:Number;
		public var y:Number;
		
		private var count:Number = 0;
		private var blinkingSpeed:Number = 1;
		
		public function DisposableText(text:String, _x:Number, _y:Number, size:Number, color:uint, _blinkingSpeed:Number = 1, _count:Number = Math.PI)
		{
			x = _x;
			y = _y;
			blinkingSpeed = _blinkingSpeed;
			count = _count;
			var fd:FontDescription = new FontDescription("AlHor", FontWeight.NORMAL, FontPosture.NORMAL, FontLookup.EMBEDDED_CFF, RenderingMode.CFF);
            
			var elementFormat:ElementFormat = new ElementFormat(fd, size, color);
			elementFormat.fontSize = size;
			//elementFormat.color = _headingColour;
			var textElement:TextElement = new TextElement(text, elementFormat);
			
			var textBlock:TextBlock = new TextBlock(textElement);// , null, TextJustifier.getJustifierForLocale("ar"));
			textBlock.bidiLevel = 1;

			var t:TextLine = textBlock.createTextLine();
			while (t != null) {
				textLines.push(t);
				t = textBlock.createTextLine(t);
			}
		}
		
		public override function update(dTime:Number, queue:uint):uint
		{
			count -= blinkingSpeed * dTime;
			if (count <= 0)
				return 0;
			return Level.QUEUE_RENDER + queue;
		}
		
		public override function render(viewRect:Rectangle, buffer:BitmapData, bufferRect:Rectangle, queue:uint):uint
		{
			var mat:Matrix = new Matrix();
			mat.translate(x, y);
			for each (var t:TextLine in textLines) {
				buffer.draw(t, mat, new ColorTransform(1, 1, 1, Math.abs(Math.sin(count))));
				mat.translate(0, t.height);
			}
			return Level.QUEUE_UPDATE + queue;
		}
	}
	
}