package  
{
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.filters.ConvolutionFilter;
	import flash.text.engine.GroupElement;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class ParticleEmitter extends GameObject
	{		
		public var speed:Number = 0;
		public var speedVariance:Number = 0;
		public var direction:Number = 0;
		public var directionVariance:Number = 0;
		public var rotationSpeed:Number = 0;
		public var rotationSpeedVariance:Number = 0;
		public var scaleSpeed:Number = 0;
		public var scaleSpeedVariance:Number = 0;
		public var alphaSpeed:Number = 0;
		public var alphaSpeedVariance:Number = 0;
		
		public var initX:Number;
		public var initY:Number;
		public var initScale:Number = 1;
		public var initRot:Number;
		public var initAlpha:Number;
		
		
		public var rate:Number = 50;
		private var counter:Number = 0;
		
		private var level:Level;
		private var queue:uint = 1;
		
		public var image:Bitmap;
		
		public override function handleAdded(_level:Level, _queue:uint):uint
		{
			level = _level;
			queue = _queue & Level.QUEUE_WIDTH;
			return Level.QUEUE_UPDATE + (Level.QUEUE_WIDTH & _queue);
		}
		
		public function ParticleEmitter(_image:Bitmap, _x:Number, _y:Number)
		{
			image = _image;
			initX = _x;
			initY = _y;
		}
		
		public override function update(dTime:Number, _queue:uint):uint
		{
			counter += dTime * rate;
			while (counter >= 1) {
				-- counter;
				var dir:Number = direction + (Math.random() * directionVariance);
				var spd:Number = speed + (Math.random() * speedVariance);

				level.addGameObject(new Particle(image
						, initX, Math.cos(dir) * speed
						, initY, Math.sin(dir) * speed
						, initRot, rotationSpeed + (Math.random() * rotationSpeedVariance)
						, initScale, scaleSpeed + (Math.random() * scaleSpeedVariance)
						, initAlpha, alphaSpeed + (Math.random() * alphaSpeedVariance))
					, queue);
			}
			
			return Level.QUEUE_UPDATE + queue;
		}
	}
	
}