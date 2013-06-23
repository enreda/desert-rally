package 
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.media.Sound;

	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class Main extends Sprite 
	{
		private static var _instance:Main;
		private var buffer:BitmapData = new BitmapData(550, 400);
		private var darkRect:Shape = new Shape();
		private var pressedKeys:Array = new Array();
		
		private var mainScreen:MainScreen;
		private var selectionScreen:SelectionScreen;
		private var level1:Level;
		private var winScreen:WinScreen;
		
		private var currentLevel:Level;
		private var nextLevel:Level;
		
		private var shape:Sprite = new Sprite();
		
		public var selection:int;
		public var martaba:int;
		public var winTime:Number;
		
		public var fade:Number = 1;
		
		public static function getInstance():Main
		{
			if (_instance == null) {
				_instance = new Main();
			}
			
			return _instance;
		}
		
		public function Main():void 
		{
			_instance = this;
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			
			this.graphics.clear();
			this.graphics.beginBitmapFill(buffer, null, false, false);
			this.graphics.drawRect(0, 0, buffer.width, buffer.height);
			this.graphics.endFill();
			
			darkRect.graphics.beginFill(0);
			darkRect.graphics.drawRect(0, 0, 550, 400);
			darkRect.graphics.endFill();
			
			//level1 = new Level1();
			mainScreen = new MainScreen();
			selectionScreen = new SelectionScreen();
			level1 = new Level1();
			winScreen = new WinScreen();
			currentLevel = mainScreen;
			
			currentLevel.enterLevel();
			
			this.addChild(shape);
		}
		
		public function changeLevel(l:String):void
		{
			if (l == "level1") {
				nextLevel = level1;
			}
			else if (l == "mainScreen") {
				nextLevel = mainScreen;
			}
			else if (l == "selectionScreen") {
				nextLevel = selectionScreen;
			}
			else if (l == "winScreen") {
				nextLevel = winScreen;
			}
		}
		
		private function enterFrame(e:Event):void
		{
			var dTime:Number = 1.0 / this.stage.frameRate;
			if (nextLevel) {
				fade -= dTime;
				if (fade <= 0) {
					fade = 0;
					currentLevel.exitLevel();
					currentLevel = nextLevel;
					nextLevel = null;
					currentLevel.enterLevel();
				}
			}
			else if (fade < 1) {
				fade += dTime;
				if (fade >= 1) {
					fade = 1;
				}
			}
			
			if (currentLevel) {
				currentLevel.update(1 / this.stage.frameRate);
				//currentLevel.update(1.0 / 50.0);
				currentLevel.render(buffer, new Rectangle(0, 0, buffer.width, buffer.height));
				if (fade < 1)
					buffer.draw(darkRect, null, new ColorTransform(1, 1, 1, 1 - fade));
			}
		}
		
		private function keyDown(e:KeyboardEvent):void
		{
			if (pressedKeys[e.keyCode] != true) {
				pressedKeys[e.keyCode] = true;
				currentLevel.keyDown(e.keyCode);
			}
		}
		
		private function keyUp(e:KeyboardEvent):void
		{
			pressedKeys[e.keyCode] = false;
			currentLevel.keyUp(e.keyCode);
		}
	}
}