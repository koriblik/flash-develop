package utils {
	import com.adobe.images.PNGEncoder;
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	/**
	 * 2014-04-21
	 * @author Pavol Kusovsky
	 */
	public class algorithms {
		
		static public function bresenhamsLine(pStartPoint:Point, pEndPoint:Point):Vector.<int> {
			var pStartPointX:int = int(pStartPoint.x);
			var pStartPointY:int = int(pStartPoint.y);
			var pEndPointX:int = int(pEndPoint.x);
			var pEndPointY:int = int(pEndPoint.y);
			var result:Vector.<int> = new Vector.<int>();
			var dx:int = Math.abs(pEndPointX - pStartPointX);
			var dy:int = Math.abs(pEndPointY - pStartPointY);
			var sx:int = pStartPointX < pEndPointX ? 1 : -1;
			var sy:int = pStartPointY < pEndPointY ? 1 : -1;
			var err:int = dx - dy;
			while (true) {
				result.push(pStartPointX, pStartPointY);
				if ((pStartPointX == pEndPointX) && (pStartPointY == pEndPointY))
					break;
				var e2:int = err * 2;
				if (e2 > -dx) {
					err -= dy;
					pStartPointX += sx;
				}
				if (e2 < dx) {
					err += dx;
					pStartPointY += sy;
				}
			}
			return result;
		}
		
		static public function distanceBetweenPoints(pPoint1:Point, pPoint2:Point):Number {
			var deltaX:Number = pPoint2.x - pPoint1.x;
			var deltaY:Number = pPoint2.y - pPoint1.y;
			return Math.sqrt(deltaX * deltaX + deltaY * deltaY);
		}
		
		static public function savePNG(sName:String, uColor:uint, bBitmapData:BitmapData, bBgBitmapData:BitmapData):void {
			trace(bBitmapData.height);
			var pngSource:BitmapData = new BitmapData(bBitmapData.width, bBitmapData.height, true, 0x00000000);
			var c:ColorTransform = new ColorTransform();
			c.color = uColor;
			bBitmapData.colorTransform(new Rectangle(0, 0, bBitmapData.width, bBitmapData.height), c);
			pngSource.draw(bBgBitmapData);
			pngSource.draw(bBitmapData);
			var ba:ByteArray = PNGEncoder.encode(pngSource);
			var file:File = File.desktopDirectory.resolvePath("pencil\\"+sName + "_" + uColor.toString(16) + ".png");
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(ba);
			fileStream.close();
		}
		
		static public function savePNGToPath(sName:String, bBitmapData:BitmapData):void {
			var pngSource:BitmapData = new BitmapData(bBitmapData.width, bBitmapData.height, true, 0x00000000);
			pngSource.draw(bBitmapData);
			var ba:ByteArray = PNGEncoder.encode(pngSource);
			var file:File = File.desktopDirectory.resolvePath(sName);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(ba);
			fileStream.close();
		}
	}
}