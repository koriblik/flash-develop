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
		//player x position - for 
		public const __X_POSITION:uint = 200;
		//time in sec to get from one line to another
		public const __SPEED:Number = 0.2;
		//time in sec for the jump
		public const __JUMP_SPEED:Number = 1;
		private var __sprite:Image;
		//current position interval <0,2>
		private var __xPosition:Number;
		//current position in jump <0,1>
		private var __yPosition:Number;
		//active line (where I am touching line)
		private var __line:uint;
		//height of the line
		private var __lineHeight:uint;
		//status __IN_JUMP, __IN_RUN
		private var __status:String;
		//target line fhere to move
		private var __targetLine:uint;
		//status if target has been reached so I can catch another move request
		private var __targetReached:Boolean;
		//move status - where I am moving __MOVE_UP, __MOVE_DOWN, __ON_HOLD
		private var __moveStatus:String;
		//calculated movement speed
		private var __movementSpeed:Number;
		//calculated movement speed
		private var __jumpSpeed:Number;
		//height of the jump
		private var __jumpHeight:uint;
		
		public function objectPlayer(uLineHeight:uint, uJumpHeight:uint) {
			super();
			__lineHeight = uLineHeight;
			__jumpHeight = uJumpHeight;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			//remove listener
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			__sprite = new Image(assets.getAtlas().getTexture("player_fly"));
			__sprite.alignPivot("left", "bottom");
			addChild(__sprite);
			initialize();
		}
		
		public function initialize():void {
			//initialize player
			//center line, no jump, run, no movement
			__line = 1;
			__xPosition = __line;
			__yPosition = 0;
			__targetLine = __line;
			__targetReached = true;
			__status = __IN_RUN;
			__moveStatus = __ON_HOLD;
			//calculate speed based on frame rate
			__movementSpeed = config.__DELTA_TIME / __SPEED;
			__jumpSpeed = config.__DELTA_TIME / __JUMP_SPEED;
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
			//if not in jump
			if (__status != __IN_JUMP) {
				__status = __IN_JUMP;
				__yPosition = 0;
			}
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
			//jump
			if (__status == __IN_JUMP) {
				if ((__yPosition + __jumpSpeed) <= 1) {
					__yPosition += __jumpSpeed;
				} else {
					__yPosition = 0;
					__status = __IN_RUN;
				}
			}
			//set line I am touching
			__line = (__xPosition >= 0.5) ? 1 : 0;
			__line = (__xPosition > 1.5) ? 2 : __line;
			__sprite.y = uint(__xPosition * __lineHeight) - uint(__jumpHeight * Math.sin(Math.PI * __yPosition));
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
		
		public function playerCollisionWidth():uint {
			return __sprite.width;
		}
	
	}
}