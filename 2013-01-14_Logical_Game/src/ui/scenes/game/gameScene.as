package ui.scenes.game
{
	import config;
	import ui.scenes.game.objects.parallaxLayer;
	import starling.events.Event;
	import starling.textures.Texture;
	import ui.scenes.baseScene;
	
	/**
	 * 2014-01-15
	 * @author Pavol Kusovsky
	 */
	public class gameScene extends baseScene
	{
		private var __layer01:parallaxLayer;
		private var __layer02:parallaxLayer;
		private var __layer04:parallaxLayer;
		private var __position:uint;
		
		public function gameScene()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			__position = 0;
		}
		
		private function onAddedToStage(e:Event):void
		{
			//remove listener
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			//fade in can be called only after scene is ready on stage
			//this should be last thing to be displayed
			fadeIn({duration: config.__FADE_SCENE_DELAY, color: 0xffffffff, width: config.__WINDOW_WIDTH, height: config.__WINDOW_HEIGHT});
			addEventListener("SCENE_INITIALIZED", onSceneInitialized);
			trace("[gameScene] addedToStage");
		}
		
		private function onSceneInitialized(e:Event):void
		{
			removeEventListener("SCENE_INITIALIZED", onSceneInitialized);
			//in this point scene is fully visible
			//...
			var tiles01:Array = new Array("background_layer01", "background_layer01", "background_layer01", "background_layer01", "background_layer01", "background_layer01");
			__layer01 = new parallaxLayer(94, 117, tiles01, 0.3, 0, 67);
			addChild(__layer01);
			var tiles02:Array = new Array("background_layer02", "background_layer02", "background_layer02", "background_layer02", "background_layer02", "background_layer02", "background_layer02");
			__layer02 = new parallaxLayer(94, 67, tiles02, .4, 0, 0);
			addChild(__layer02);
			var tiles04:Array = new Array("background_layer04", "background_layer04", "background_layer04", "background_layer04");
			__layer04 = new parallaxLayer(187, 130, tiles04, 1, 0, 184);
			addChild(__layer04);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event:Event):void
		{
			__position +=13;
			__layer01.setPosition(__position);
			__layer02.setPosition(__position);
			__layer04.setPosition(__position);
		}
	}
}
