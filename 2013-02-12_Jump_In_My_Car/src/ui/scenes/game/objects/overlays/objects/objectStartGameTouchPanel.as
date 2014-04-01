package ui.scenes.game.objects.overlays.objects {
	import feathers.display.Scale9Image;
	import feathers.textures.Scale9Textures;
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.TextureSmoothing;
	
	/**
	 * 2014-04-01
	 * @author PAvol Kusovsky
	 */
	public class objectStartGameTouchPanel extends Sprite {
		private var __leftHanededAlignment:Boolean;
		private var __panelSize:uint;
		private var __panelSprite:Scale9Image;
		private var __gestureTap:Image;
		private var __iconJump:Image;
		
		public function objectStartGameTouchPanel(bLeftHanededAlignment:Boolean, uPanelSize:uint) {
			super();
			__leftHanededAlignment = bLeftHanededAlignment;
			__panelSize = uPanelSize;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			__panelSprite = new Scale9Image(new Scale9Textures(assets.getAtlas().getTexture("overlay_rectangle_9slice"), new Rectangle(1, 1, 1, 1)));
			__panelSprite.smoothing = TextureSmoothing.NONE;
			__panelSprite.width = __panelSize;
			__panelSprite.height = config.__DEFAULT_HEIGHT;
			this.addChild(__panelSprite);
			__gestureTap = new Image(assets.getAtlas().getTexture("gesture_tap"));
			__gestureTap.alignPivot("center", "center");
			addChild(__gestureTap);
			__iconJump = new Image(assets.getAtlas().getTexture("overlay_jump"));
			__iconJump.alignPivot("center", "center");
			addChild(__iconJump);
			updatePositions(__leftHanededAlignment);
		}
		
		public function updatePositions(bLeftHanededAlignment:Boolean):void {
			__leftHanededAlignment = bLeftHanededAlignment;
			if (__leftHanededAlignment) {
				__gestureTap.x = 30 + (__gestureTap.width / 2);
				__iconJump.x = __gestureTap.x + ((__gestureTap.width / 2) + __iconJump.width / 2);
			} else {
				__gestureTap.x = __panelSprite.width - (30 + (__gestureTap.width / 2));
				__iconJump.x = __gestureTap.x -  ((__gestureTap.width / 2) + __iconJump.width / 2);
			}
			__gestureTap.y = config.__DEFAULT_HEIGHT / 2;
			__iconJump.y = config.__DEFAULT_HEIGHT / 2;
		}
	}
}