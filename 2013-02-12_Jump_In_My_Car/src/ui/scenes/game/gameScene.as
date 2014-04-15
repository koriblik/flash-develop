package ui.scenes.game {
	import config;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import ui.scenes.baseScene;
	import ui.scenes.game.objects.backgroundLayersObject;
	import ui.scenes.game.objects.coinController;
	import ui.scenes.game.objects.levelController;
	import ui.scenes.game.objects.objectPlayer;
	import ui.scenes.game.objects.objectsLayer;
	import ui.scenes.game.objects.obstacleController;
	import ui.scenes.game.objects.overlays.overlayGameOver;
	import ui.scenes.game.objects.overlays.overlayStartGame;
	import ui.scenes.game.objects.speedController;
	
	/**
	 * 2014-01-15
	 * @author Pavol Kusovsky
	 */
	public class gameScene extends baseScene {
		//speed in pixels per second
		private const __MAX_SPEED:uint = 1000;
		private const __SHAKE_BOUNDARIES:uint = 10;
		//when I register movement - 10% of screen height
		private const __MIN_DIFF_MOVEMENT:uint = config.__DEFAULT_HEIGHT / 10;
		//space betveen lines
		private const __LINE_HEIGHT:uint = 30;
		//basic jump height (small and big are calculated based on this)
		private const __JUMP_HEIGHT:uint = 100;
		private const __IN_GAME_STATE:String = "inGameState";
		private const __IN_START_DELAY_STATE:String = "inStartDelayState";
		private const __IN_GAME_OVER_STATE:String = "inGameOverState";
		private var __backgroundLayer:backgroundLayersObject;
		private var __objectsLayer:objectsLayer;
		private var __coinController:coinController;
		private var __obstacleController:obstacleController;
		private var __levelController:levelController;
		private var __objectPlayer:objectPlayer;
		private var __overlayStartGame:overlayStartGame;
		private var __overlayGameOver:overlayGameOver;
		private var __frame:uint;
		private var __position:Number;
		private var __speed:speedController;
		//score
		private var __scoreText:TextField;
		//cursor positions
		private var __currentPosition:Point = new Point();
		private var __previousPosition:Point = new Point();
		//game state
		private var __state:String;
		//array that holds the status of key pressed
		private var __keyDown:Vector.<Boolean>;
		//is clicked down/movement
		private var __fingerDown:Boolean;
		private var __fingerMoved:Boolean;
		//status of the player
		private var __inEndAnimation:Boolean;
		
		public function gameScene() {
			super();
			assets.initFonts();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			//remove listener
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			//fade in can be called only after scene is ready on stage
			//this should be last thing to be displayed
			fadeIn({duration: config.__FADE_SCENE_DELAY, color: 0xffffffff, width: config.__WINDOW_WIDTH, height: config.__WINDOW_HEIGHT});
			addEventListener("SCENE_INITIALIZED", onSceneInitialized);
			trace("[gameScene] addedToStage");
		}
		
		private function onSceneInitialized(e:Event):void {
			var i:uint;
			removeEventListener("SCENE_INITIALIZED", onSceneInitialized);
			//in this point scene is fully visible
			//set variables
			__speed = new speedController(__MAX_SPEED, 8, 1);
			//background layer
			__backgroundLayer = new backgroundLayersObject();
			addChild(__backgroundLayer);
			//add player
			__objectPlayer = new objectPlayer(__LINE_HEIGHT, __JUMP_HEIGHT);
			//objects layer
			__objectsLayer = new objectsLayer(__objectPlayer);
			addChild(__objectsLayer);
			//level controller
			__levelController = new levelController(__backgroundLayer);
			//coin controller
			__coinController = new coinController(__objectsLayer);
			//obstacle controller
			__obstacleController = new obstacleController(__objectsLayer);
			//score
			__scoreText = new TextField(config.__WINDOW_WIDTH, 64, "0", "04b", 30, 0xffff00);
			addChild(__scoreText);
			//overlays
			__overlayStartGame = new overlayStartGame();
			addChild(__overlayStartGame);
			__overlayGameOver = new overlayGameOver();
			addChild(__overlayGameOver);
			//add keyboard vector
			__keyDown = new Vector.<Boolean>(256);
			initialize();
		}
		
		/**
		 * Use this method to reset all data before restarting level
		 */
		public function initialize():void {
			//initalize data
			__position = 0;
			__frame = 0;
			__speed.initialize();
			__backgroundLayer.initialize();
			__coinController.initialize();
			__obstacleController.initialize();
			__objectPlayer.initialize();
			__objectsLayer.initialize();
			//set start delay state
			__state = __IN_START_DELAY_STATE;
			//overlays
			__overlayStartGame.initialize();
			__overlayStartGame.addEventListener(overlayStartGame.__EVENT_START, onStartGameClicked);
			//clear all keys states
			var i:uint;
			for (i = 0; i < 256; i++) {
				__keyDown[i] = false;
			}
			//set up click
			__fingerDown = false;
			__fingerMoved = false;
			//end animation
			__inEndAnimation = false;
		}
		
		private function onStartGameClicked(e:Event):void {
			__overlayStartGame.removeEventListener(overlayStartGame.__EVENT_START, onStartGameClicked);
			//add EnterFrame handler
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			//add keyboard listeners
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			this.stage.addEventListener(TouchEvent.TOUCH, onTouch);
			//set new state
			__state = __IN_GAME_STATE;
		}
		
		/**
		 * Call this method once game is over
		 */
		private function gameOver():void {
			//add EnterFrame handler
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			//add keyboard listeners
			this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			this.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			this.stage.removeEventListener(TouchEvent.TOUCH, onTouch);
			__overlayGameOver.initialize();
			__overlayGameOver.addEventListener(overlayGameOver.__EVENT_OVER, onGameOverClicked);
			//set new state
			__state = __IN_GAME_OVER_STATE;
		}
		
		private function onTouch(event:TouchEvent):void {
			var touchB:Touch = event.getTouch(this.stage, TouchPhase.BEGAN);
			var touchE:Touch = event.getTouch(this.stage, TouchPhase.ENDED);
			var touchM:Touch = event.getTouch(this.stage, TouchPhase.MOVED);
			//if touch - remember position and enable movement
			if (touchB) {
				__fingerDown = true;
				__previousPosition = touchB.getPreviousLocation(this);
			}
			//if touch ended disable movement
			if (touchE) {
				__fingerDown = false;
				if (!__fingerMoved) {
					//test if tap is on correct place (right side)
					if (((touchE.getPreviousLocation(this).x >= ((1 - config.__TOUCH_PANEL_SIZE) * config.__WINDOW_WIDTH)) && (!config.__DATA_OBJECT.leftHanededAlignment)) || ((touchE.getPreviousLocation(this).x < config.__TOUCH_PANEL_SIZE * config.__WINDOW_WIDTH) && (config.__DATA_OBJECT.leftHanededAlignment))) {
						__objectPlayer.jump();
					}
					//test if tap is on correct place (left side)
					if ((touchE.getPreviousLocation(this).x < config.__TOUCH_PANEL_SIZE * config.__WINDOW_WIDTH) && (config.__DATA_OBJECT.leftHanededAlignment)) {
						__objectPlayer.jump();
					}
				}
				__fingerMoved = false;
			}
			//if moved and finder is down
			if (touchM) {
				if (__fingerDown) {
					__fingerMoved = true;
					//get current position
					__currentPosition = touchM.getLocation(this);
					//check if player is still in movement and update previous position acordingly
					if (__objectPlayer.moveStatus != __objectPlayer.__ON_HOLD) {
						__previousPosition = touchM.getPreviousLocation(this);
					}
					//check if I am at the correct dimensions for movement
					if (((touchM.getPreviousLocation(this).x < ((1 - config.__TOUCH_PANEL_SIZE) * config.__WINDOW_WIDTH)) && (!config.__DATA_OBJECT.leftHanededAlignment)) || ((touchM.getPreviousLocation(this).x >= config.__TOUCH_PANEL_SIZE * config.__WINDOW_WIDTH) && (config.__DATA_OBJECT.leftHanededAlignment))) {
						//check if movement is higher than MIN value to recognize movement - move down
						if ((__currentPosition.y - __previousPosition.y) > __MIN_DIFF_MOVEMENT) {
							__previousPosition = touchM.getPreviousLocation(this);
							__objectPlayer.moveDown();
						}
						//check if movement is lower than MIN value to recognize movement  - move up
						if ((__currentPosition.y - __previousPosition.y) < -__MIN_DIFF_MOVEMENT) {
							__previousPosition = touchM.getPreviousLocation(this);
							__objectPlayer.moveUp();
						}
					}
				}
			}
		}
		
		private function onGameOverClicked(e:Event):void {
			__overlayGameOver.removeEventListener(overlayGameOver.__EVENT_OVER, onGameOverClicked);
			initialize();
		}
		
		private function onKeyUp(e:KeyboardEvent):void {
			__keyDown[e.keyCode] = false;
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			__keyDown[e.keyCode] = true;
		}
		
		private function onEnterFrame(event:Event):void {
			/*
			//TODO if speed is stopped - game over (should be changed to something that controls dead anumation
			if (__speed.direction == speedController.__STOP) {
				gameOver();
			}
			*/
			//update frame counter
			__frame++;
			//calculate new speed
			__speed.updateFrame(config.__DELTA_TIME);
			//calculate position
			__position += __speed.getSpeed();
			__position = Math.min(__position, config.__LEVEL_SIZE);
			//update background layers
			__backgroundLayer.updateFrame(__position);
			//update coins controller
			__coinController.updateFrame(__position);
			//update obstacle controller
			__obstacleController.updateFrame(__position);
			//update player movement in objectsLayer
			//UP
			if (__keyDown[Keyboard.UP]) {
				__objectPlayer.moveUp();
			}
			//DOWN
			if (__keyDown[Keyboard.DOWN]) {
				__objectPlayer.moveDown();
			}
			//JUMP
			if (__keyDown[Keyboard.SPACE]) {
				__objectPlayer.jump();
			}
			__objectPlayer.updateFrame(__speed.getSpeed());
			//update object layers
			__objectsLayer.updateFrame(__position);
			//TODO check player interraction with coins and handle return value - change it to score
			Main.__tempDraw.graphics.clear();
			Main.__tempOutput.htmlText = "";
			//do not check this if in end animation:
			if (!__inEndAnimation) {
				//get # of coins taken and remove them if necessary in controller
				var returnValueCoin:uint = __coinController.colisionWithPlayer(__objectPlayer, __position);
				__scoreText.text = String(uint(__scoreText.text) + returnValueCoin);
				//check the hit with obstacles
				var returnValueObstacle:String = __obstacleController.colisionWithPlayer(__objectPlayer, __position);
				if (returnValueObstacle == obstacleController.__HIT) {
					__speed.startBreak(true);
					__inEndAnimation = true;
						//gameOver(obstacleController.__HIT);
				}
				//check if on way
				var returnValueLevel:String = __levelController.colisionWithPlayer(__objectPlayer, __position);
				if (returnValueLevel == levelController.__FALL) {
					__speed.startBreak(true);
					__inEndAnimation = true;
					__objectPlayer.fall();
					__objectPlayer.addEventListener(objectPlayer.__EVENT_ANIMATION_FALL_END, onPlayerFallCompleted);
					
				}
			}
			//shake scene
			//!shake(__speed.getSpeed());
		
		/*TODO delete
		   __player.y = 270 + 10 * Math.sin(Math.PI * __position / 180);
		   __playerShadow.scaleX = 0.84 + 0.08 * Math.sin(Math.PI * __position / 180);
		   __playerShadow.scaleY = 0.84 + 0.08 * Math.sin(Math.PI * __position / 180);
		 */
		}
		
		private function onPlayerFallCompleted(e:Event):void 
		{
			gameOver();
		}
		
		private function shake(nSpeed:Number):void {
			var delta:Number;
			if (nSpeed >= __MAX_SPEED / 2) {
				delta = ((nSpeed / __MAX_SPEED) - 0.5) * 2;
				this.x = int(delta * (-__SHAKE_BOUNDARIES + 2 * __SHAKE_BOUNDARIES * Math.random()));
					//this.y = delta * (-__SHAKE_BOUNDARIES + 2 * __SHAKE_BOUNDARIES * Math.random());
			}
		}
	}
}
