package  
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
		
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class Level 
	{
		public static const QUEUE_WIDTH:uint = 63;
		public static const QUEUE_UPDATE:uint = Math.pow(2, 6);
		public static const QUEUE_RENDER:uint = Math.pow(2, 7);
		public static const QUEUE_EVENT:uint = Math.pow(2, 8);
		
		private var updateQueue:Array = new Array(QUEUE_WIDTH);
		private var renderQueue:Array = new Array(QUEUE_WIDTH);
		private var eventQueue:Array = new Array();
		
		protected var viewRect:Rectangle = new Rectangle(0, 0, 550, 400);
		
		protected function pushToQueues(obj:GameObject, queue:uint):void
		{
			var queueNo:uint = queue & QUEUE_WIDTH;
			var a:Array;
			if (queue & QUEUE_EVENT) {
				eventQueue.push(obj);
			}
			
			if (queue & QUEUE_UPDATE) {
				if (updateQueue[queueNo] != null) {
					updateQueue[queueNo].push(obj);
				}
				else {
					a = new Array(QUEUE_WIDTH);
					a.push(obj);
					updateQueue[queueNo] = a;
				}
			}
			else if (queue & QUEUE_RENDER) {
				if (renderQueue[queueNo] != null) {
					renderQueue[queueNo].push(obj);
				}
				else {
					a = new Array(QUEUE_WIDTH);
					a.push(obj);
					renderQueue[queueNo] = a;
				}
			}
		}
		
		public function clearQueues():void
		{
			eventQueue = new Array();
			renderQueue = new Array();
			updateQueue = new Array();
		}
		
		public function update(dTime:Number):void
		{
			var queue:Array;
			for (var key:String in updateQueue) {
				queue = updateQueue[key];
				updateQueue[key] = null;
				
				for each (var obj:GameObject in queue) {
					if (obj.deleteIt)
						continue;
					pushToQueues(obj, obj.update(dTime, uint(key)));
				}
			}
		}

		public function render(buffer:BitmapData, rect:Rectangle):void
		{
			this.renderGameObjects(new Rectangle(0, 0, 550, 400), buffer, rect);
		}
		
		protected function renderGameObjects(viewRect:Rectangle, buffer:BitmapData, bufferRect:Rectangle):void
		{
			var key:String;
			var queue:Array;
			var obj:GameObject;
			
			if (viewRect.width == buffer.width && viewRect.height == bufferRect.height) {
				
				for (key in renderQueue) {
					queue = renderQueue[key];
					renderQueue[key] = null;
				
					for each (obj in queue) {
						if (obj.deleteIt)
							continue;
						pushToQueues(obj, obj.renderNoScale(viewRect.topLeft, buffer, uint(key)));
					}
				}
			}
			else {
				for (key in renderQueue) {
					queue = renderQueue[key];
					renderQueue[key] = null;
					
					for each (obj in queue) {
						if (obj.deleteIt)
							continue;
						pushToQueues(obj, obj.render(viewRect, buffer, bufferRect, uint(key)));
					}
				}
			}
		}
		
		public function keyDown(keyCode:int):void
		{
			dispatchEvent("keyDown", { keyCode:keyCode } );
		}
		
		public function keyUp(keyCode:int):void
		{
			dispatchEvent("keyUp", { keyCode:keyCode } );
		}
		
		public function dispatchEvent(eventType:String, args:Object):Object
		{
			var a:Array = eventQueue;
			eventQueue = new Array();
			var rValue:Object = new Object;
			for each (var obj:GameObject in a) {
				if (obj.deleteIt)
					continue;
				pushToQueues(obj, obj.handleEvent(eventType, args, rValue));
			}
			return rValue;
		}
		
		public function addGameObject(obj:GameObject, queue:uint):void
		{
			pushToQueues(obj, obj.handleAdded(this, queue));
		}
		
		public function removeGameObject(obj:GameObject):void
		{
			obj.deleteIt = true;
		}
		
		public function enterLevel():void
		{
			
		}
		
		public function exitLevel():void
		{
			
		}
	}
}