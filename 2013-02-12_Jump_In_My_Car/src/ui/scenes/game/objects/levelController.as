package ui.scenes.game.objects {
	
	/**
	 * 2014-04-02
	 * @author Pavol Kusovsky
	 */
	public class levelController {
		static public const __FALL:String = "FALL";
		private var __backgroundObject:backgroundLayersObject;
		
		public function levelController(oBackgroundObject:backgroundLayersObject) {
			__backgroundObject = oBackgroundObject;
			initialize();
		}
		
		public function initialize():void {
			//nothing to do
		}
		
		public function colisionWithPlayer(oObjectPlayer:objectPlayer, uPosition:uint):String {
			var returnValue:String = "";
			var playerHeight:Number = oObjectPlayer.getJumpHeight();
			//if not over floor
			if (__backgroundObject.getFrontLayerHeight(uPosition + oObjectPlayer.__X_POSITION) == -1) {
				//if not in jump - __FALL.
				if (oObjectPlayer.status == oObjectPlayer.__IN_RUN){
					return __FALL;
				}
			}
			return "";
		}
	}
}