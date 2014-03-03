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
		//time in sec to get from one line to another
		public const __SPEED:Number = 0.2;
		private var __sprite:Image;
		//current position interval <0,2>
		private var __xPosition:Number;
		//active line (where I am touching line)
		private var __line:uint;
		//height of the line
		private var __lineHeight:uint;
		private var __status:String;
		private var __targetLine:uint;
		private var __targetReached:Boolean;
		private var __moveStatus:String;
		private var __movementSpeed:Number;
		
		public function objectPlayer(uLineHeight:uint) {
			super();
			__lineHeight = uLineHeight;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			//remove listener
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			__sprite = new Image(assets.getAtlas().getTexture("player_fly"));
			__sprite.alignPivot("center", "bottom");
			addChild(__sprite);
			initialize();
		}
		
		public function initialize():void {
			//initialize player
			//center line, no jump, run, no movement
			__line = 1;
			__xPosition = __line;
			__targetLine = __line;
			__targetReached = true;
			__status = __IN_RUN;
			__moveStatus = __ON_HOLD;
			__movementSpeed = config.__DELTA_TIME / __SPEED;
		}
		
		public function moveUp():void {
			//if no movement or into other direction
			if ((__targetReached) || (__moveStatus == __MOVE_DOWN)) {
				if (__xPosition > 0) {
					__targetLine--;
					__moveStatus = __MOVE_UP;
					__targetReached = false;
				}
			}
		
		}
		
		public function moveDown():void {
			//if no movement or into other direction
			if ((__targetReached) || (__moveStatus == __MOVE_UP)) {
				if (__xPosition < 2) {
					__targetLine++;
					__moveStatus = __MOVE_DOWN;
					__targetReached = false;
				}
			}
		}
		
		public function jump():void {
			__status = __IN_JUMP;
		}
		
		public function updateFrame(nSpeed:Number):void {
			//TODO calculate frame of sprite based on speed
			//handle move-ing
			if (!__targetReached) {
				if (__moveStatus == __MOVE_UP) {
					if ((__xPosition - __movementSpeed) > __targetLine) {
						__xPosition -= __movementSpeed;
					} else {
						__xPosition = __targetLine;
						__moveStatus = __ON_HOLD;
						__targetReached = true;
					}
				}
				if (__moveStatus == __MOVE_DOWN) {
					if ((__xPosition + __movementSpeed) < __targetLine) {
						__xPosition += __movementSpeed;
					} else {
						__xPosition = __targetLine;
						__moveStatus = __ON_HOLD;
						__targetReached = true;
					}
				}
			}
			//set line I am touching
			__line = (__xPosition >= 0.5) ? 1 : 0;
			__line = (__xPosition > 1.5) ? 2 : __line;
			__sprite.y = uint(__xPosition * __lineHeight);
			//TODO handle jump
		}
		
		/**
		 * Return status of Player
		 * @return	String	__IN_JUMP, __IN_RUN
		 */
		public function get status():String {
			return __status;
		}
		
		/**
		 * Return line vhere player is right now
		 * @return	uint	[0,1,2]
		 */
		public function get line():uint {
			return __line;
		}
	
	}
}