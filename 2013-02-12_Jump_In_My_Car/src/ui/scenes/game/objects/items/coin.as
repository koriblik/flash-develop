package ui.scenes.game.objects.items {
	import starling.display.Image;
	import starling.display.Sprite;
	
	/**
	 * 2014-02-24
	 * @author Pavol Kusovsky
	 */
	public class coin extends Sprite {
		private var __sprite:Image;
		private var __shadow:Image;
		private var __position:uint;
		private var __width:uint;
		private var __line:uint;
		private var __frame:uint;
		
		public function coin() {
			super();
			__shadow = new Image(assets.getAtlas().getTexture("coin_shadow"));
			__shadow.y = -__shadow.height / 2;
			addChild(__shadow);
			__sprite = new Image(assets.getAtlas().getTexture("coin00_empty"));
			addChild(__sprite);
			__width = __sprite.width;
			__sprite.pivotX = 0;
			__sprite.pivotY = __sprite.height;
			initialize(0, 0, 0, 0);
		}
		
		public function initialize(uPosition:uint, uLine:uint, uX:uint, uY:uint):void {
			__sprite.texture = assets.getAtlas().getTexture("coin00_empty");
			__shadow.visible = false;
			__position = uPosition;
			__line = uLine;
			this.x = uX;
			this.y = uY;
			__frame = 0;
		}
		
		/**
		 * Calculate frame to be displayed
		 */
		public function updateSprite():void {
			//set frame based on current position
			var frame:uint = ((__position + __frame) / 8) % 8;
			__sprite.texture = assets.getAtlas().getTexture("coin0" + (frame + 1).toString());
			__shadow.visible = true;
			__frame++;
		}
		
		/**
		 * Check if coin is still presented on screen
		 * @param	nPosition
		 * @return
		 */
		public function checkVisibility(nPosition:Number):Boolean {
			if (nPosition > (__position + __width)) {
				return true;
			} else {
				return false;
			}
		}
		
		/**
		 * Getter - return line number so I can remove it from display list
		 */
		public function get line():uint {
			return __line;
		}
		
		/**
		 * Getter - return position of coin
		 */
		public function get position():uint {
			return __position;
		}
		
		/**
		 * Get width of the coin
		 * @return	uint	width of the coin
		 */
		public function coinWidth():uint {
			return __sprite.width;
		}
	}
}