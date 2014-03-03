package ui.scenes.game {
	import config;
	import flash.ui.Keyboard;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import ui.scenes.baseScene;
	import ui.scenes.game.objects.backgroundLayersObject;
	import ui.scenes.game.objects.coinController;
	import ui.scenes.game.objects.objectPlayer;
	import ui.scenes.game.objects.objectsLayer;
	import ui.scenes.game.objects.speedController;
	
	/**
	 * 2014-01-15
	 * @author Pavol Kusovsky
	 */
	public class gameScene extends baseScene {
		private const __MAX_SPEED:uint = 2;
		private const __SHAKE_BOUNDARIES:uint = 10;
		private const __LINE_HEIGHT:uint = 30;
		private var __backgroundLayer:backgroundLayersObject;
		private var __objectsLayer:objectsLayer;
		private var __coinController:coinController;
		private var __objectPlayer:objectPlayer;
		/*TODO delete
		   private var __player:Image;
		   private var __playerShadow:Image;
		 */
		private var __frame:uint;
		private var __position:Number;
		private var __speed:speedController;
		//array that holds the status of key pressed
		private var __keyDown:Vector.<Boolean>;
		
		public function gameScene() {
			super();
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
			//...
			__position = 0;
			__frame = 0;
			__speed = new speedController(__MAX_SPEED, 8, 0.3);
			//background layer
			__backgroundLayer = new backgroundLayersObject();
			addChild(__backgroundLayer);
			//add player
			__objectPlayer = new objectPlayer(__LINE_HEIGHT);
			//objects layer
			__objectsLayer = new objectsLayer(__objectPlayer);
			addChild(__objectsLayer);
			//coin controller
			__coinController = new coinController(__objectsLayer);
			/*TODO delete
			   __playerShadow = new Image(assets.getAtlas().getTexture("player_fly_shadow"));
			   addChild(__playerShadow);
			   __playerShadow.x = 130;
			   __playerShadow.y = 340;
			   __playerShadow.pivotX = __playerShadow.width / 2;
			   __playerShadow.pivotY = __playerShadow.height / 2;
			   __player = new Image(assets.getAtlas().getTexture("player_fly"));
			   addChild(__player);
			   __player.x = 100;
			   __player.y = 170;
			 */
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			//addd keyboard listener
			__keyDown = new Vector.<Boolean>(256);
			for (i = 0; i < 256; i++) {
				__keyDown[i] = false;
			}
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function onKeyUp(e:KeyboardEvent):void {
			__keyDown[e.keyCode] = false;
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			__keyDown[e.keyCode] = true;
			//!trace(e.keyCode + " : " + __keyDown[e.keyCode]);
		}
		
		private function onEnterFrame(event:Event):void {
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
			//update player movement in objectsLayer
			//UP
			if (__keyDown[Keyboard.UP]) {
				__objectPlayer.moveUp();
			}
			//DOWN
			if (__keyDown[Keyboard.DOWN]) {
				__objectPlayer.moveDown();
			}
			__objectPlayer.updateFrame(__speed.getSpeed());
			//update object layers
			__objectsLayer.updateFrame(__position);
			//shake scene
			//!shake(__speed.getSpeed());
			//
		/*TODO delete
		   __player.y = 270 + 10 * Math.sin(Math.PI * __position / 180);
		   __playerShadow.scaleX = 0.84 + 0.08 * Math.sin(Math.PI * __position / 180);
		   __playerShadow.scaleY = 0.84 + 0.08 * Math.sin(Math.PI * __position / 180);
		 */
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
