package  
{
	import adobe.utils.CustomActions;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.ColorCorrection;
	import flash.display.PixelSnapping;
	import flash.display.Shader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class Ground extends GameObject
	{
		[Embed(source = "../media/sand.jpg")]
		public static var GroundSprite:Class;
		
		private static var groundBitmap:Bitmap = new GroundSprite();
		private var groundShape:Shape = new Shape();
		
		private var roadMat:Matrix = new Matrix();
		
		public override function Ground()
		{
			groundBitmap.pixelSnapping = PixelSnapping.ALWAYS;
			groundShape.graphics.beginBitmapFill(groundBitmap.bitmapData, null, true, true);
			groundShape.graphics.drawRect(0, 0, 550 * 5, 400 * 5);
			groundShape.graphics.endFill();
		}
		
		public override function render(viewRect:Rectangle, buffer:BitmapData, bufferRect:Rectangle, queue:uint):uint
		{
			//_render(viewRect, buffer, bufferRect);
			return Level.QUEUE_RENDER + queue;
		}
		
		public override function renderNoScale(offset:Point, buffer:BitmapData, queue:uint):uint
		{
			//var startX:Number = 0 - (offset.x % groundBitmap.bitmapData.width);
			var startY:Number = 0 - (offset.y % groundBitmap.bitmapData.height);
			
			//var repeatX:int = Math.ceil((offset.x + buffer.width) / groundBitmap.bitmapData.width) - int(offset.x / groundBitmap.bitmapData.width);
			var repeatY:int = Math.ceil((offset.y + buffer.height) / groundBitmap.bitmapData.height) - int(offset.y / groundBitmap.bitmapData.height);
			
			//for (var i:int = 0; i < repeatX; ++ i) {
				for (var j:int = 0; j < repeatY; ++ j) {
					var rect:Rectangle = new Rectangle(0, 0, groundBitmap.bitmapData.width, groundBitmap.bitmapData.height);
//					buffer.copyPixels(groundBitmap.bitmapData, rect, new Point(startX + (i * groundBitmap.bitmapData.width), startY + (j * groundBitmap.bitmapData.height)));
					buffer.copyPixels(groundBitmap.bitmapData, rect, new Point(0 - offset.x, startY + (j * groundBitmap.bitmapData.height)));
				}
			//}
			return Level.QUEUE_RENDER + queue;
		}
		
		public function _render(viewRect:Rectangle, buffer:BitmapData, bufferRect:Rectangle):void
		{
			var m:Matrix = new Matrix();
			m.translate(0 - (viewRect.x % groundBitmap.width), 0 - (viewRect.y % groundBitmap.height));
			m.scale(bufferRect.width / viewRect.width, bufferRect.height / viewRect.height);
			buffer.draw(groundShape, m, null, null, null, true);
		}
	}
}