package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	
	/**
	 * Move by delta best on passedTime during Enter Frame
	 * @author pk
	 */
	public class Main extends Sprite {
		private var __time:uint = 0;
		private var test:moveTheTree;
		
		public function Main():void {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			test = new moveTheTree();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void {
			var passedTime:uint = getTimer() - __time;
			test.moveTheTreeDelta(passedTime);
			__time = getTimer();
		}
	
	}

}