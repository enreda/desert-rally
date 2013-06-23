package  
{
	import flash.display.BitmapData;
	import flash.display.ColorCorrection;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class SelectionScreen extends Level
	{
		[Embed(source="../media/door_close.mp3")]
		private static var DoorCloseSound:Class;
		private var doorCloseSound:Sound = new DoorCloseSound();

		[Embed(source="../media/click.mp3")]
		private static var ClickSound:Class;
		private var clickSound:Sound = new ClickSound();

		[Embed(source = "../media/assets.swf", symbol="SelectionScreenBackground")]
		public static var BackgroundSprite:Class;
		
		private var backGround:MovieClip = new BackgroundSprite();
		
		[Embed(source = "../media/assets.swf", symbol="Key")]
		public static var KeySprite:Class;
		
		private var key:ImageObject = new ImageObject(new KeySprite());
		
		private var selection:int = Math.random() * 4;
		
		public function SelectionScreen():void
		{
			backGround.gotoAndStop(1);
			//addGameObject(key, Level.QUEUE_RENDER + 1);
			addGameObject(new ImageObject(backGround), Level.QUEUE_RENDER);
			var t:String = "فريق عائلة كريم";
			addGameObject(new TextObject(t, 275, 65, 40, 0xffffffff, 0, false, "center"), Level.QUEUE_RENDER + 1);
			
			t = "كريم";
			addGameObject(new TextObject(t, 60, 330, 28, 0xffffff, 0, false, "ltr"), Level.QUEUE_RENDER + 1);

			t = "جميلة";
			addGameObject(new TextObject(t, 170, 330, 28, 0xffffff, 0, false, "ltr"), Level.QUEUE_RENDER + 1);
			
			t = "أبو كريم";
			addGameObject(new TextObject(t, 290, 330, 28, 0xffffff, 0, false, "ltr"), Level.QUEUE_RENDER + 1);

			t = "أم كريم";
			addGameObject(new TextObject(t, 450, 330, 28, 0xffffff, 0, false, "ltr"), Level.QUEUE_RENDER + 1);

			updateKeyPosition();
		}
		
		private function updateKeyPosition():void
		{
			key.y = 320;
			if (selection == 0) {
				backGround.gotoAndStop(1);
				key.x = 60;
			}
			else if (selection == 1) {
				backGround.gotoAndStop(2);
				key.x = 190;
			}
			else if (selection == 2) {
				backGround.gotoAndStop(3);
				key.x = 310;
			}
			else if (selection == 3) {
				backGround.gotoAndStop(4);
				key.x = 480;
			}
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
			if (keyCode == Keyboard.LEFT) {
				selection = Math.max(selection - 1, 0);
				updateKeyPosition();
				clickSound.play(0, 1);
			}
			else if (keyCode == Keyboard.RIGHT) {
				selection = Math.min(selection + 1, 3);
				updateKeyPosition();
				clickSound.play(0, 1);
			}
			else if (keyCode == Keyboard.SPACE) {
				Main.getInstance().selection = selection;
				Main.getInstance().changeLevel("level1");
				doorCloseSound.play(0, 1);
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