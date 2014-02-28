package ui.scenes.game.objects {
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * 2014-02-28
	 * @author Pavol Kusovsky
	 */
	public class objectPlayer extends Sprite {
		public const __IN_JUMP:String = "inJump";
		public const __IN_RUN:String = "inRun";
		public const __MOVE_UP:String = "moveUp";
		public const __MOVE_DOWN:String = "moveDown";
		public const __ON_HOLD:String = "onHold";
		private var __sprite:Image;
		private var __line:uint;
		private var __status:String;
		private var __moveStatus:String;
		
		public function objectPlayer() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			//remove listener
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			__sprite = new Image(assets.getAtlas().getTexture("player_fly"));
			initialize();
		}
		
		public function initialize():void {
			//initialize player
			__line = 1;
			__status = __IN_RUN;
			__moveStatus = __ON_HOLD;
		}
		
		public function moveUp():void {
			__moveStatus = __MOVE_UP;
		}
		
		public function moveDown():void {
			__moveStatus = __MOVE_DOWN;
		}
		
		public function jump():void {
			__status = __IN_JUMP;
		}
		
		public function updateFrame(nSpeed:Number) {
			//TODO calculate frame of sprite based on speed
			//TODO move to defined line
			//TODO handle jump
		}
		
		/**
		 * Return status of Player
		 * @return	String	__IN_JUMP, __IN_RUN
		 */
		public function get status():String {
			return __status;
		}
	
	}
}