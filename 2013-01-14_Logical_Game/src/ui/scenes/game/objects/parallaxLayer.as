package ui.scenes.game.objects
{
	import starling.display.Sprite;
	import starling.display.Image;
	import starling.events.Event;
	
	/**
	 * 2014-02-11
	 * @author Pavol Kusovsky
	 */
	public class parallaxLayer extends Sprite
	{
		private var __vectorImages:Vector.<Image>;
		private var __tileWidth:uint;
		private var __tileHeight:uint;
		private var __tileData:Array;
		private var __tileDataLength:uint;
		private var __parallaxLoop:Boolean;
		private var __speed:Number;
		
		public function parallaxLayer(iTileWidth:uint, iTileHeight:uint, aTileData:Array, nSpeed:Number = 1, iTopLeftX:int = 0, iTopLeftY:int = 0, bLoop:Boolean = true)
		{
			super();
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
			//create vector of images that hold the tiles
			__vectorImages = new Vector.<Image>();
			__tileWidth = iTileWidth;
			__tileHeight = iTileHeight;
			__parallaxLoop = bLoop;
			__tileData = aTileData.slice(0);
			__tileDataLength = __tileData.length;
			__speed = nSpeed;
			var i:uint;
			var max:uint = Math.ceil(config.__WINDOW_WIDTH / iTileWidth) + 1;
			var image:Image;
			for (i = 0; i < max; i++)
			{
				//TODO zatial to mam iba jednoriadkovy paralax
				image = new Image(assets.getAtlas().getTexture("background_empty"));
				image.width = iTileWidth;
				image.height = iTileHeight;
				//set position
				image.x = iTopLeftX + i * iTileWidth;
				image.y = iTopLeftY;
				__vectorImages.push(image);
				addChild(image);
			}
		}
		
		private function onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		public function setPosition(iPosition:uint):void
		{
			iPosition *= __speed;
			if (iPosition < 0)
			{
				throw new Error("Position should not be less than 0!");
			}
			if (__parallaxLoop)
			{
				//set position x - based on MOD
				this.x = -int(iPosition % __tileWidth);
				//calculate starting point in the texture array
				
				//set counter to 0
				var __counter:uint = 0;
				//set texture where to begin
				var __offsetX:uint = int(iPosition / __tileWidth) % __tileDataLength;
				//calculate how much tiles I have
				var __xTilesLength:uint = __vectorImages.length;
				while (__counter < __xTilesLength)
				{
					//set correct texture
					__vectorImages[__counter].texture = assets.getAtlas().getTexture(__tileData[(__counter + __offsetX) % __tileDataLength]);
					__counter++;
				}
			}
		}
	}

}