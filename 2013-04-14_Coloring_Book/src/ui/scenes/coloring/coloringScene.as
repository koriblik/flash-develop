package ui.scenes.coloring {
	import config;
	import flash.accessibility.Accessibility;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import ui.scenes.baseScene;
	import ui.scenes.coloring.objects.freePaintingObject;
	
	/**
	 * 2014-01-15
	 * @author Pavol Kusovsky
	 */
	public class coloringScene extends baseScene {
		private var __object:freePaintingObject;
		public function coloringScene() {
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
			initialize();
		}
		
		/**
		 * Use this method to reset all data before restarting level
		 */
		public function initialize():void {
			__object = new freePaintingObject();
			addChild(__object);
		}
	}
}