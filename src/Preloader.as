package 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.text.engine.RenderingMode;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class Preloader extends MovieClip 
	{
		public static var AlHorFont:Class = TextObject.AlHorFont;
		
		private var percentage:TextLine;
		
		public function Preloader() 
		{
			addEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
			// show loader
			
			var fd:FontDescription = new FontDescription("AlHor", FontWeight.NORMAL, FontPosture.NORMAL, FontLookup.EMBEDDED_CFF, RenderingMode.CFF);
			var elementFormat:ElementFormat = new ElementFormat(fd, 24, 0x999999);
			var textElement:TextElement = new TextElement("جاري التحميل", elementFormat);
			var textBlock:TextBlock = new TextBlock(textElement);// , null, TextJustifier.getJustifierForLocale("ar"));
			
			var t:TextLine = textBlock.createTextLine();
			t.x = (550 - t.width) * 0.5;
			t.y = 190;
			this.addChild(t);

		}
		
		private function updatePercentage(p:int):void
		{
			if (percentage != null)
				this.removeChild(percentage);

			var fd:FontDescription = new FontDescription("AlHor", FontWeight.NORMAL, FontPosture.NORMAL, FontLookup.EMBEDDED_CFF, RenderingMode.CFF);
			var elementFormat:ElementFormat = new ElementFormat(fd, 24, 0x999999);
			var textElement:TextElement = new TextElement(p.toString() + "%", elementFormat);
			var textBlock:TextBlock = new TextBlock(textElement);// , null, TextJustifier.getJustifierForLocale("ar"));
			
			percentage = textBlock.createTextLine();
			percentage.x = (550 - percentage.width) * 0.5;
			percentage.y = 220;
			this.addChild(percentage);
		}
		
		private function progress(e:ProgressEvent):void 
		{
			updatePercentage((e.bytesLoaded / e.bytesTotal) * 100);
		}
		
		private function checkFrame(e:Event):void 
		{
			if (currentFrame == totalFrames) 
			{
				removeEventListener(Event.ENTER_FRAME, checkFrame);
				startup();
			}
		}
		
		private function startup():void 
		{
			// hide loader
			stop();
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			while (this.numChildren > 0)
				this.removeChildAt(0);
			var mainClass:Class = getDefinitionByName("Main") as Class;
			addChild(new mainClass() as DisplayObject);
		}
		
	}
	
}