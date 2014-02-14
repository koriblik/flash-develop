package ui.scenes.loader {
	import config;
	import starling.events.Event;
	import ui.scenes.baseScene;
	
	/**
	 * 2014-01-15
	 * @author Pavol Kusovsky
	 */
	public class loaderScene extends baseScene {
		
		public function loaderScene() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			//remove listener
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage); 
			//fade in can be called only after scene is ready on stage
			//this should be last thing to be displayed
			fadeIn({duration: config.__FADE_SCENE_DELAY, color: 0xff000000, width: config.__WINDOW_WIDTH, height: config.__WINDOW_HEIGHT});
			addEventListener("SCENE_INITIALIZED", onSceneInitialized);
			trace("[loaderScene] addedToStage");
		}
		
		private function onSceneInitialized(e:Event):void {
			removeEventListener("SCENE_INITIALIZED", onSceneInitialized);
			//in this point scene is fully visible
			//...
			fadeOutAndClose({duration: config.__FADE_SCENE_DELAY, color: 0xff000000, width: config.__WINDOW_WIDTH, height: config.__WINDOW_HEIGHT});
			config.__ACTIVE_SCENE = "mainMenuScene";
		}
	}
}
