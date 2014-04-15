package {
	import flash.display.Stage;
	import flash.sensors.Accelerometer;
	import flash.system.Capabilities;
	
	/**
	 * 2014-04-14
	 * @author Pavol Kusovsky
	 */
	public class config {
		static public const __SHARED_OBJECT_LOCAL_NAME:String = "koriblik/coloringbook";
		static public const __SHARED_OBJECT_LOCAL_PATH:String = "/";
		static public const __FADE_SCENE_DELAY:Number = 0.2;
		static public const __DEFAULT_WIDTH:uint = 360;
		static public const __DEFAULT_HEIGHT:uint = 640;
		static public var __WORKING_WIDTH:uint;
		static public var __WORKING_HEIGHT:uint;
		static public var __ACTIVE_SCENE:String = "";
		static public var __STAGE:Stage;
		static public var __FRAME_RATE:uint;
		static public var __DELTA_TIME:Number;
		static public var __SCENES:Array;
		static public var __MENU_BG_COLOR:uint;
		static public var __WINDOW_WIDTH:uint;
		static public var __WINDOW_HEIGHT:uint;
		static public var __WINDOW_SCALE:Number;
		static public var __MOBILE_DEVICE:Boolean;
		
		/**
		 * initialize all parameters
		 * @param	stage
		 */
		static public function initialize(stage:Stage):void {
			__SCENES = new Array();
			__STAGE = stage;
			__FRAME_RATE = __STAGE.frameRate;
			__DELTA_TIME = 1 / __FRAME_RATE;
			//detect if this is mobile device)
			__MOBILE_DEVICE = Accelerometer.isSupported;
			//! delete
			__MOBILE_DEVICE = true;
			if (__MOBILE_DEVICE) {
				__WINDOW_WIDTH = stage.fullScreenWidth;
				__WINDOW_HEIGHT = stage.fullScreenHeight;
			} else {
				__WINDOW_WIDTH = stage.stageWidth;
				__WINDOW_HEIGHT = stage.stageHeight;
			}
			__WINDOW_SCALE = (__WINDOW_HEIGHT / __DEFAULT_HEIGHT);
		}
	
	}
}