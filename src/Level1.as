package  
{
	import adobe.utils.CustomActions;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class Level1 extends Level
	{
		[Embed(source="../media/beep.mp3")]
		private static var BeepSound:Class;

		[Embed(source="../media/beep2.mp3")]
		private static var Beep2Sound:Class;

		[Embed(source="../media/win.mp3")]
		private static var WinSound:Class;
		
//		public static var req:URLRequest = new URLRequest("desertrally.mp3");
//		public static var music:SoundChannel;
		[Embed(source="../media/desertrally.mp3")]
		private static var Music:Class;
		public static var music:SoundChannel;

		public static const LEVEL_WIDTH:uint = 1000;
		public static const LEVEL_HEIGHT:uint = 15000;	
		public static const START_LINE:uint = LEVEL_HEIGHT - 300;
		public static const FINISH_LINE:uint = 300;

		private var ground:Ground = new Ground();
		private const NUM_CARS:int = 4;
		private var cars:Array;
		public const NUM_HILLS:uint = 100;
		public const NUM_CONES:uint = 150;
		
		private var hills:Array = new Array();
		private var cones:Array = new Array();
		
		private var humanDriver:HumanDriver;
		private var aiDrivers:Array = new Array();
		
		private var countDown:Number = 5;
		
		private var startLine:StartLine = new StartLine(0, START_LINE, LEVEL_WIDTH, 100, ground);
		private var finishLine:FinishLine = new FinishLine(0, FINISH_LINE, LEVEL_WIDTH, 100, ground);
		
		public var winners:int = 0;
		public var martaba:int = 0;
		public var winTime:Number = 0;
		public var winSound:Sound = new WinSound();
		public var beepSound:Sound = new BeepSound();
		public var beep2Sound:Sound = new Beep2Sound();
		
		public var bar:Bar;
		public function Level1()
		{
			createHills(NUM_HILLS);
		}

		public override function enterLevel():void
		{
			this.clearQueues();
			this.addGameObject(ground, Level.QUEUE_RENDER);
			for each (var h:Hill in hills) {
				this.addGameObject(h, Level.QUEUE_EVENT | (Level.QUEUE_RENDER + 1));
			}
			addGameObject(startLine, QUEUE_RENDER + 1);
			addGameObject(finishLine, QUEUE_EVENT | QUEUE_RENDER + 1);
			createCones(150);
			
			createCars();
			resetCars();
			countDown = 5;
			martaba = 0;
			winTime = 0;
			winners = 0;
			//music = new Sound(req).play(0, 1);
			music = new Music().play();
			initViewRect();
		}
		
		private function initDrivers():void
		{
			for (var i:int = 0; i < NUM_CARS; ++ i) {
				cars[i].off = false;
				if (i == Main.getInstance().selection) {
					humanDriver = new HumanDriver(cars[i]);
					this.addGameObject(humanDriver, QUEUE_EVENT);
				}
				else {
					var d:AIDriver = new AIDriver(cars[i]);
					aiDrivers.push(d);
					addGameObject(d, QUEUE_EVENT | QUEUE_UPDATE);
				}
			}
		}
		
		private function killDrivers():void
		{
			if (humanDriver) {
				this.removeGameObject(humanDriver);
				humanDriver = null;
			}
			
			for each (var d:AIDriver in aiDrivers) {
				this.removeGameObject(d);
			}
			aiDrivers = new Array();
		}
		
		public override function exitLevel():void
		{
			//music.stop();
			killDrivers();
		}
		
		private function resetCars():void
		{
			var space:Number = 100;
			
			for (var i:int = 0; i < cars.length; ++ i) {
				cars[i].x = (LEVEL_WIDTH - (space * (cars.length - 1))) * 0.5 + (i * space);
				cars[i].y = startLine.y + startLine.height + 40;
				cars[i].rot = Math.PI * -0.5;
				cars[i].speed = 0;
				cars[i].acc = 0;
				cars[i].rotSpeed = 0;
				cars[i].rotAcc = 0;
				bar.addCar(cars[i]);
			}
		}
		
		private function createCars():void
		{
			bar = new Bar(0, 0, START_LINE, FINISH_LINE);
			cars = new Array(NUM_CARS);
			
			for (var i:int = 0; i < NUM_CARS; ++ i) {
				var red:Number = 1.0;
				var green:Number = 1.0;
				var blue:Number = 1.0;
				
				if (i == 0 && Main.getInstance().selection == i) {
					red = 0.9490196078431373;
					green = 0.3607843137254902;
					blue = 0.2666666666666667;
				}
				else if (i == 1 && Main.getInstance().selection == i) {
					red = 1.0;
					green = 0.4666666666666667;
					blue = 0.8235294117647059;
				}
				else if (i == 2 && Main.getInstance().selection == i) {
					red = 0.4941176470588235;
					green = 0.4117647058823529;
					blue = 0.3058823529411765;
				}
				else if (i == 3 && Main.getInstance().selection == i) {
					red = 0.7372549019607843;
					green = 0.7411764705882353;
					blue = 0.0901960784313725;
				}
				
				var c:Car = new Car(0, 0, 0 - Math.PI * 0.5, red, green, blue);
				cars[i] = c;
				addGameObject(c, QUEUE_EVENT | QUEUE_UPDATE + 4);
			}
			addGameObject(bar, QUEUE_RENDER + 5);
		}
		
		private function createHills(count:int):void
		{
			while (count > 0) {
				var width:Number = 250 + int(Math.random() * 100);
				var height:Number = width;
				var x:Number = int(Math.random() * (LEVEL_WIDTH )) - (width * 0.5);
				var y:Number = 400 + int(Math.random() * ((LEVEL_HEIGHT - 800) - height));
				if (testHillPosition(x, y, width, height)) {
					var hill:Hill = new Hill(x, y, width, height, ground);
					hills.push(hill);
					-- count;
				}
			}
		}
		
		private function createCones(count:int):void
		{
			while (count > 0) {
				var x:Number = int(Math.random() * (LEVEL_WIDTH )) - (Cone.coneBitmap.width * 0.5);
				var y:Number = 400 + int(Math.random() * ((LEVEL_HEIGHT - 800) - Cone.coneBitmap.height));
				if (testHillPosition(x, y, 1, 1)) {
					if (testConePosition(x, y, 100)) {
						var cone:Cone = new Cone(x, y);
						cones.push(cone);
						this.addGameObject(cone, Level.QUEUE_EVENT | (Level.QUEUE_RENDER + 1));
						-- count;
					}
				}
			}
		}
		
		private function testHillPosition(x:Number, y:Number, width:Number, height:Number):Boolean
		{
			for each (var hill:Hill in hills) {
				if (x > (hill.x + hill.width) || (x + width) < hill.x
					|| y > (hill.y + hill.height) || (y + height) < hill.y)
					continue;
				return false;
			}
			return true;
		}
		
		private function testConePosition(x:Number, y:Number, dist:Number):Boolean
		{
			for each (var c:Cone in cones) {
				var d:Number = Math.pow((x - c.x), 2) + Math.pow((y - c.y), 2);
				if (d >= (dist * dist))
					continue;

				return false;
			}
			return true;
		}

		public override function update(dTime:Number):void
		{
			if (countDown > 0) {
				var prevCount:Number = countDown;
				countDown -= dTime;
				if (martaba > 0) {
					if (countDown <= 0) {
						Main.getInstance().changeLevel("winScreen");
					}
				}
				else {
					if (prevCount > 3 && countDown <= 3) {
						this.addGameObject(new DisposableText("3", 250, 100, 100, 0xffffffff, 4), QUEUE_RENDER + 7);
						beepSound.play(0, 1);
					}
					else if (prevCount > 2 && countDown <= 2) {
						this.addGameObject(new DisposableText("2", 250, 100, 100, 0xffffffff, 4), QUEUE_RENDER + 7);
						beepSound.play(0, 1);
					}
					else if (prevCount > 1 && countDown <= 1) {
						this.addGameObject(new DisposableText("1", 250, 100, 100, 0xffffffff, 4), QUEUE_RENDER + 7);
						beepSound.play(0, 1);
					}
					else if (prevCount > 0 && countDown <= 0) {
						this.addGameObject(new DisposableText("إنطلاق", 190, 100, 100, 0xffffffff, 2), QUEUE_RENDER + 7);
						beep2Sound.play(0, 1);
						initDrivers();
					}
				}
			}
			winTime += dTime;
			super.update(dTime);
		}
		
		private function initViewRect():void
		{
			var h:Number = 400;
			var w:Number = 550;
			
			var focusX:Number = LEVEL_WIDTH * 0.5;
			var focusY:Number = START_LINE;

			viewRect.x = focusX - (w * 0.5);
			viewRect.y = focusY - (h * 0.5);
			viewRect.width = w;
			viewRect.height = h;
		}
		
		private function updateViewRect(c:Car):void
		{
			var h:Number = 400;
			var w:Number = 550;
			
			var focusX:Number = (c.x + (Math.cos(c.rot) * (50 + c.speed * 30))) - (w * 0.5);
			var focusY:Number = (c.y + (Math.sin(c.rot) * (50 + c.speed * 30))) - (h * 0.5);
			if (focusX < 0)
				focusX = 0;
			
			if (focusY < 0)
				focusY = 0;
				
			if (focusX > LEVEL_WIDTH - w)
				focusX = LEVEL_WIDTH - w;
			
			if (focusY > LEVEL_HEIGHT - h)
				focusY = LEVEL_HEIGHT - h;
			
			viewRect.x += (focusX - viewRect.x) * 0.04;
			viewRect.y += (focusY - viewRect.y) * 0.04;
			viewRect.width += (w - viewRect.width) * 0.04;
			viewRect.height += (h - viewRect.height) * 0.04;
		}
		public override function render(buffer:BitmapData, rect:Rectangle):void
		{
			if (countDown <= 0) {
				var focusCar:int = Main.getInstance().selection;
				updateViewRect(cars[focusCar]);
			}
			
			buffer.lock();
			renderGameObjects(viewRect, buffer, rect);
			buffer.unlock();
		}
		
		public override function keyDown(keyCode:int):void
		{
			if (keyCode == Keyboard.ESCAPE) {
				killDrivers();
				//music.stop();
				music.stop();
				Main.getInstance().changeLevel("mainScreen");
			}
			else {
				super.keyDown(keyCode);
			}
		}
		
		public override function dispatchEvent(eventType:String, args:Object):Object
		{

			if (eventType == "declareWinner") {
				for (var i:uint = 0; i < cars.length; ++ i) {
					if (args.car == cars[i] && (winners & Math.pow(2, i)) == 0) {
						++ martaba;
						if (args.car == humanDriver.car) {
							winSound.play(0, 1);
							Main.getInstance().martaba = martaba;
							Main.getInstance().winTime = winTime;
							countDown = 2;
						}
						winners |= Math.pow(2, i);
					}
				}
			}
			return super.dispatchEvent(eventType, args);
		}

	}
}