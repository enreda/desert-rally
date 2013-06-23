package  
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class MainScreen extends Level
	{
		[Embed(source="../media/engine_start.mp3")]
		private static var StartSound: Class;
		
		public var startSound:Sound = new StartSound();

		[Embed(source = "../media/assets.swf", symbol="MainScreenBackground")]
		public static var BackgroundSprite:Class;
	
		public function MainScreen():void
		{
			addGameObject(new ImageObject(new BackgroundSprite()), Level.QUEUE_RENDER);
			var t:String = "رالي الصحراء";
			addGameObject(new TextObject(t, 275, 65, 60, 0xffffffff, 0, false, "center"), Level.QUEUE_RENDER + 1);
			
			t = "طريقة اللعب";
			addGameObject(new TextObject(t, 530, 125, 30, 0xffffffff, 0, true), Level.QUEUE_RENDER + 1);

			t = "- إختر الشخصية بواسطة تحريك الأسهم";
			addGameObject(new TextObject(t, 530, 155, 20, 0xffffffff, 0, true), Level.QUEUE_RENDER + 1);
			
			t = "والضغط على زر المسافة.";
			addGameObject(new TextObject(t, 515, 180, 20, 0xffffffff, 0, true), Level.QUEUE_RENDER + 1);

			t = "- إستعد للإنطلاق والفوز.";
			addGameObject(new TextObject(t, 530, 205, 20, 0xffffffff, 0, true), Level.QUEUE_RENDER + 1);

			t = "- تحكم بواسطة الأسهم للأمام والجانبين.";
			addGameObject(new TextObject(t, 530, 230, 20, 0xffffffff, 0, true), Level.QUEUE_RENDER + 1);

			t = "- تجنب الأقماع أثناء الحركة.";
			addGameObject(new TextObject(t, 530, 255, 20, 0xffffffff, 0, true), Level.QUEUE_RENDER + 1);

			t = "- إحصل على نتيجتك والعب ثانية متحدي الآخرين.";
			addGameObject(new TextObject(t, 530, 280, 20, 0xffffffff, 0, true), Level.QUEUE_RENDER + 1);

			var hitEnter:TextObject = new TextObject("إضغط زر المسافة للبدأ", 275, 360, 24, 0xffffff, 3, false, "center");
			addGameObject(hitEnter, Level.QUEUE_RENDER + 1);
		}
		
		public override function update(dTime:Number):void
		{
			super.update(dTime);
		}
		
		public override function render(buffer:BitmapData, rect:Rectangle):void
		{
			super.render(buffer, rect);
		}
		
		public override function keyDown(keyCode:int):void
		{
			if (keyCode == Keyboard.SPACE) {
				Main.getInstance().changeLevel("selectionScreen");
				startSound.play(0, 1);
			}
			else {
				dispatchEvent("keyDown", { keyCode:keyCode } );
			}
		}
		
		public override function keyUp(keyCode:int):void
		{
			dispatchEvent("keyUp", { keyCode:keyCode } );
		}
	}
	
}