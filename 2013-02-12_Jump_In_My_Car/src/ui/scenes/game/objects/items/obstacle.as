package ui.scenes.game.objects.items {
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.TextureSmoothing;
	
	/**
	 * 2014-03-05
	 * @author Pavol Kusovsky
	 */
	public class obstacle extends Sprite {
		
		private const __BLINK_DELAY:uint = 30;
		public static const __UP_ROW_SPACE:uint = 52;
		private var __sprite:Image;
		public var __data:Object;
		//variable to indicate if already hit happened (due to jump obstacles - so I can check only once)
		private var __hit:Boolean;
		private var __frame:uint;
		
		public function obstacle() {
			super();
			__sprite = new Image(assets.getAtlas().getTexture("empty_1x1"));
			addChild(__sprite);
		}
		
		public function initialize(oData:Object):void {
			//data name, position, line, wide, tall, row, pivotX, pivotY, width, height, collisionXPoint, action
			__data = oData;
			//set texture
			__sprite.texture = assets.getAtlas().getTexture(__data.name);
			__sprite.smoothing = TextureSmoothing.NONE;
			__sprite.readjustSize();
			__sprite.pivotX = __data.pivotX;
			__sprite.pivotY = __data.pivotY;
			this.x = __data.position;
			this.y = 0;
			__hit = false;
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
		
		/**
		 * __hit Getter
		 * @return	Boolean		if already hit happened on this obstacle
		 */
		public function get hit():Boolean {
			return __hit;
		}
		
		/**
		 * __hit Setter
		 * @param	Boolean		set __hit value
		 */
		public function set hit(bHit:Boolean):void {
			__hit = bHit;
		}
	}
}