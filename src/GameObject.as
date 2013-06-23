package  
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class GameObject 
	{	
		internal var deleteIt:Boolean = false;
		
		public function handleAdded(level:Level, queue:uint):uint
		{
			return queue;
		}
		
		public function update(dTime:Number, queue:uint):uint
		{
			return Level.QUEUE_RENDER + queue;
		}
		
		public function render(viewRect:Rectangle, buffer:BitmapData, bufferRect:Rectangle, queue:uint):uint
		{
			return Level.QUEUE_UPDATE + queue;
		}
		
		public function renderNoScale(offset:Point, buffer:BitmapData, queue:uint):uint
		{
			return this.render(new Rectangle(offset.x, offset.y, buffer.width, buffer.height), buffer, new Rectangle(0, 0, buffer.width, buffer.height), queue);
		}
		
		public function handleEvent(eventType:String, args:Object, rValue:Object):uint
		{
			return 0;
		}
	}
}