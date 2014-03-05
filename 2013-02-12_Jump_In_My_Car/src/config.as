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
		static public var __STAGE:Stage;
		static public var __FRAME_RATE:uint;
		static public var __DELTA_TIME:Number;
		static public var __SCENES:Array;
		static public var __WINDOW_WIDTH:uint;
		static public var __WINDOW_HEIGHT:uint;
		static public var __MENU_BG_COLOR:uint;
		//textures in the level - ground
		static public var __LEVEL_GRAPHIC_DATA:Array;
		//length of the level in pixels
		static public var __LEVEL_SIZE:uint;
		//coins array
		static public var __LEVEL_COINS_DATA:Array;
		//obstacles array
		static public var __LEVEL_OBSTACLES_DATA:Array;
		
		static public function initialize(stage:Stage):void {
			__SCENES = new Array();
			__STAGE = stage;
			__FRAME_RATE = __STAGE.frameRate;
			__DELTA_TIME = 1 / __FRAME_RATE;
			__WINDOW_WIDTH = stage.stageWidth;
			__WINDOW_HEIGHT = stage.stageHeight;
			__MENU_BG_COLOR = 0xffff00ff;
			__LEVEL_GRAPHIC_DATA = new Array();
			__LEVEL_COINS_DATA = new Array();
			__LEVEL_OBSTACLES_DATA = new Array();
			loadLevelData();
			loadCoinsData();
			loadObstaclesData();
		}
		
		static private function loadObstaclesData():void {
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
			//load textures from the obstacles
			maxItems = assets.__obstaclesXML.descendants("type").length();
			var textures:Array = new Array();
			for (i = 0; i < maxItems; i++) {
				textures[assets.__obstaclesXML.descendants("type")[i].@id] = assets.__obstaclesXML.descendants("type")[i];
			}
			maxItems = assets.__obstaclesXML.descendants("obstacle").length();
			for (i = 0; i < maxItems; i++) {
				__LEVEL_OBSTACLES_DATA.push( { name: textures[assets.__obstaclesXML.descendants("obstacle")[i].@type_id].@id, position: uint(assets.__obstaclesXML.descendants("obstacle")[i].@position), line: uint(assets.__obstaclesXML.descendants("obstacle")[i].@line) } );
				//TODO add the rest of parameters from texture array
				//align="top" wide="1" tall="1" row="0" pivotx="0" pivoty="106" width="48" height="138" 
				trace(__LEVEL_OBSTACLES_DATA[__LEVEL_OBSTACLES_DATA.length - 1].position);
			}
			//TODO sort them
		}
		
		static public function loadCoinsData():void {
			var i:uint;
			var j:uint;
			var k:uint;
			var maxItems:uint;
			var maxSections:uint;
			var position:uint;
			var repeats:uint;
			var space:uint;
			var templateList:XML = new XML();
			//load templates from the coins
			maxItems = assets.__coinsXML.descendants("template").length();
			var templates:Array = new Array();
			for (i = 0; i < maxItems; i++) {
				templates[assets.__coinsXML.descendants("template")[i].@id] = assets.__coinsXML.descendants("template")[i];
			}
			//load coins from sections defined
			maxSections = assets.__coinsXML.descendants("section").length();
			for (i = 0; i < maxSections; i++) {
				position = uint(assets.__coinsXML.descendants("section")[i].@position);
				templateList = templates[assets.__coinsXML.descendants("section")[i].@template_id];
				//load number of items in Template
				maxItems = templateList.children().length();
				for (j = 0; j < maxItems; j++) {
					repeats = uint(templateList.children()[j].@repeat);
					space = uint(templateList.children()[j].@space);
					for (k = 0; k < repeats; k++) {
						__LEVEL_COINS_DATA.push({position: uint(position + Number(templateList.children()[j].@position) * space + k * space), line: uint(templateList.children()[j].@line)});
					}
				}
			}
			//sort the data
			for (i = 0; i < __LEVEL_COINS_DATA.length; i++) {
				j = i;
				if (j > 0) {
					//if current position is less then previous - bubble down
					while ((__LEVEL_COINS_DATA[j].position < __LEVEL_COINS_DATA[j - 1].position)) {
						//switch
						__LEVEL_COINS_DATA.splice(j - 1, 0, __LEVEL_COINS_DATA.splice(j, 1)[0]);
						j--;
						if (j == 0) {
							break;
						}
					}
				}
			}
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
			//calculate level size
			__LEVEL_SIZE = __LEVEL_GRAPHIC_DATA.length * uint(assets.__levelXML.textures.@width) - __WINDOW_WIDTH;
		}
	}
}