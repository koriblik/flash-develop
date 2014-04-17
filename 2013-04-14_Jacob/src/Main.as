package {
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import flash.text.TextField;
	import ui.applicationClass;
	
	/**
	 * 2014-04-14
	 * @author Pavol Kusovsky
	 */
	public class Main extends Sprite {
		private var __starling:Starling;
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
			//!delete
			__tempOutput = new TextField();
			addChild(__tempOutput);
			__tempOutput.width = 300;
			__tempOutput.height = 180;
			__tempOutput.multiline = true;
			__tempOutput.textColor = 0xff0000;
			//!
			config.initialize(stage);
			//Create a Starling instance that will run the "application" class
			Starling.multitouchEnabled = true;
			__starling = new Starling(applicationClass, stage, new Rectangle(0, 0, config.__WINDOW_WIDTH, config.__WINDOW_HEIGHT));
			__starling.simulateMultitouch = true;
			Starling.current.stage.stageWidth = (config.__WINDOW_WIDTH / config.__WINDOW_SCALE);
			Starling.current.stage.stageHeight = (config.__WINDOW_HEIGHT / config.__WINDOW_SCALE);
			config.__WORKING_WIDTH = config.__WINDOW_WIDTH / config.__WINDOW_SCALE;
			config.__WORKING_HEIGHT = config.__DEFAULT_HEIGHT;
			//in this point my default height is __DEFAULT_HEIGHT and
			__starling.antiAliasing = 1;
			__starling.showStats = true;
			__starling.showStatsAt("right", "top", 1);
			__starling.start();
			__tempOutput.htmlText += "__WINDOW_WIDTH: " + config.__WINDOW_WIDTH + "\n__WINDOW_HEIGHT: " + config.__WINDOW_HEIGHT + "\n__WINDOW_SCALE: " + config.__WINDOW_SCALE;
		}
	}
}