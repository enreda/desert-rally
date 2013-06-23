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
	public class Car extends GameObject
	{
		[Embed(source="../media/horn.mp3")]
		private static var HornSound:Class;
		public static var hornSound:Sound = new HornSound();
		public static var hornTimeout:Number = 0.5;
		
		[Embed(source = "../media/car2.png")]
		public static var CarBitmap:Class;
		
		[Embed(source = "../media/carAlpha.png")]
		public static var CarAlphaBitmap:Class;
		
		[Embed(source = "../media/dust.png")]
		public static var DustBitmap:Class;
		
//		[Embed(source = "../media/track.png")]
//		public static var TrackBitmap:Class;
		
		[Embed(source="../shaders/carpaint.pbj", mimeType="application/octet-stream")]
		public static var CarPaintShader:Class;

		public static var carBitmap:BitmapData;
		
		private static const NUM_ROLL_FRAMES:uint = 11;
		private static const NUM_PITCH_FRAMES:uint = 21;
		private var carFrames:Array;
		
		private var prevSpeed:Number = 0;
		private var prevRot:Number = 0;
		private var roll:Number = 0;
		private var pitch:Number = 0;
		
		public static var dustBitmap:Bitmap = new DustBitmap();
//		public static var trackBitmap:Bitmap = new TrackBitmap();
		private static var shadowBitmap:BitmapData;

		public var speed:Number = 0;
		public var acc:Number = 0;
		public var rotSpeed:Number = 0;
		public var rotAcc:Number = 0;
		public const MAX_ROTATION:Number = Math.PI * 0.25;
		
		public var x:Number = 0;
		public var y:Number = 0;
		public var rot:Number = 0;
		
		private var dustEmitter:ParticleEmitter;
		//private var leftTrackEmitter:ParticleEmitter;
		//private var rightTrackEmitter:ParticleEmitter;
		
		private var level:Level;
		
		private var tracksQueue:uint = 1;
		private var shadowQueue:uint = 2;
		private var dustQueue:uint = 3;
		private var carQueue:uint = 4;
		
		private var updateQueue:uint = 0;
		
		public var red:Number;
		public var green:Number;
		public var blue:Number;
		
		private var hitCone:Boolean = false;
		public var off:Boolean = false;
		
		public function Car(_x:Number, _y:Number, _rot:Number, red:Number, green:Number, blue:Number)
		{
			if (carBitmap == null)
				generateSourceBitmap();
			
			x = _x;
			y = _y;
			this.red = red;
			this.green = green;
			this.blue = blue;
			rot = _rot;
			prevRot = rot;
			prevSpeed = speed;
			
			var frameWidth:int = carBitmap.width / NUM_ROLL_FRAMES;
			var frameHeight:int = carBitmap.height / NUM_PITCH_FRAMES;
			
			var shader:Shader = new Shader(new CarPaintShader());
			shader.data.paint.value = [red, green, blue, 1.0];

			var shaderFilter:ShaderFilter = new ShaderFilter(shader);
			shaderFilter.topExtension = 0;
			shaderFilter.bottomExtension = 0;
			shaderFilter.leftExtension = 0;
			shaderFilter.rightExtension = 0;
			
			var newImg:BitmapData = new BitmapData(carBitmap.width, carBitmap.height, true, 0);
			newImg.applyFilter(carBitmap, new Rectangle(0, 0, carBitmap.width, carBitmap.height)
				, new Point(0, 0), shaderFilter);
			
			carFrames = new Array();
			for (var i:uint = 0; i < NUM_PITCH_FRAMES; ++ i) {
				var a:Array = new Array();
				for (var j:uint = 0; j < NUM_ROLL_FRAMES; ++ j) {
					var frame:BitmapData = new BitmapData(frameWidth, frameHeight, true, 0);
					var mat:Matrix = new Matrix();
					mat.translate(0 - (frameWidth * j), 0 - (frameHeight * i));
					frame.draw(newImg, mat, null, null, new Rectangle(0, 0, frameWidth, frameHeight), true);
					a.push(frame);
				}
				carFrames.push(a);
			}
			newImg.dispose();
		}
		
		private static function generateSourceBitmap():void
		{
			var bitmap:Bitmap = new CarBitmap();
			var alpha:Bitmap = new CarAlphaBitmap();
			carBitmap = new BitmapData(bitmap.bitmapData.width, bitmap.bitmapData.height, true, 0);
			Car.carBitmap.copyPixels(bitmap.bitmapData, new Rectangle(0, 0, carBitmap.width, carBitmap.height)
				, new Point(0, 0), alpha.bitmapData, new Point(0, 0));
			carBitmap.copyChannel(alpha.bitmapData, new Rectangle(0, 0, carBitmap.width, carBitmap.height), new Point(0, 0), 1, 8);
			shadowBitmap = generateShadowBitmap(carBitmap);
		}
		
		private static function generateShadowBitmap(obj:BitmapData):BitmapData
		{
			var f:DropShadowFilter = new DropShadowFilter(0, 45, 0, 0.5, 8, 8, 1, 1, false, false, true);
			//var filters:Array = [f];
//			obj.filters = filters;
			
			var b:BitmapData = new BitmapData(obj.width / NUM_ROLL_FRAMES, obj.height / NUM_PITCH_FRAMES);
//			b.applyFilter(obj, new Rectangle(0, obj.height * NUM_PITCH_FRAMES * 0.5, b.width, b.height)
//				, new Point(0, 0), f);
			b.applyFilter(obj, new Rectangle(b.width, b.height * int(NUM_PITCH_FRAMES / 2), b.width, b.height)
				, new Point(0, 0), f);
			//var mat:Matrix = new Matrix();
			//mat.translate(0, b.height * int(NUM_PITCH_FRAMES / 2));
			//b.draw(obj);
			//obj.filters = null;
			return b;
		}
		
		public override function handleAdded(_level:Level, queue:uint):uint
		{
			this.level = _level;
			
			carQueue = queue & Level.QUEUE_WIDTH;
			dustQueue = carQueue - 1;
			shadowQueue = dustQueue - 1;
			tracksQueue = shadowQueue - 1;
			
			// dust emitter
			dustEmitter = new ParticleEmitter(dustBitmap, x, y);
			dustEmitter.directionVariance = 0.4;
			dustEmitter.speed = 0;
			dustEmitter.speedVariance = 0;

			dustEmitter.initAlpha = 0.8;
			dustEmitter.alphaSpeed = -1;
			dustEmitter.alphaSpeedVariance = -0.6;
			
			dustEmitter.initScale = 0.5;
			dustEmitter.scaleSpeed = 3;
			dustEmitter.scaleSpeedVariance = 3;

			dustEmitter.initRot = 0;
			dustEmitter.rotationSpeed = -6;
			dustEmitter.rotationSpeedVariance = 12;
			
/*
			// left track emitter
			leftTrackEmitter = new ParticleEmitter(trackBitmap, x, y);
			leftTrackEmitter.directionVariance = 0;
			leftTrackEmitter.scaleSpeed = 0;
			leftTrackEmitter.scaleSpeedVariance = 0;
			leftTrackEmitter.rotationSpeed = 0;
			leftTrackEmitter.rotationSpeedVariance = 0;
			leftTrackEmitter.speed = 0;
			leftTrackEmitter.speedVariance = 0;
			leftTrackEmitter.initAlpha = 1;
			leftTrackEmitter.alphaSpeed = -0.2;
			
			// right track emitter
			rightTrackEmitter = new ParticleEmitter(trackBitmap, x, y);
			rightTrackEmitter.directionVariance = 0;
			rightTrackEmitter.scaleSpeed = 0;
			rightTrackEmitter.scaleSpeedVariance = 0;
			rightTrackEmitter.rotationSpeed = 0;
			rightTrackEmitter.rotationSpeedVariance = 0;
			rightTrackEmitter.speed = 0;
			rightTrackEmitter.speedVariance = 0;
			rightTrackEmitter.initAlpha = 1;
			rightTrackEmitter.alphaSpeed = -0.2;
*/
			level.addGameObject(dustEmitter, dustQueue);
//			level.addGameObject(leftTrackEmitter, tracksQueue);
//			level.addGameObject(rightTrackEmitter, tracksQueue);
			
			return Level.QUEUE_EVENT | Level.QUEUE_UPDATE + updateQueue;
		}
		
		private function updateEmitters():void
		{
			dustEmitter.initX = x;
			dustEmitter.initY = y;
//			dustEmitter.direction = rotSpeed + (rot - (Math.PI));
//			dustEmitter.speed = rotSpeed * 50000;
			dustEmitter.rate = speed * 1;
			dustEmitter.direction = rot + Math.PI;
			dustEmitter.speed = Math.max(((acc * 0.4) - speed) * 70, 0);
			dustEmitter.rate += Math.max(((acc * 0.6) - speed) * 2, 0);

			if (dustEmitter.rate < 5)
				dustEmitter.rate = 0;
/*
			leftTrackEmitter.initX = x + (Math.cos(rot - (Math.PI + 0.7)) * 30);
			leftTrackEmitter.initY = y + (Math.sin(rot - (Math.PI + 0.7)) * 30);
			leftTrackEmitter.initRot = rot - (Math.PI);
			leftTrackEmitter.rate = speed * 1;

			rightTrackEmitter.initX = x + (Math.cos(rot - (Math.PI - 0.7)) * 30);
			rightTrackEmitter.initY = y + (Math.sin(rot - (Math.PI - 0.7)) * 30);
			rightTrackEmitter.initRot = rot - (Math.PI);
			rightTrackEmitter.rate = speed * 1;
*/
		}
		
		public override function update(dTime:Number, queue:uint):uint
		{
			if (off) {
				this.acc = 0.0;
				this.rotAcc = 0.0;
			}
			
			if (hornTimeout >= 0)
				hornTimeout -= dTime;
			
			if (queue == updateQueue) {
				var frontLeftTireX:Number = x + (Math.cos(rot - Math.PI * 0.2)) * 40;
				var frontLeftTireY:Number = y + (Math.sin(rot - Math.PI * 0.2)) * 40;
				var frontRightTireX:Number = x + (Math.cos(rot + Math.PI * 0.2)) * 40;
				var frontRightTireY:Number = y + (Math.sin(rot + Math.PI * 0.2)) * 40;
				
				var backLeftTireX:Number = x + (Math.cos(rot - Math.PI * 0.8)) * 40;
				var backLeftTireY:Number = y + (Math.sin(rot - Math.PI * 0.8)) * 40;
				var backRightTireX:Number = x + (Math.cos(rot + Math.PI * 0.8)) * 40;
				var backRightTireY:Number = y + (Math.sin(rot + Math.PI * 0.8)) * 40;
				
				var heightLeftFront:Number = level.dispatchEvent("testHeight", { x:frontLeftTireX, y:frontLeftTireY }).height as Number;
				var heightRightFront:Number = level.dispatchEvent("testHeight", { x:frontRightTireX, y:frontRightTireY }).height as Number;
				var heightLeftBack:Number = level.dispatchEvent("testHeight", { x:backLeftTireX, y:backLeftTireY }).height as Number;
				var heightRightBack:Number = level.dispatchEvent("testHeight", { x:backRightTireX, y:backRightTireY }).height as Number;
				
				var verticalDiff:Number = ((heightLeftBack + heightRightBack) - (heightLeftFront + heightRightFront)) * 0.5;
				var horizontalDiff:Number = ((heightRightFront + heightRightBack) - (heightLeftFront + heightLeftBack)) * 0.5;
				
				pitch = verticalDiff ;
				roll = horizontalDiff;
				
				var frictionAcc:Number = speed * -1.6;
				var gravityAcc:Number = (verticalDiff * 20.0);
				if (gravityAcc > 0)
					gravityAcc *= 0.3;
				
				speed += (acc + frictionAcc + gravityAcc) * dTime;
				
				if (hitCone) {
					speed *= 0.4;
					hitCone = false;
				}
				
				var antiRotAcc:Number = (rotSpeed * -0.01) + (rotSpeed * Math.abs(speed) * -0.01);
				rotSpeed += rotAcc + antiRotAcc;
				
				x += Math.cos(rot) * speed;
				y += Math.sin(rot) * speed;
				rot += rotSpeed * speed * dTime;
				
				roll += (rot - prevRot) * 7.0;
				
				prevRot = rot;
				prevSpeed = speed;
				
				testCollision(queue);
				updateEmitters();
			}
			return Level.QUEUE_RENDER + shadowQueue;
		}
		
		private function testCollision(q:uint):Boolean
		{
			if (x > Level1.LEVEL_WIDTH)
				x = Level1.LEVEL_WIDTH
			else if (x < 0)
				x = 0;
			
			var rValue:Object = level.dispatchEvent("testCollision", { x:x, y:y, queue:q, car:this } );
			if (rValue.cone == true) {
				//this.speed *= 0.3;
				this.hitCone = true;
			}
			else if (rValue.x > 0 && rValue.y > 0) {
				x += rValue.x;
				y += rValue.y;
				return true;
			}
			
			return false;
		}
		
		public override function handleEvent(type:String, args:Object, rValue:Object):uint
		{
			if (type == "testCollision" && args.car != this) {
				var maxDist:Number = 70;
				var dist:Number = Math.pow((x - args.x), 2) + Math.pow((y - args.y), 2);
				if (dist < maxDist * maxDist) {
					dist = Math.sqrt(dist);
					var angle:Number = Math.atan2(y - args.y, x - args.x);
					var _x:Number = Math.cos(angle) * (maxDist - dist) * -0.5;
					var _y:Number = Math.sin(angle) * (maxDist - dist) * -0.5;
					x += _x * -1.0;
					y += _y * -1.0;
					rValue.x = _x;
					rValue.y = _y;
					
					if (hornTimeout < 0) {
						hornSound.play(0, 1);
						hornTimeout = 2;
					}
					//return Level.QUEUE_EVENT | Level.QUEUE_UPDATE | (args.queue + 1);
				}
			}
			return Level.QUEUE_EVENT;
		}
		
		public function getDefaultImage():BitmapData
		{
			return carFrames[int(0.5 * NUM_PITCH_FRAMES)][0];
		}
		
		public override function render(viewRect:Rectangle, buffer:BitmapData, bufferRect:Rectangle, queue:uint):uint
		{
			var mat:Matrix = new Matrix();

			if (queue == shadowQueue) {
				mat.translate(shadowBitmap.width * -0.5, shadowBitmap.height * -0.5);
				mat.rotate(rot);
				mat.translate((x + 5) - viewRect.x, (y + 5) - viewRect.y);
			
				mat.scale(bufferRect.width / viewRect.width, bufferRect.height / viewRect.height);
				mat.translate(bufferRect.x, bufferRect.y);
				
				buffer.draw(shadowBitmap, mat, null, BlendMode.MULTIPLY, null, false);
				trace("test");
				return Level.QUEUE_RENDER + carQueue;
			}
			else if (queue == carQueue) {
				var pitchIndex:int = Math.round((0.5 + pitch) * NUM_PITCH_FRAMES);
				pitchIndex = Math.min(Math.max(pitchIndex, 0), NUM_PITCH_FRAMES - 1);
				var rollIndex:int = Math.round(Math.abs(roll * NUM_ROLL_FRAMES));
				rollIndex = Math.min(Math.max(rollIndex, 0), NUM_ROLL_FRAMES - 1);
				
				var cb:BitmapData = carFrames[pitchIndex][rollIndex];
				
				mat.translate(cb.width * -0.5, cb.height * -0.5);
				
				if (roll < 0)
					mat.scale(1, -1);
				mat.rotate(rot);
				mat.translate(x - viewRect.x, y - viewRect.y);
			
				mat.scale(bufferRect.width / viewRect.width, bufferRect.height / viewRect.height);
				mat.translate(bufferRect.x, bufferRect.y);
			
				buffer.draw(cb, mat, null, null, null, true);
				return Level.QUEUE_UPDATE + updateQueue;
			}
			
			/*
			// rendering tire positions
			var frontLeftTireX:Number = 0 + (Math.cos(rot - Math.PI * 0.2)) * 40;
			var frontLeftTireY:Number = 0 + (Math.sin(rot - Math.PI * 0.2)) * 40;
			var frontRightTireX:Number = 0 + (Math.cos(rot + Math.PI * 0.2)) * 40;
			var frontRightTireY:Number = 0 + (Math.sin(rot + Math.PI * 0.2)) * 40;
			
			var backLeftTireX:Number = 0 + (Math.cos(rot - Math.PI * 0.8)) * 40;
			var backLeftTireY:Number = 0 + (Math.sin(rot - Math.PI * 0.8)) * 40;
			var backRightTireX:Number = 0 + (Math.cos(rot + Math.PI * 0.8)) * 40;
			var backRightTireY:Number = 0 + (Math.sin(rot + Math.PI * 0.8)) * 40;
			
			var t:Shape = new Shape();
			t.graphics.beginFill(0);
			t.graphics.drawCircle(frontLeftTireX, frontLeftTireY, 3);
			t.graphics.drawCircle(frontRightTireX, frontRightTireY, 3);
			t.graphics.drawCircle(backLeftTireX, backLeftTireY, 3);
			t.graphics.drawCircle(backRightTireX, backRightTireY, 3);
			t.graphics.endFill();
			var mt:Matrix = new Matrix()
			mt.translate(x - viewRect.x, y - viewRect.y);
			mt.scale(bufferRect.width / viewRect.width, bufferRect.height / viewRect.height);
			buffer.draw(t, mt);
			*/
			return Level.QUEUE_UPDATE;
		}
	}
}