package ui.scenes.game.objects.overlays {
	import flash.ui.Keyboard;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.display.Sprite;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.TextureSmoothing;
	
	/**
	 * 2014-03-07
	 * @author Pavol Kusovsky
	 */
	public class overlayGameOver extends Sprite {
		public static const __EVENT_OVER:String = "eventOver";
		private var __sprite:Image;
		
		public function overlayGameOver() {
			super();
			__sprite = new Image(assets.getAtlas().getTexture("empty_1x1"));
			addChild(__sprite);
			__sprite.smoothing = TextureSmoothing.NONE;
			__sprite.width = config.__WINDOW_WIDTH;
			__sprite.height = config.__WINDOW_HEIGHT
			__sprite.alignPivot("left", "top");
			__sprite.x = 0;
			__sprite.y = 0;
			this.visible = false;
		}
		
		public function initialize():void {
			//visualize
			this.visible = true;
			//set handlers
			this.addEventListener(TouchEvent.TOUCH, touchHandler);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		public function deinitialize():void {
			//visualize
			this.visible = false;
			//remove handlers
			this.removeEventListener(TouchEvent.TOUCH, touchHandler);
			this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			//dispatch event that I am finished
			dispatchEvent(new Event(__EVENT_OVER));
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			//if any key pressed then deinitialize and start game
			deinitialize();
		}
		
		private function touchHandler(e:TouchEvent):void {
			//if clicked then deinitialize
			var touchEnded:Touch = e.getTouch(this, TouchPhase.ENDED);
			if (touchEnded){
				deinitialize();
			}
		}
	}
}