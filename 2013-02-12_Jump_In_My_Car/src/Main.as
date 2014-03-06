package {
	import config;
	import assets;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import starling.core.Starling;
	import ui.applicationClass;
	
	/**
	 * 2014-01-14
	 * @author Pavol Kusovsky
	 */
	public class Main extends Sprite {
		private var __starling:Starling;
		public static var __tempDraw:MovieClip;
		public function Main():void {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			// entry point
			removeEventListener(Event.ADDED_TO_STAGE, init);
			assets.initialize();
			config.initialize(stage);
			//Create a Starling instance that will run the "application" class
			Starling.multitouchEnabled = false;
			__starling = new Starling(applicationClass, stage);
			__starling.antiAliasing = 1;
			__starling.showStats = true;
			__starling.showStatsAt("left", "bottom", 1);
			__starling.start();
			__tempDraw = new MovieClip();
			addChild(__tempDraw);
		}
	}
}