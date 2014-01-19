package {
	import flash.display.Stage;
	
	/**
	 * 2014-01-14
	 * @author Pavol Kusovsky
	 */
	public class config {
		static public const __SHARED_OBJECT_LOCAL_NAME:String = "koriblik/LogicalGame";
		static public const __SHARED_OBJECT_LOCAL_PATH:String = "/";
		static public const __FADE_SCENE_DELAY:Number = 0.4;
		static public var __ACTIVE_SCENE:String = "";
		static public var __SCENES:Array;
		static public var __WINDOW_WIDTH:uint;
		static public var __WINDOW_HEIGHT:uint;
		static public var __MENU_BG_COLOR:uint;
		
		static public function initialize(stage:Stage):void {
			__SCENES = new Array();
			__WINDOW_WIDTH = stage.stageWidth;
			__WINDOW_HEIGHT = stage.stageHeight;
			__MENU_BG_COLOR = 0xffff00ff;
		}
	}
}