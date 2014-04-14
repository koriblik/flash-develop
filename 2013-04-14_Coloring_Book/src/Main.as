package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import ui.applicationClass;
	
	/**
	 * 2014-04-14
	 * @author Pavol Kusovsky
	 */
	public class Main extends Sprite {
		private var __starling:Starling;
		
		public function Main():void {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			// entry point
			removeEventListener(Event.ADDED_TO_STAGE, init);
			config.initialize(stage);
			//Create a Starling instance that will run the "application" class
			Starling.multitouchEnabled = true;
			__starling = new Starling(applicationClass, stage, new Rectangle(0, 0, config.__WINDOW_WIDTH, config.__WINDOW_HEIGHT));
			__starling.simulateMultitouch = true;
			Starling.current.stage.stageWidth = (config.__WINDOW_WIDTH / config.__WINDOW_SCALE);
			Starling.current.stage.stageHeight = (config.__WINDOW_HEIGHT / config.__WINDOW_SCALE);
			config.__WINDOW_WIDTH /= config.__WINDOW_SCALE;
			__starling.antiAliasing = 1;
			__starling.showStats = true;
			__starling.showStatsAt("left", "bottom", 2);
			__starling.start();
		}
	}

}