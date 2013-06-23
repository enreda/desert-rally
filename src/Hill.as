package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Shader;
	import flash.display.Shape;
	import flash.filters.BlurFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Zaid Abdulla
	 */
	public class Hill extends GameObject
	{
		[Embed(source="../shaders/lighting.pbj", mimeType="application/octet-stream")]
		public static var LightingShader:Class;
		
		[Embed(source="../shaders/displacement.pbj", mimeType="application/octet-stream")]
		public static var DisplacementShader:Class;

		private var heightMap:BitmapData;
		private var hillImage:BitmapData;
		
		public var x:Number;
		public var y:Number;
		
		public var width:Number;
		public var height:Number;
		
		
		public function Hill(_x:Number, _y:Number, _width:Number, _height:Number, ground:Ground)
		{
			x = _x;
			y = _y;
			width = _width;
			height = _height;
			heightMap = new BitmapData(width, height, false, 0);
			hillImage = new BitmapData(width, height, false, 0);
			generateHeightmap();
			fillHillImage(ground);
			applyDisplacement();
			applyLighting();
		}
		
		private function generateHeightmap():void
		{
			var shp:Shape = new Shape();
			shp.graphics.beginFill(0xffffff);
			shp.graphics.drawCircle(heightMap.width * 0.5, heightMap.height * 0.5, heightMap.width * 0.3);
			shp.graphics.endFill();
			var filters:Array = new Array();
			//filters.push(new BlurFilter(heightMap.width / 8, heightMap.height / 8, 3));
			filters.push(new BlurFilter(heightMap.width * 0.2, heightMap.width * 0.2, 3));
			shp.filters = filters;
			heightMap.draw(shp, null, null, null, null, true);
		}
		
		private function fillHillImage(ground:Ground):void
		{
			ground._render(new Rectangle(x, y, width, height), hillImage, new Rectangle(0, 0, width, height));
		}
		
		private function getDisplacementMap():BitmapData
		{
			var map:BitmapData = new BitmapData(heightMap.width, heightMap.height, false, 0);
			var shader:Shader = new Shader(new DisplacementShader());
			shader.data.heightmap.input = heightMap;
			
			var shp:Shape = new Shape();
			shp.graphics.beginShaderFill(shader);
			shp.graphics.drawRect(0, 0, heightMap.width, heightMap.height);
			shp.graphics.endFill();
			
			map.draw(shp, null, null, null, null, true);
			return map;
		}
		
		private function applyDisplacement():void
		{
			var displacementMap:BitmapData = getDisplacementMap();
			var displacementMapFilter:DisplacementMapFilter
				= new DisplacementMapFilter(displacementMap, new Point(0, 0), 1, 2, 50, 50, DisplacementMapFilterMode.IGNORE);
			
			var shp:Shape = new Shape();
			shp.graphics.beginBitmapFill(hillImage);
			shp.graphics.drawRect(0, 0, hillImage.width, hillImage.height);
			shp.graphics.endFill();
			
			var a:Array = new Array();
			a.push(displacementMapFilter);
			shp.filters = a;
			
			var image:BitmapData = new BitmapData(hillImage.width, hillImage.height, false, 0);
			image.draw(shp);
			
			hillImage = image;
		}
		
		private function applyLighting():void
		{
			var image:BitmapData = new BitmapData(hillImage.width + 5, hillImage.height, false, 0);
			var shader:Shader = new Shader(new LightingShader());
			shader.data.heightmap.input = heightMap;
			shader.data.surface.input = hillImage;
			
			
			var shp:Shape = new Shape();
			shp.graphics.beginShaderFill(shader);
			shp.graphics.drawRect(0, 0, image.width, image.height);
			shp.graphics.endFill();
			
			image.draw(shp, null, null, null, null, true);
			hillImage.draw(image);
		}

		public override function render(viewRect:Rectangle, buffer:BitmapData, bufferRect:Rectangle, queue:uint):uint
		{
			var scaleX:Number = bufferRect.width / viewRect.width;
			var scaleY:Number = bufferRect.height / viewRect.height;
			
			var mat:Matrix = new Matrix();
			mat.scale(scaleX * (width / heightMap.width), scaleY * (height / heightMap.height));
			mat.translate(scaleX * (x - viewRect.x), scaleY * (y - viewRect.y));
			
			buffer.draw(hillImage, mat, null, BlendMode.NORMAL, null, true);
			
			return Level.QUEUE_RENDER + queue;
		}
		
		public override function renderNoScale(offset:Point, buffer:BitmapData, queue:uint):uint
		{
			buffer.copyPixels(hillImage, hillImage.rect, new Point(x - offset.x, y - offset.y));
			
			return Level.QUEUE_RENDER + queue;			
		}
		
		public override function handleEvent(eventType:String, args:Object, rValue:Object):uint
		{
			if (eventType == "testHeight") {
				if (args.x < x || args.x > x + width || args.y < y || args.y > y + height)
					return Level.QUEUE_EVENT;
				
				rValue.height = Number((Number(heightMap.getPixel32(args.x - x, args.y - y)) & 0x0000ff) / 255.0) as Number;
			}
			return Level.QUEUE_EVENT;
		}
	}
}