package ui.scenes.coloring.objects.subObjects {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * 2014-04-22
	 * @author Pavol Kusovsky
	 */
	public class toolSelection extends Sprite {
		private const __SINGLE_TOOL_WIDTH:uint = 26;
		private var __toolPallete:Sprite;
		private var __size:Point;
		private var __selectedTool:uint;
		private var __moved:Boolean;
		
		public function toolSelection(uWidth:uint, uHeight:uint) {
			super();
			__size = new Point(uWidth, uHeight);
			//clip rectangle
			this.clipRect = new Rectangle(0, 0, __size.x, __size.y);
			__toolPallete = new Sprite();
			__toolPallete.addEventListener(TouchEvent.TOUCH, onTouchToolPallete);
			addChild(__toolPallete);
			var i:uint;
			for (i = 0; i < assets.__coloringBookToolsPallete.length; i++) {
				var s:singleTool = new singleTool();
				s.x = i * __SINGLE_TOOL_WIDTH;
				s.y = 16;
				__toolPallete.addChild(s);
			}
		}
		
		public function init(sTool:String):void {
			var i:uint;
			for (i = 0; i < assets.__coloringBookToolsPallete.length; i++) {
				(__toolPallete.getChildAt(i) as singleTool).init(sTool, assets.__coloringBookToolsPallete[i]);
			}
		}
		
		private function onTouchToolPallete(event:TouchEvent):void {
			var touchBegan:Touch = event.getTouch(__toolPallete, TouchPhase.BEGAN);
			var touchEnded:Touch = event.getTouch(__toolPallete, TouchPhase.ENDED);
			var touchMoved:Touch = event.getTouch(__toolPallete, TouchPhase.MOVED);
			//
			if (touchBegan) {
				// one finger start touch
				//__startPoint = touchBegan.getLocation(this);
			}
			if (touchMoved) {
				// one finger moving
				var movement:Point = touchMoved.getMovement(__toolPallete);
				__toolPallete.x = Math.min(0, movement.x + __toolPallete.x);
				if (__toolPallete.x < (-__toolPallete.width + __size.x)) {
					__toolPallete.x = (-__toolPallete.width + __size.x);
				}
			}
			if (touchEnded) {
				// one finger end touch
				//__deltaPoint = touchEnded.getLocation(this);
			}
		}
	}
}