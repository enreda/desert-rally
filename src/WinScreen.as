package  
{
	import flash.display.BitmapData;
	import flash.display.ColorCorrection;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class WinScreen extends Level
	{
		[Embed(source = "../media/assets.swf", symbol="WinScreenBackground1")]
		public static var BackgroundSprite1:Class;
		
		[Embed(source = "../media/assets.swf", symbol="WinScreenBackground2")]
		public static var BackgroundSprite2:Class;

		[Embed(source = "../media/assets.swf", symbol="WinScreenBackground3")]
		public static var BackgroundSprite3:Class;

		[Embed(source = "../media/assets.swf", symbol="WinScreenBackground4")]
		public static var BackgroundSprite4:Class;
		
		public function WinScreen():void
		{
		}
		
		public override function enterLevel():void
		{
			clearQueues();
			if (Main.getInstance().selection == 0) {
				addGameObject(new ImageObject(new BackgroundSprite1()), Level.QUEUE_RENDER);
			}
			else if (Main.getInstance().selection == 1) {
				addGameObject(new ImageObject(new BackgroundSprite2()), Level.QUEUE_RENDER);
			}
			else if (Main.getInstance().selection == 2) {
				addGameObject(new ImageObject(new BackgroundSprite3()), Level.QUEUE_RENDER);
			}
			else if (Main.getInstance().selection == 3) {
				addGameObject(new ImageObject(new BackgroundSprite4()), Level.QUEUE_RENDER);
			}
			var hitEnter:TextObject = new TextObject("إضغط زر Esc للعودة", 275, 360, 24, 0xffffff, 1, true, "center");
			addGameObject(hitEnter, Level.QUEUE_RENDER + 1);
			
			var t:String;
			if (Main.getInstance().martaba == 1) {
				t = "ممتاز!";
				addGameObject(new TextObject(t, 500, 130, 24, 0xffffff, 0, true), Level.QUEUE_RENDER + 1);
				t = "لقد فزت بالمركز الأول.";
				addGameObject(new TextObject(t, 500, 170, 24, 0xffffff, 0, true), Level.QUEUE_RENDER + 1);
			}
			else if (Main.getInstance().martaba == 2) {
				t = "أحسنت.";
				addGameObject(new TextObject(t, 500, 130, 24, 0xffffff, 0, true), Level.QUEUE_RENDER + 1);
				t = "لقد فزت بالمركز الثاني.";
				addGameObject(new TextObject(t, 500, 170, 24, 0xffffff, 0, true), Level.QUEUE_RENDER + 1);
			}
			else if (Main.getInstance().martaba == 3) {
				t = "أحسنت.";
				addGameObject(new TextObject(t, 500, 130, 24, 0xffffff, 0, true), Level.QUEUE_RENDER + 1);
				t = "لقد فزت بالمركز الثالث.";
				addGameObject(new TextObject(t,500, 170, 24, 0xffffff, 0, true), Level.QUEUE_RENDER + 1);
			}
			else if (Main.getInstance().martaba == 4) {
				t = "أحسنت.";
				addGameObject(new TextObject(t, 500, 130, 24, 0xffffff, 0, true), Level.QUEUE_RENDER + 1);
				t = "لقد فزت بالمركز الرابع.";
				addGameObject(new TextObject(t, 500, 170, 24, 0xffffff, 0, true), Level.QUEUE_RENDER + 1);
			}
			
			t = "أنت بطل الصحراء.";
			addGameObject(new TextObject(t, 500, 210, 24, 0xffffff, 0, true), Level.QUEUE_RENDER + 1);
			
			// show time
			var winTime:Number = Main.getInstance().winTime;
			var minutes:Number = getMinutes(winTime);
			var seconds:Number = getSeconds(winTime);
			var time:String = "الوقت: ";
			if (minutes > 0) {
				if (minutes >= 3 && minutes <= 10)
					time += minutes.toString() + " دقائق و ";
				else
					time += minutes.toString() + " دقيقة و ";
			}
			if (seconds >= 3 && seconds <= 10)
				time += seconds.toString() + " ثواني.";
			else
				time += seconds.toString() + " ثانية.";
			addGameObject(new TextObject(time, 500, 250, 24, 0xffffff, 0, true), Level.QUEUE_RENDER + 1);
		}
		
		public override function update(dTime:Number):void
		{
			super.update(dTime);
		}
		
		public override function render(buffer:BitmapData, rect:Rectangle):void
		{
			buffer.fillRect(new Rectangle(0, 0, 550, 400), 0xffffffff);
			super.render(buffer, rect);
		}
		
		public override function keyDown(keyCode:int):void
		{
			if (keyCode == Keyboard.ESCAPE) {
				Main.getInstance().changeLevel("mainScreen");
			}
		}
		
		public override function exitLevel():void
		{
			Level1.music.stop();
		}
		
		private static function getMinutes(t:Number):Number
		{
			return Math.floor(t / 60.0);
		}
		
		private static function getSeconds(t:Number):Number
		{
			return Math.round(t - getMinutes(t));
		}
	}
}