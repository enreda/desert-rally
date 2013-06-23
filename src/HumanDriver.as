package  
{
	import flash.media.Sound;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class HumanDriver extends GameObject
	{
		public var car:Car;

		[Embed(source="../media/car.mp3")]
		private static var CarSound:Class;
		
		private static var carSound:Sound = new CarSound();
		
		public function HumanDriver(_car:Car) 
		{
			car = _car;
		}
		
		public override function handleEvent(eventType:String, args:Object, rValue:Object):uint
		{
			if (eventType == "keyDown" && args.keyCode == Keyboard.UP) {
				//car.acc += 15.0;
				car.acc = 12.0;
				carSound.play(0, 1);
			}
			else if (eventType == "keyUp" && args.keyCode == Keyboard.UP) {
				//car.acc -= 15.0;
				car.acc = 0;
			}
			if (eventType == "keyDown" && args.keyCode == Keyboard.DOWN) {
				//car.acc -= 15.0;
				car.acc = -8.0;
			}
			else if (eventType == "keyUp" && args.keyCode == Keyboard.DOWN) {
				//car.acc += 15.0;
				car.acc = 0.0;
			}
			if (eventType == "keyDown" && args.keyCode == Keyboard.LEFT) {
				//car.rotAcc -= 0.03;
				car.rotAcc -= 0.03;
			}
			else if (eventType == "keyUp" && args.keyCode == Keyboard.LEFT) {
				car.rotAcc += 0.03;
			}
			if (eventType == "keyDown" && args.keyCode == Keyboard.RIGHT) {
				car.rotAcc += 0.03;
			}
			else if (eventType == "keyUp" && args.keyCode == Keyboard.RIGHT) {
				car.rotAcc -= 0.03;
			}
			return Level.QUEUE_EVENT;
		}
	}
	
}