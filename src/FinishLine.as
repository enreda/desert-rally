package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Shader;
	import flash.display.Shape;
	import flash.filters.BlurFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.text.engine.RenderingMode;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class FinishLine extends GameObject
	{
		[Embed(source = "../media/noise.png")]
		public static var NoiseMap:Class;

		public var x:Number;
		public var y:Number;
		
		public var width:Number;
		public var height:Number;
		
		private var image:BitmapData;
		
		private var level:Level;
		
		public function FinishLine(_x:Number, _y:Number, _width:Number, _height:Number, ground:Ground)
		{
			x = _x;
			y = _y;
			width = _width;
			height = _height;
			image = new BitmapData(_width, _height, false, 0);
			fillGround(ground, image);
			var tmp:BitmapData = new BitmapData(_width, _height, true, 0);
			drawLine(tmp);
			drawText(tmp);
			applyNoise(tmp);
			applyBlur(tmp);
			image.draw(tmp, null, new ColorTransform(1, 1, 1, 0.4));
		}
		
		public override function handleAdded(_level:Level, queue:uint):uint
		{
			level = _level;
			return super.handleAdded(_level, queue);
		}
		
		private function fillGround(ground:Ground, b:BitmapData):void
		{
			ground._render(new Rectangle(x, y, width, height), b, new Rectangle(0, 0, width, height));
		}
		
		private function drawLine(b:BitmapData):void
		{
			var shp:Shape = new Shape();
			shp.graphics.lineStyle(10, 0xffffff);
			shp.graphics.moveTo(0, 10);
			shp.graphics.lineTo(b.width, 10);
			
			b.draw(shp, null, null, null, null, true);
		}
		
		private function drawText(b:BitmapData):void
		{
			var fd:FontDescription = new FontDescription("AlHor", FontWeight.NORMAL, FontPosture.NORMAL, FontLookup.EMBEDDED_CFF, RenderingMode.CFF);
			var elementFormat:ElementFormat = new ElementFormat(fd, b.height, 0xffffff);
			var textElement:TextElement = new TextElement("خط النهاية", elementFormat);
			var textBlock:TextBlock = new TextBlock(textElement);// , null, TextJustifier.getJustifierForLocale("ar"));
			var t:TextLine = textBlock.createTextLine();
			
			var mat:Matrix = new Matrix();
			
			mat.translate((b.width / 2) - (t.width / 2), b.height - (20));
			b.draw(t, mat);
		}
		
		private function applyBlur(b:BitmapData):void
		{
			var shp:Shape = new Shape();
			shp.graphics.beginBitmapFill(b);
			shp.graphics.drawRect(0, 0, b.width, b.height);
			shp.graphics.endFill();
			var filters:Array = new Array();
			filters.push(new BlurFilter(5, 5, 1));
			shp.filters = filters;
			b.draw(shp, null, null, null, null, true);
		}
		
		private function applyNoise(b:BitmapData):void
		{
			var shp:Shape = new Shape();
			shp.graphics.beginBitmapFill(new NoiseMap().bitmapData);
			shp.graphics.drawRect(0, 0, b.width, b.height);
			shp.graphics.endFill();
			b.draw(shp, null, null, BlendMode.ERASE);
		}

		public override function render(viewRect:Rectangle, buffer:BitmapData, bufferRect:Rectangle, queue:uint):uint
		{
			var scaleX:Number = bufferRect.width / viewRect.width;
			var scaleY:Number = bufferRect.height / viewRect.height;
			
			var mat:Matrix = new Matrix();
			mat.scale(scaleX * (width / image.width), scaleY * (height / image.height));
			mat.translate(scaleX * (x - viewRect.x), scaleY * (y - viewRect.y));
			
			buffer.draw(image, mat, null, BlendMode.NORMAL, null, true);
			
			return Level.QUEUE_RENDER + queue;
		}
		
		public override function renderNoScale(offset:Point, buffer:BitmapData, queue:uint):uint
		{
			buffer.copyPixels(image, image.rect, new Point(x - offset.x, y - offset.y));
			
			return Level.QUEUE_RENDER + queue;			
		}
		
		public override function handleEvent(eventType:String, args:Object, rValue:Object):uint
		{
			if (eventType == "testCollision") {
				if (args.car.y < y + 10) {
					args.car.off = true;
					level.dispatchEvent("declareWinner", { car:args.car } );
				}
			}
			return Level.QUEUE_EVENT;
		}
	}
}