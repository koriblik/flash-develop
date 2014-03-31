package ui.scenes.game.objects {
	import starling.display.Sprite;
	import starling.events.Event;
	import ui.scenes.game.objects.utils.parallaxLayer;
	
	/**
	 * 2014-02-24
	 * @author Pavol Kusovsky
	 */
	public class backgroundLayersObject extends Sprite {
		private var __layer01:parallaxLayer;
		private var __layer02:parallaxLayer;
		private var __levelLayer01:parallaxLayer;
		
		public function backgroundLayersObject() {
			super();
			touchable = false;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			var i:uint = 0;
			//remove listener
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			//add layers
			var tiles01:Array = new Array();
			while (i < config.__WINDOW_WIDTH) {
				tiles01.push("background_layer01");
				i += assets.getAtlas().getTexture("background_layer01").width;
			}
			__layer01 = new parallaxLayer("bg_layer01", 128, 192, tiles01, .3, 0, 128);
			addChild(__layer01);
			i = 0;
			var tiles02:Array = new Array();
			while (i < config.__WINDOW_WIDTH) {
				tiles02.push("background_layer02");
				i += assets.getAtlas().getTexture("background_layer02").width;
			}
			__layer02 = new parallaxLayer("bg_layer02", 128, 128, tiles02, .4, 0, 0);
			addChild(__layer02);
			__levelLayer01 = new parallaxLayer("foreground_layer01", 128, 192, config.__LEVEL_GRAPHIC_DATA, 1, 0, 320, false);
			addChild(__levelLayer01);
			initialize();
		}
		
		public function initialize():void {
			updateFrame(0);
		}
		
		public function updateFrame(nPosition:Number):void {
			//update layers positions
			__layer01.setPosition(nPosition);
			__layer02.setPosition(nPosition);
			__levelLayer01.setPosition(nPosition);
		}
	}
}