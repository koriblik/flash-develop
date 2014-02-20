package ui.scenes.game {
	import config;
	import starling.display.Image;
	import starling.events.Event;
	import ui.scenes.baseScene;
	import ui.scenes.game.objects.parallaxLayer;
	
	/**
	 * 2014-01-15
	 * @author Pavol Kusovsky
	 */
	public class gameScene extends baseScene {
		private var __layer01:parallaxLayer;
		private var __layer02:parallaxLayer;
		private var __levelLayer01:parallaxLayer;
		private var __player:Image;
		private var __playerShadow:Image;
		private var __position:uint;
		
		public function gameScene() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			__position = 0;
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
			var tiles01:Array = new Array("background_layer01", "background_layer01", "background_layer01", "background_layer01", "background_layer01", "background_layer01", "background_layer01");
			__layer01 = new parallaxLayer("bg_layer01", 128, 192, tiles01, 0.3, 0, 128);
			addChild(__layer01);
			var tiles02:Array = new Array("background_layer02", "background_layer02", "background_layer02", "background_layer02", "background_layer02", "background_layer02", "background_layer02");
			__layer02 = new parallaxLayer("bg_layer02", 128, 128, tiles02, 4, 0, 0);
			addChild(__layer02);
			__levelLayer01 = new parallaxLayer("foreground_layer03", 128, 192, config.__LEVEL_GRAPHIC_DATA, .5, 0, 320, false);
			addChild(__levelLayer01);
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
			__position += 8;
			__layer01.setPosition(__position);
			__layer02.setPosition(__position);
			__levelLayer01.setPosition(__position);
			__player.y = 270 + 10 * Math.sin(Math.PI * __position / 180);
			__playerShadow.scaleX = 0.84 + 0.08 * Math.sin(Math.PI * __position / 180);
			__playerShadow.scaleY = 0.84  + 0.08 * Math.sin(Math.PI * __position / 180);
		}
	}
}
