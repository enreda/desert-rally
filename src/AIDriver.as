package  
{
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class AIDriver extends GameObject
	{
		private var car:Car;
		private var level:Level;
		
		private var destY:Number = 99999;
		private var destX:Number;
		private var destPoints:Number;
		
		
		public function AIDriver(_car:Car) 
		{
			car = _car;
			//destX = car.x;
			//destY = car.y;
		}
		
		public override function handleAdded(_level:Level, queue:uint):uint
		{
			level = _level;
			return queue | Level.QUEUE_EVENT;
		}
		
		public function beam(x:Number, y:Number, dir:Number, numSteps:int, stepLength:Number):Number
		{
			var points:Number = 0 - (Math.sin(dir) * numSteps * stepLength);
			
			for (var i:int = 2; i <= numSteps; ++ i) {
				var posX:Number = x + Math.cos(dir) * i * stepLength;
				var posY:Number = y + Math.sin(dir) * i * stepLength;
				var n:Number = level.dispatchEvent("testHeight", { x:posX, y:posY } ).height as Number;
				if (n > 0)
					points -= n * 400;
			}
			return points;
		}
		
		public override function update(dTime:Number, queue:uint):uint
		{
			var points:Number = -9999;
			var dist:Number = Math.pow(destX - car.x, 2) + Math.pow(destY - car.y, 2);
			var dir:Number;
			
			if (car.y < destY + 50) {
				for (dir = car.rot - (Math.PI * 0.30); dir <= car.rot + (Math.PI * 0.30); dir += (Math.PI * 0.05)) {
					var tempX:Number = car.x + Math.cos(dir) * 4 * 30;
					if (tempX > 20 && tempX < Level1.LEVEL_WIDTH - 30) {
						var n:Number = beam(car.x, car.y, dir, 4, 30);
						//n += Math.abs(dir - car.rot) * 10;
						if (n > points) {
							destX = car.x + Math.cos(dir) * 4 * 30;
							destY = car.y + Math.sin(dir) * 4 * 30;
							points = n;
						}
					}
				}
				destPoints = points;
			}
			else {
				dir = Math.atan2(destY - car.y, destX - car.x);
	//			var diff:Number = Math.abs(dir - car.rot)
//				car.rot += (dir - car.rot) * 0.05;

				if (dir > car.rot + 0.1) {
					car.rotAcc = 0.03;
				}
				else if (dir < car.rot - 0.1) {
					car.rotAcc = -0.03;
				}
				else {
					car.rotAcc = 0;
				}
				car.acc = 12.0 - (car.rotAcc * 80);
			}
			
			return Level.QUEUE_UPDATE;
		}
	}
}