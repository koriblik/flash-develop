package ui.scenes.game.objects {
	import caurina.transitions.Tweener;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.TextureSmoothing;
	
	/**
	 * 2014-02-28
	 * @author Pavol Kusovsky
	 */
	public class objectPlayer extends Sprite {
		public static const __EVENT_ANIMATION_FALL_END:String = "event_animation_fall_end";
		public const __IN_JUMP:String = "inJump";
		public const __IN_SMALL_JUMP:String = "inSmallJump";
		public const __IN_BIG_JUMP:String = "inBigJump";
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
		public const __JUMP_SMALL_SPEED:Number = 2.2;
		public const __JUMP_BIG_SPEED:Number = 3.4;
		public const __FALL_ANIMATION_DURATION:Number = .5;
		//graphics
		private var __sprite:Image;
		private var __spriteShadow:Image;
		//height
		private var __height:Number;
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
		private var __jumpSmallSpeed:Number;
		private var __jumpBigSpeed:Number;
		//height of the jumps
		private var __jumpHeight:uint;
		private var __jumpSmallHeight:uint;
		private var __jumpBigHeight:uint;
		
		public function objectPlayer(uLineHeight:uint, uJumpHeight:uint = 100) {
			super();
			__lineHeight = uLineHeight;
			__jumpHeight = uJumpHeight;
			__jumpSmallHeight = __jumpHeight * __JUMP_SMALL_SPEED;
			__jumpBigHeight = __jumpHeight * __JUMP_BIG_SPEED;
			touchable = false;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			//remove listener
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			//add oplayer shadow
			__spriteShadow = new Image(assets.getAtlas().getTexture("player_fly_shadow"));
			__spriteShadow.smoothing = TextureSmoothing.NONE;
			__spriteShadow.alignPivot("center", "center");
			addChild(__spriteShadow);
			//add player sprite and align it to left bottom
			__sprite = new Image(assets.getAtlas().getTexture("player_fly"));
			__sprite.smoothing = TextureSmoothing.NONE;
			__sprite.alignPivot("left", "bottom");
			addChild(__sprite);
			__spriteShadow.x = __sprite.width / 2;
			__height = __sprite.height;
			
			//calculate speed based on frame rate
			__movementSpeed = config.__DELTA_TIME / __SPEED;
			//jump speed - how long I stay in jump
			__jumpSpeed = config.__DELTA_TIME / __JUMP_SPEED;
			__jumpSmallSpeed = config.__DELTA_TIME / __JUMP_SMALL_SPEED;
			__jumpBigSpeed = config.__DELTA_TIME / __JUMP_BIG_SPEED;
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
			updateFrame(0);
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
			//if not in any jump type
			if (__status == __IN_RUN) {
				__status = __IN_JUMP;
				__yPosition = 0;
			}
		}
		
		public function smallJump():void {
			//calculate initial yposition based on the current height
			__yPosition = Math.asin(getJumpHeight() / __jumpSmallHeight) / Math.PI;
			//set jump type
			__status = __IN_SMALL_JUMP;
		}
		
		public function bigJump():void {
			//calculate initial yposition based on the current height
			__yPosition = Math.asin(getJumpHeight() / __jumpBigHeight) / Math.PI;
			//set jump type
			__status = __IN_BIG_JUMP;
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
			switch (__status) {
				case __IN_JUMP: 
					if ((__yPosition + __jumpSpeed) <= 1) {
						__yPosition += __jumpSpeed;
					} else {
						__yPosition = 0;
						__status = __IN_RUN;
					}
					break;
				case __IN_SMALL_JUMP: 
					if ((__yPosition + __jumpSmallSpeed) <= 1) {
						__yPosition += __jumpSmallSpeed;
					} else {
						__yPosition = 0;
						__status = __IN_RUN;
					}
					break;
				case __IN_BIG_JUMP: 
					if ((__yPosition + __jumpBigSpeed) <= 1) {
						__yPosition += __jumpBigSpeed;
					} else {
						__yPosition = 0;
						__status = __IN_RUN;
					}
					break;
			}
			//set line I am touching
			__line = (__xPosition >= 0.5) ? 1 : 0;
			__line = (__xPosition > 1.5) ? 2 : __line;
			//TODO handle small jump and high jump
			//this formula works only for normal jump
			__sprite.y = uint(__xPosition * __lineHeight) - uint(getJumpHeight());
			__spriteShadow.y = uint(__xPosition * __lineHeight);
			__spriteShadow.scaleX = (500 - getJumpHeight()) / 500;
			__spriteShadow.scaleY = __spriteShadow.scaleX;
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
		
		/**
		 * Get the movement status
		 * @return	Boolean	__movementStatus
		 */
		public function get moveStatus():String {
			return __moveStatus;
		}
		
		/**
		 * Return width of the player - for collision
		 * @return
		 */
		public function playerCollisionWidth():uint {
			return __sprite.width;
		}
		
		/**
		 * Return Altitude of the player
		 * @return	Number	Altitude of the Player
		 */
		public function getJumpHeight():Number {
			var returnValue:Number = 0;
			switch (__status) {
				case __IN_JUMP: 
					returnValue = __jumpHeight * Math.sin(Math.PI * __yPosition);
					break;
				case __IN_SMALL_JUMP: 
					returnValue = __jumpSmallHeight * Math.sin(Math.PI * __yPosition);
					break;
				case __IN_BIG_JUMP: 
					returnValue = __jumpBigHeight * Math.sin(Math.PI * __yPosition);
					break;
			}
			return returnValue;
		}
		
		public function fall():void {
			Tweener.addTween(this, {y: config.__DEFAULT_HEIGHT+__height, time: __FALL_ANIMATION_DURATION, delay: 0, transition: "easeInSine", onComplete: tweenCompleted});
		}
		
		private function tweenCompleted():void {
			dispatchEventWith(__EVENT_ANIMATION_FALL_END);
		}
	}
}