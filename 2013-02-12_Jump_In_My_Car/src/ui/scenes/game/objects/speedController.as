package ui.scenes.game.objects {
	
	/**
	 * 2014-02-20
	 * @author Pavol Kusovsky
	 */
	public class speedController {
		private const __ACCELERATE:String = "accelerate";
		private const __BREAK:String = "break";
		private var __speed:Number;
		private var __speedMax:Number;
		private var __speedMaxTime:Number;
		private var __speedMinTime:Number;
		private var __counter:Number;
		//accelerate/break
		private var __direction:String;
		
		public function speedController(nMaxSpeed:Number = 10, nSpeedMaxTime:Number = 5, nSpeedMinTime:Number = .5) {
			__speedMax = nMaxSpeed;
			__speedMaxTime = nSpeedMaxTime;
			__speedMinTime = nSpeedMinTime;
			__direction = __ACCELERATE;
			initialize();
		}
		
		/**
		 * Initlaize variables for restart
		 */
		public function initialize():void {
			__speed = 0;
			__counter = 0;
		}
		
		public function updateFrame(nDelta:Number = 1):void {
			switch (__direction) {
				case __ACCELERATE: 
					__counter += nDelta;
					__counter = Math.min(__speedMaxTime, __counter);
					__speed = nDelta*__speedMax * Math.sin((__counter * (Math.PI / 2)) / __speedMaxTime);
					break;
				case __BREAK: 
					__counter += nDelta;
					__counter = Math.min(__speedMinTime, __counter);
					__speed = nDelta*__speedMax * Math.cos((__counter * (Math.PI / 2)) / __speedMinTime);
					if (__counter == __speedMinTime) {
						__direction = __ACCELERATE;
						__counter = 0;
					}
					break;
			}
		}
		
		public function getSpeed():Number {
			return __speed;
		}
		
		public function startBreak():void {
			__direction = __BREAK;
			__counter = 0;
		}
	}
}