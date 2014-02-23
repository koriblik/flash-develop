package ui.scenes.game.objects.utils {
	/**
	 * 2014-02-21
	 * @author pavol Kusovsky
	 */
	public class objectPool {
		private var __pool:Vector.<*>;
		private var __counter:uint;
		private var __class:Class;
		
		/**
		 * Constructor
		 * @param	cType	Type of the object to be in Pool
		 * @param	uLength	Initialize size of the Pool
		 */
		public function objectPool(cType:*, uLength:uint) {
			__pool = new Vector.<*>();
			__class = cType;
			//__counter = uLength;
			var i:uint = uLength;
			while (--i > -1) {
				__pool.push(new __class());
			}
		}
		
		/**
		 * Get object from the Pool
		 * @return *	Object from Pool
		 */
		public function getObject():* {
			//if Pool is empty create new object
			if (__pool.length == 0) {
				__pool.push(new __class());
			}
			return __pool.pop();
		}
		
		/**
		 * Return object back to Pool
		 * @param	dObject		Object to return
		 */
		public function returnObject(dObject:*):void {
			__pool.push(dObject);
		}
	}
}
