package {
	import config;
	import assets;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import starling.core.Starling;
	import ui.applicationClass;
	
	/**
	 * 2014-01-14
	 * @author Pavol Kusovsky
	 */
	public class Main extends Sprite {
		private var __starling:Starling;
		public static var __tempDraw:MovieClip;
		public static var __tempOutput:TextField;
		
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
			__starling = new Starling(applicationClass, stage, new Rectangle(0, 0, config.__WINDOW_WIDTH, config.__WINDOW_HEIGHT));
			Starling.current.stage.stageWidth = (config.__WINDOW_WIDTH / config.__WINDOW_SCALE);
			Starling.current.stage.stageHeight = (config.__WINDOW_HEIGHT / config.__WINDOW_SCALE);
			config.__WINDOW_WIDTH /= config.__WINDOW_SCALE;
			config.loadData();
			__starling.antiAliasing = 1;
			__starling.showStats = true;
			__starling.showStatsAt("left", "bottom", 2);
			__starling.start();
			//TODO delete
			__tempDraw = new MovieClip();
			addChild(__tempDraw);
			__tempOutput = new TextField();
			addChild(__tempOutput);
			__tempOutput.width = 300;
			__tempOutput.height = 180;
			__tempOutput.multiline = true;
			__tempOutput.textColor = 0xff0000;
			__tempOutput.htmlText = "STATUS"
		}
	}
}