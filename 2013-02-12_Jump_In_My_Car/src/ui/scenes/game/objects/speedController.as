package ui.scenes.game.objects {
	
	/**
	 * 2014-02-20
	 * @author Pavol Kusovsky
	 */
	public class speedController {
		public static const __ACCELERATE:String = "accelerate";
		public static const __BREAK:String = "break";
		public static const __STOP:String = "stop";
		private var __speed:Number;
		private var __speedMax:Number;
		private var __speedMaxTime:Number;
		private var __speedMinTime:Number;
		private var __counter:Number;
		private var __counterB:Number;
		private var __isEnd:Boolean;
		//accelerate/break
		private var __direction:String;
		
		public function speedController(nMaxSpeed:Number = 10, nSpeedMaxTime:Number = 5, nSpeedMinTime:Number = 1) {
			__speedMax = nMaxSpeed;
			__speedMaxTime = nSpeedMaxTime;
			__speedMinTime = nSpeedMinTime;
			initialize();
		}
		
		/**
		 * Initlaize variables for restart
		 */
		public function initialize():void {
			__speed = 0;
			__counter = 0;
			__counterB = 0;
			__isEnd = false;
			__direction = __ACCELERATE;
		}
		
		public function updateFrame(nDelta:Number = 1):void {
			switch (__direction) {
				case __ACCELERATE: 
					__counter += nDelta;
					__counter = Math.min(__speedMaxTime, __counter);
					__speed = nDelta * __speedMax * Math.sin((__counter * (Math.PI / 2)) / __speedMaxTime);
					break;
				case __BREAK: 
					__counterB += nDelta;
					__counterB = Math.min(__speedMinTime, __counterB);
					__speed = nDelta * __speedMax * Math.cos((__counterB * (Math.PI / 2)) / __speedMinTime);
					if (__counterB == __speedMinTime) {
						__counter = 0;
						//if is end - do not start again
						if (__isEnd) {
							__direction = __STOP;
						} else {
							__direction = __ACCELERATE;
						}
					}
					break;
				case __STOP: 
					//nothing to do
					break;
			}
		}
		
		public function getSpeed():Number {
			return __speed;
		}
		
		public function startBreak(bIsEnd:Boolean = false):void {
			__direction = __BREAK;
			__isEnd = bIsEnd;
			//set counter to percentage of current speed
			__counterB = __speedMinTime * (1 - __counter / __speedMaxTime);
		}
		
		public function get direction():String {
			return __direction;
		}
	}
}