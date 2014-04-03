package ui.scenes.game.objects.overlays.objects {
	import extensions.starling.scale9Image;
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.TextureSmoothing;
	
	/**
	 * 2014-04-01
	 * @author PAvol Kusovsky
	 */
	public class objectStartGameMovePanel extends Sprite {
		private var __leftHanededAlignment:Boolean;
		private var __panelSize:uint;
		private var __panelSprite:scale9Image;
		private var __gestureUp:Image;
		private var __gestureDown:Image;
		private var __iconMove:Image
		
		public function objectStartGameMovePanel(bLeftHanededAlignment:Boolean, uPanelSize:uint) {
			super();
			__leftHanededAlignment = bLeftHanededAlignment;
			__panelSize = uPanelSize;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			__panelSprite = new scale9Image(assets.getAtlas().getTexture("overlay_rectangle_9slice"), new Rectangle(1, 1, 1, 1));
			__panelSprite.width = __panelSize;
			__panelSprite.height = config.__DEFAULT_HEIGHT;
			this.addChild(__panelSprite);
			__gestureUp = new Image(assets.getAtlas().getTexture("gesture_swipe_up"));
			__gestureUp.smoothing = TextureSmoothing.NONE;
			__gestureUp.alignPivot("center", "center");
			addChild(__gestureUp);
			__gestureDown = new Image(assets.getAtlas().getTexture("gesture_swipe_down"));
			__gestureDown.smoothing = TextureSmoothing.NONE;
			__gestureDown.alignPivot("center", "center");
			addChild(__gestureDown);
			__iconMove = new Image(assets.getAtlas().getTexture("overlay_move"));
			__iconMove.smoothing = TextureSmoothing.NONE;
			__iconMove.alignPivot("center", "center");
			addChild(__iconMove);
			updatePositions(__leftHanededAlignment);
		}
		
		public function updatePositions(bLeftHanededAlignment:Boolean):void {
			__leftHanededAlignment = bLeftHanededAlignment;
			if (__leftHanededAlignment) {
				__gestureUp.x = __panelSprite.width - (30 + (__gestureUp.width / 2));
				__gestureDown.x = __panelSprite.width - (30 + (__gestureDown.width / 2));
				__iconMove.x = __panelSprite.width - (30 + (__iconMove.width / 2));
			} else {
				__gestureUp.x = 30 + (__gestureUp.width / 2);
				__gestureDown.x = 30 + (__gestureDown.width / 2);
				__iconMove.x = 30 + (__gestureDown.width / 2);
			}
			__gestureUp.y = config.__DEFAULT_HEIGHT / 4;
			__gestureDown.y = 3 * config.__DEFAULT_HEIGHT / 4;
			__iconMove.y = config.__DEFAULT_HEIGHT / 2;
		}
	
	}

}