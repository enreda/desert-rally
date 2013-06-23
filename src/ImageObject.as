package  
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class ImageObject extends GameObject
	{
		private var img:DisplayObject;
		public var x:Number = 0;
		public var y:Number = 0;
		
		public function ImageObject(_img:DisplayObject, _x:Number = 0, _y:Number = 0)
		{
			img = _img;
			x = _x;
			y = _y;
		}
		
		public override function render(viewRect:Rectangle, buffer:BitmapData, bufferRect:Rectangle, queue:uint):uint
		{
			var mat:Matrix = new Matrix();
			mat.translate(x - viewRect.x, y - viewRect.y);
			mat.scale(bufferRect.width / viewRect.width, bufferRect.height / viewRect.height);
			mat.translate(bufferRect.x, bufferRect.y);
			buffer.draw(img, mat);
			
			return Level.QUEUE_RENDER + queue;
		}
	}
}