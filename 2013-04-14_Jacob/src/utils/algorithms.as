package utils {
	import flash.geom.Point;
	
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
	}
}