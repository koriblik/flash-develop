package {
	import flash.display.Stage;
	import flash.sensors.Accelerometer;
	import flash.system.Capabilities;
	
	/**
	 * 2014-01-14
	 * @author Pavol Kusovsky
	 */
	public class config {
		static public const __SHARED_OBJECT_LOCAL_NAME:String = "koriblik/jimc";
		static public const __SHARED_OBJECT_LOCAL_PATH:String = "/";
		static public const __FADE_SCENE_DELAY:Number = 0.2;
		static public const __DEFAULT_WIDTH:uint = 910;
		static public const __DEFAULT_HEIGHT:uint = 512;
		static public const __TOUCH_PANEL_SIZE:Number = .7;
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
		static public var __ANDROID_DEVICE:Boolean;
		//storage data object
		static public var __DATA_OBJECT:Object;
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
			//detect if this is mobile device)
			__MOBILE_DEVICE = Accelerometer.isSupported;
			__ANDROID_DEVICE = true;
			if (__MOBILE_DEVICE) {
				__WINDOW_WIDTH = stage.fullScreenWidth;
				__WINDOW_HEIGHT = stage.fullScreenHeight;
			} else {
				__WINDOW_WIDTH = stage.stageWidth;
				__WINDOW_HEIGHT = stage.stageHeight;
			}
			__WINDOW_SCALE = (__WINDOW_HEIGHT / __DEFAULT_HEIGHT);
			__MENU_BG_COLOR = 0xffff00ff;
			__LEVEL_GRAPHIC_DATA = new Array();
			__LEVEL_COINS_DATA = new Array();
			__LEVEL_OBSTACLES_DATA = new Array();
			//TODO set data
			__DATA_OBJECT = new Object();
			__DATA_OBJECT.leftHanededAlignment = false;
		}
		
		static public function loadData():void {
			loadLevelData();
			//loadCoinsData();
			//loadObstaclesData();
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
			var levelCounter:uint = 0;
			var sectionStart:uint = 0;
			//load textures from the game level
			maxItems = assets.__levelXML.descendants("leveltexture").length();
			var textures:Array = new Array();
			for (i = 0; i < maxItems; i++) {
				textures[String(assets.__levelXML.descendants("leveltexture")[i].@id)] = assets.__levelXML.descendants("leveltexture")[i].@name;
			}
			//load templates from the game level
			maxItems = assets.__levelXML.descendants("leveltemplate").length();
			var templates:Array = new Array();
			for (i = 0; i < maxItems; i++) {
				templates[String(assets.__levelXML.descendants("leveltemplate")[i].@id)] = assets.__levelXML.descendants("leveltemplate")[i];
			}
			//load the level textures from sections defined
			maxSections = assets.__levelXML.descendants("section").length();
			for (i = 0; i < maxSections; i++) {
				repeats = uint(assets.__levelXML.descendants("section")[i].@repeat);
				subSize = uint(assets.__levelXML.descendants("section")[i].@sub_size);
				for (j = 0; j < repeats; j++) {
					sectionStart = levelCounter;
					templateList = templates[String(assets.__levelXML.descendants("section")[i].@template_id)];
					//load number of items in Template
					maxItems = templateList.children().length();
					for (k = 0; k < maxItems; k++) {
						switch (templateList.children()[k].name().toString()) {
							case "for": 
								maxFor = templateList.children()[k].children().length();
								for (l = 0; l < subSize; l++) {
									for (m = 0; m < maxFor; m++) {
										__LEVEL_GRAPHIC_DATA.push(textures[String(templateList.children()[k].children()[m].@texture_id)]);
										levelCounter++;
									}
								}
								break;
							case "item": 
								__LEVEL_GRAPHIC_DATA.push(textures[String(templateList.children()[k].@texture_id)]);
								levelCounter++;
								break;
						}
					}
					//lets add coins here
					loadCoinsData(assets.__levelXML.descendants("section")[i], uint(assets.__levelXML.level.textures.@width) * sectionStart);
					loadObstaclesData(assets.__levelXML.descendants("section")[i], uint(assets.__levelXML.level.textures.@width) * sectionStart);
				}
			}
			//calculate level size
			__LEVEL_SIZE = __LEVEL_GRAPHIC_DATA.length * uint(assets.__levelXML.level.textures.@width) - __WINDOW_WIDTH;
		}
		
		static public function loadCoinsData(xXML:XML, uPosition:uint):void {
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
			//TODO this should be optimized by removing this part away from this function
			maxItems = assets.__levelXML.descendants("cointemplate").length();
			var templates:Array = new Array();
			for (i = 0; i < maxItems; i++) {
				templates[String(assets.__levelXML.descendants("cointemplate")[i].@id)] = assets.__levelXML.descendants("cointemplate")[i];
			}
			//load coins from sections defined
			maxSections = xXML.descendants("coin").length();
			for (i = 0; i < maxSections; i++) {
				position = uint(xXML.descendants("coin")[i].@position);
				templateList = templates[String(xXML.descendants("coin")[i].@template_id)];
				//load number of items in Template
				maxItems = templateList.children().length();
				for (j = 0; j < maxItems; j++) {
					repeats = uint(templateList.children()[j].@repeat);
					space = uint(templateList.children()[j].@space);
					for (k = 0; k < repeats; k++) {
						__LEVEL_COINS_DATA.push({position: uint(uPosition + position * uint(assets.__levelXML.level.textures.@width) + Number(templateList.children()[j].@position) * space + k * space), line: uint(templateList.children()[j].@line)});
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
		
		static private function loadObstaclesData(xXML:XML, uPosition:uint):void {
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
			//TODO this should be optimized by removing this part away from this function
			maxItems = assets.__levelXML.descendants("obstacletype").length();
			var textures:Array = new Array();
			for (i = 0; i < maxItems; i++) {
				textures[assets.__levelXML.descendants("obstacletype")[i].@id] = assets.__levelXML.descendants("obstacletype")[i];
			}
			//add attributes of the obstacle
			maxItems = xXML.descendants("obstacle").length();
			for (i = 0; i < maxItems; i++) {
				__LEVEL_OBSTACLES_DATA.push({name: String(textures[xXML.descendants("obstacle")[i].@type_id].@id), position: uPosition + uint(xXML.descendants("obstacle")[i].@position) * uint(assets.__levelXML.level.textures.@width), line: uint(xXML.descendants("obstacle")[i].@line), blink: uint(xXML.descendants("obstacle")[i].@blink), wide: uint(textures[xXML.descendants("obstacle")[i].@type_id].@wide), tall: Number(textures[xXML.descendants("obstacle")[i].@type_id].@tall), row: uint(textures[xXML.descendants("obstacle")[i].@type_id].@row), pivotX: uint(textures[xXML.descendants("obstacle")[i].@type_id].@pivotx), pivotY: uint(textures[xXML.descendants("obstacle")[i].@type_id].@pivoty), width: uint(textures[xXML.descendants("obstacle")[i].@type_id].@width), height: uint(textures[xXML.descendants("obstacle")[i].@type_id].@height), collisionXPoint: uint(textures[xXML.descendants("obstacle")[i].@type_id].@collisionxpoint), action: String(textures[xXML.descendants("obstacle")[i].@type_id].@action)});
			}
			//TODO sort them
			for (i = 0; i < __LEVEL_OBSTACLES_DATA.length; i++) {
				j = i;
				if (j > 0) {
					//if current position is less then previous - bubble down
					while ((__LEVEL_OBSTACLES_DATA[j].position < __LEVEL_OBSTACLES_DATA[j - 1].position)) {
						//switch
						__LEVEL_OBSTACLES_DATA.splice(j - 1, 0, __LEVEL_OBSTACLES_DATA.splice(j, 1)[0]);
						j--;
						if (j == 0) {
							break;
						}
					}
				}
			}
		}
	
	}
}