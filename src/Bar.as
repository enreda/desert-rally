package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.Shader;
	import flash.display.Shape;
	import flash.filters.DropShadowFilter;
	import flash.filters.ShaderFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class Bar extends GameObject
	{
		[Embed(source = "../media/bar.png")]
		public static var BarBitmap:Class;
		
		public static var barBitmap:Bitmap = new BarBitmap();
		
		private var level:Level;
		
		private var updateQueue:uint = 0;
		
		private var x:Number;
		private var y:Number;
		
		public var cars:Array = new Array();
		
		private var carBlinkTime:Number = 0;
		
		private var startLine:Number;
		private var finishLine:Number;
		
		public function Bar(x:Number, y:Number, startLine:Number, finishLine:Number)
		{
			this.x = x;
			this.y = y;
			this.startLine = startLine;
			this.finishLine = finishLine;
		}
		
		public function addCar(c:Car):void
		{
			cars.push(c);
		}
				
		public override function handleEvent(type:String, args:Object, rValue:Object):uint
		{
			return Level.QUEUE_EVENT;
		}
		
		public override function render(viewRect:Rectangle, buffer:BitmapData, bufferRect:Rectangle, queue:uint):uint
		{
			var xx:Number = 10.0;
			var yy:Number = (400 - barBitmap.height) * 0.5;

			var m:Matrix = new Matrix();
			m.translate(0, yy);
			buffer.draw(barBitmap, m);
			
			for each (var c:Car in cars) {
				var mat:Matrix = new Matrix();
				mat.translate(Number(c.getDefaultImage().width) * -0.5, Number(c.getDefaultImage().height) * -0.5);
				mat.rotate(Math.PI * -0.5);
				mat.scale(0.2, 0.2);
				mat.translate(xx, (yy + (barBitmap.height * 0.05))+ ((c.y - finishLine) / (startLine - finishLine)) * (barBitmap.height * 0.9));
				//mat.translate(xx, yy + barBitmap.y + barBitmap.he(finishLine - y)int(((c.y - startLine) / (finishLine - startLine)) * barBitmap.height));
				buffer.draw(c.getDefaultImage(), mat, null, null, null, true);
				xx += 10;
			}
			return Level.QUEUE_RENDER + queue;
		}
	}
}