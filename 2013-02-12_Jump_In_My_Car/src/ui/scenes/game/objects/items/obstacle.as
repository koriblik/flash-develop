package ui.scenes.game.objects.items {
	import starling.display.Image;
	import starling.display.Sprite;
	
	/**
	 * 2014-03-05
	 * @author Pavol Kusovsky
	 */
	public class obstacle extends Sprite {
		
		private const BLINK_DELAY:uint = 30;
		private var __sprite:Image;
		public var __data:Object;
		private var __frame:uint;
		
		public function obstacle() {
			super();
			__sprite = new Image(assets.getAtlas().getTexture("empty_1x1"));
			addChild(__sprite);
		}
		
		public function initialize(oData:Object):void {
			//data name, position, line, wide, tall, row, pivotX, pivotY, width, height
			__data = oData;
			//set texture
			__sprite.texture = assets.getAtlas().getTexture(__data.name);
			__sprite.readjustSize();
			__sprite.pivotX = __data.pivotX;
			__sprite.pivotY = __data.pivotY;
			this.x = __data.position;
			this.y = 0;
			__frame = 0;
		}
		
		/**
		 * Calculate frame to be displayed
		 */
		public function updateSprite():void {
			//TODO set frame based on current position
			/*delete
			   var frame:uint = ((__position + __frame) / 8) % 8;
			   __sprite.texture = assets.getAtlas().getTexture("coin0" + (frame + 1).toString());
			   __shadow.visible = true;
			 */
			__frame++;
		}
		
		/**
		 * Check if obstacle is still presented on screen
		 * @param	nPosition
		 * @return
		 */
		public function checkVisibility(nPosition:Number):Boolean {
			if (nPosition > (__data.position - __data.pivotX + __data.width)) {
				return true;
			} else {
				return false;
			}
		}
		
		/**
		 * Return line number so I can remove it from display list
		 */
		public function getLine():uint {
			return __data.line + __data.row * 3;
		}
	}
}