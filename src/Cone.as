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
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class Cone extends GameObject
	{
		[Embed(source="../media/hitcone.mp3")]
		private static var HitSound:Class;
		public static var hitSound:Sound = new HitSound();

		[Embed(source = "../media/cone.png")]
		public static var ConeBitmap:Class;
		
		public static var coneBitmap:Bitmap = new ConeBitmap();

		public var x:Number;
		public var y:Number;
		
		
		
		public function Cone(x:Number, y:Number)
		{
			this.x = x;
			this.y = y;
		}
		
		public override function render(viewRect:Rectangle, buffer:BitmapData, bufferRect:Rectangle, queue:uint):uint
		{
			var mat:Matrix = new Matrix();
			mat.translate((x - viewRect.x) - coneBitmap.width / 2, (y - viewRect.y) - coneBitmap.height / 2);
			
			buffer.draw(coneBitmap, mat);
			
			if (deleteIt)
				return 0;
			
			return Level.QUEUE_RENDER + queue;
		}
		
		public override function handleEvent(eventType:String, args:Object, rValue:Object):uint
		{
			if (eventType == "testCollision") {
				var maxDist:Number = 25;
				var dist:Number = Math.pow((x - args.x), 2) + Math.pow((y - args.y), 2);
				if (dist < maxDist * maxDist) {
					this.deleteIt = true;
					hitSound.play(0, 0);
					rValue.cone = true;
					return 0;
				}
			}
			return Level.QUEUE_EVENT;
		}
	}
}