package {
	import flash.display.Stage;
	
	/**
	 * 2014-01-14
	 * @author Pavol Kusovsky
	 */
	public class config {
		static public const __SHARED_OBJECT_LOCAL_NAME:String = "koriblik/jimc";
		static public const __SHARED_OBJECT_LOCAL_PATH:String = "/";
		static public const __FADE_SCENE_DELAY:Number = 0.2;
		static public var __ACTIVE_SCENE:String = "";
		static public var __SCENES:Array;
		static public var __WINDOW_WIDTH:uint;
		static public var __WINDOW_HEIGHT:uint;
		static public var __MENU_BG_COLOR:uint;
		
		static public var __LEVEL_GRAPHIC_DATA:Array;
		
		static public function initialize(stage:Stage):void {
			__SCENES = new Array();
			__WINDOW_WIDTH = stage.stageWidth;
			__WINDOW_HEIGHT = stage.stageHeight;
			__MENU_BG_COLOR = 0xffff00ff;
			__LEVEL_GRAPHIC_DATA = new Array();
			loadLevelData();
		}
		
		static public function loadLevelData():void {
			var i:uint;
			var j:uint;
			var k:uint;
			var l:uint;
			var m:uint;
			var maxItems:uint;
			var maxSections:uint;
			var maxFor:uint;
			var repeats:uint;
			var subSize:uint;
			var templateList:XML = new XML();
			//load textures from the game level
			maxItems = assets.__levelXML.descendants("texture").length();
			var textures:Array = new Array();
			for (i = 0; i < maxItems; i++) {
				textures[assets.__levelXML.descendants("texture")[i].@id] = assets.__levelXML.descendants("texture")[i].@name;
			}
			//load templates from the game level
			maxItems = assets.__levelXML.descendants("template").length();
			var templates:Array = new Array();
			for (i = 0; i < maxItems; i++) {
				templates[assets.__levelXML.descendants("template")[i].@id] = assets.__levelXML.descendants("template")[i];
			}
			//load the level textures from sections defined
			maxSections = assets.__levelXML.descendants("section").length();
			for (i = 0; i < maxSections; i++) {
				repeats = uint(assets.__levelXML.descendants("section")[i].@repeat);
				subSize = uint(assets.__levelXML.descendants("section")[i].@sub_size);
				for (j = 0; j < repeats; j++) {
					templateList = templates[assets.__levelXML.descendants("section")[i].@template_id];
					//load number of items in Template
					maxItems = templateList.children().length();
					for (k = 0; k < maxItems; k++) {
						switch (templateList.children()[k].name().toString()) {
							case "for": 
								maxFor = templateList.children()[k].children().length();
								for (l = 0; l < subSize; l++) {
									for (m = 0; m < maxFor; m++) {
										__LEVEL_GRAPHIC_DATA.push(textures[templateList.children()[k].children()[m].@texture_id]);
									}
								}
								break;
							case "item": 
								__LEVEL_GRAPHIC_DATA.push(textures[templateList.children()[k].@texture_id]);
								break;
						}
					}
				}
			}
		}
	}
}