package extensions.starling {
	import caurina.transitions.Tweener;
	import flash.display.BitmapData;
	import starling.events.Event;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Pavol Kusovsky
	 */
	public class fadeObject extends Sprite {
		private var __duration:Number;
		private var __color:uint;
		private var __direction:String;
		private var __width:int;
		private var __height:int;
		private var __tween:Tweener;
		private var __bitmapData:BitmapData;
		private var __image:Image;
		
		public function fadeObject(varParametres:Object, varDirection:String) {
			super();
			__duration = Number(varParametres.duration);
			__color = uint(varParametres.color);
			__direction = String(varDirection);
			__width = int(varParametres.width);
			__height = int(varParametres.height);
			__bitmapData = new BitmapData(__width, __height, false, __color);
			__image = new Image(Texture.fromBitmapData(__bitmapData, false));
			__image.x = 0;
			__image.y = 0;
			addChild(__image);
			if (__direction == "OUT") {
				alpha = 0;
				Tweener.addTween(this, {alpha: 1, time: __duration, delay: 0, transition: "easeInSine", onComplete: tweenCompleted});
			} else {
				alpha = 1;
				Tweener.addTween(this, {alpha: 0, time: __duration, delay: 0, transition: "easeOutSine", onComplete: tweenCompleted});
			}
		}
		
		private function tweenCompleted():void {
			dispatchEvent(new Event("FADE_COMPLETED"));
			removeFromParent(true);
		}
	}
}