package ui.scenes.game {
	import config;
	import flash.net.SharedObjectFlushStatus;
	import starling.display.Image;
	import starling.events.Event;
	import ui.scenes.baseScene;
	import ui.scenes.game.objects.backgroundLayersObject;
	import ui.scenes.game.objects.coinController;
	import ui.scenes.game.objects.objectsLayer;
	import ui.scenes.game.objects.utils.parallaxLayer;
	import ui.scenes.game.objects.speedController;
	
	/**
	 * 2014-01-15
	 * @author Pavol Kusovsky
	 */
	public class gameScene extends baseScene {
		private var __backgroundLayer:backgroundLayersObject;
		private var __objectsLayer:objectsLayer;
		private var __coinController:coinController;
		private var __player:Image;
		private var __playerShadow:Image;
		private var __frame:uint;
		private var __position:Number;
		private var __speed:speedController;
		
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
			removeEventListener("SCENE_INITIALIZED", onSceneInitialized);
			//in this point scene is fully visible
			//...
			__position = 0;
			__frame = 0;
			__speed = new speedController(20, 8, 0.3);
			//background layer
			__backgroundLayer = new backgroundLayersObject();
			addChild(__backgroundLayer);
			//objects layer
			__objectsLayer = new objectsLayer();
			addChild(__objectsLayer);
			//coin controller
			__coinController = new coinController(__objectsLayer);
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
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
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
			//update object layers
			__objectsLayer.updateFrame(__position);
			//
			__player.y = 270 + 10 * Math.sin(Math.PI * __position / 180);
			__playerShadow.scaleX = 0.84 + 0.08 * Math.sin(Math.PI * __position / 180);
			__playerShadow.scaleY = 0.84 + 0.08 * Math.sin(Math.PI * __position / 180);
		}
	}
}
