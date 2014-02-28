package ui.scenes.game.objects.utils {
	import flash.geom.Point;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * 2014-02-11
	 * @author Pavol Kusovsky
	 */
	public class parallaxLayer extends Sprite {
		//variable to hold the Image objects
		private var __vectorImages:Vector.<Image>;
		private var __vectorImagesLength:uint;
		//variables to define Tiles
		private var __tileWidth:uint;
		private var __tileHeight:uint;
		private var __tileData:Array;
		private var __tileDataLength:uint;
		private var __parallaxLayerWidth:uint;
		private var __parallaxLayerID:String;
		private var __tileOffset:Point;
		//is looping possible
		private var __parallaxLoop:Boolean;
		//speed ratio
		private var __speed:Number;
		//variable to hold last offset value - optimisation technique - no need to change texture if equal with current
		private var __oldOffsetX:int;
		
		public function parallaxLayer(sID:String, iTileWidth:uint, iTileHeight:uint, aTileData:Array, nSpeed:Number = 1, iTopLeftX:int = 0, iTopLeftY:int = 0, bLoop:Boolean = true) {
			super();
			//create vector of images that hold the tiles
			__vectorImages = new Vector.<Image>();
			//set up variables
			__parallaxLayerID = sID;
			__tileWidth = iTileWidth;
			__tileHeight = iTileHeight;
			__parallaxLoop = bLoop;
			__tileData = aTileData.slice(0);
			__tileDataLength = __tileData.length;
			__speed = nSpeed;
			__oldOffsetX = -1;
			__tileOffset = new Point(iTopLeftX, iTopLeftY);
			__parallaxLayerWidth = __tileWidth * __tileDataLength - config.__WINDOW_WIDTH;
			//throw error if paralax X size is less then stageWidth
			if ((__tileDataLength * iTileWidth) < config.__WINDOW_WIDTH) {
				throw new Error("[parallaxLayer \"" + __parallaxLayerID + "\"] Error: Layer width is less than stageWidth!");
			}
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			var i:uint;
			__vectorImagesLength = Math.ceil(config.__WINDOW_WIDTH / __tileWidth) + 1;
			var image:Image;
			for (i = 0; i < __vectorImagesLength; i++) {
				//TODO zatial to mam iba jednoriadkovy paralax
				//set image as empty but set correct size
				image = new Image(assets.getAtlas().getTexture("background_empty"));
				image.width = __tileWidth;
				image.height = __tileHeight;
				//set position
				image.x = __tileOffset.x + i * __tileWidth;
				image.y = __tileOffset.y;
				__vectorImages.push(image);
				addChild(image);
			}
		}
		
		public function setPosition(iPosition:Number):void {
			//set counter to 0
			var __counter:uint = 0;
			iPosition *= __speed;
			if (iPosition < 0) {
				iPosition = 0;
				trace("[parallaxLayer \"" + __parallaxLayerID + "\"] Warning: iPosition less then 0. Value changed to 0.");
			}
			//if loop is OFF and iPosition is less then layerWidth I can proceed
			if ((iPosition > __parallaxLayerWidth) && (!__parallaxLoop)) {
				//set iPosition to the latest value
				iPosition = __parallaxLayerWidth;
			}
			//calculate starting point in the texture array
			var offsetX:uint = int(iPosition / __tileWidth) % __tileDataLength;
			//set position x - based on MOD
			this.x = -int(iPosition % __tileWidth);
			//if offset is the same - no need to change textures - Optimisation technique
			if (__oldOffsetX != offsetX) {
				//update __oldOffsetX
				__oldOffsetX = offsetX;
				//calculate how much tiles I have
				while (__counter < __vectorImagesLength) {
					//set correct texture
					__vectorImages[__counter].texture = assets.getAtlas().getTexture(__tileData[(__counter + offsetX) % __tileDataLength]);
					__counter++;
				}
			}
		}
	}
}