package  
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.IBitmapDrawable;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class Particle extends GameObject
	{
/*
		[Embed(source = "../media/dust.png")]
		public static var DustBitmap:Class;
		
		public static var dustBitmap:Bitmap = new DustBitmap();
	*/	
		public var particleImage:Bitmap;
		
		public var x:Number;
		public var y:Number;
		public var rot:Number;
		public var scale:Number;
		public var alpha:Number;
		
		public var xSpeed:Number;
		public var ySpeed:Number;
		public var rotSpeed:Number;
		public var scaleSpeed:Number;
		public var alphaSpeed:Number;
		
		private var queue:uint = 1;
		//private var mat:Matrix;
		
		public function Particle(image:Bitmap
				, _x:Number, _xSpeed:Number
				, _y:Number, _ySpeed:Number
				, _rot:Number, _rotSpeed:Number
				, _scale:Number, _scaleSpeed:Number
				, _alpha:Number, _alphaSpeed:Number)
		{
			particleImage = image;
			
			x = _x;
			xSpeed = _xSpeed;
			
			y = _y;
			ySpeed = _ySpeed;
			
			rot = _rot;
			rotSpeed = _rotSpeed;
			
			scale = _scale;
			scaleSpeed = _scaleSpeed;
			
			alpha = _alpha;
			alphaSpeed = _alphaSpeed;
		}
		
		public override function handleAdded(level:Level, _queue:uint):uint
		{
			queue = _queue & Level.QUEUE_WIDTH;
			return Level.QUEUE_UPDATE + queue;
		}
		
		public override function update(dTime:Number, _queue:uint):uint
		{
			alpha += alphaSpeed * dTime;

			if (alpha < 0.1 || alpha > 1)
				return 0;

			x += xSpeed * dTime;
			y += ySpeed * dTime;
			rot += rotSpeed * dTime;
			scale += scale>2?0:(scaleSpeed * dTime);
			
			//return Level.QUEUE_RENDER + int(((1.0 - alpha) * 2) + queue);

			return Level.QUEUE_RENDER + queue;
		}
		
		public override function render(viewRect:Rectangle, buffer:BitmapData, bufferRect:Rectangle, _queue:uint):uint
		{
			var mat:Matrix = new Matrix();
			
			mat.translate(particleImage.bitmapData.width * -0.5, particleImage.bitmapData.height * -0.5);
			mat.rotate(rot);
			mat.scale(scale, scale)
			mat.translate(x - viewRect.x, y - viewRect.y);
			mat.scale(bufferRect.width / viewRect.width, bufferRect.height / viewRect.height);
			mat.translate(bufferRect.x, bufferRect.y);
			
			buffer.draw(particleImage, mat, new ColorTransform(1, 1, 1, alpha));
			return Level.QUEUE_UPDATE + queue;
		}
	}
	
}