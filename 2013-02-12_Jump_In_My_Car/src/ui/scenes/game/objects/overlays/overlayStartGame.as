package ui.scenes.game.objects.overlays {
	import extensions.starling.customButton;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import caurina.transitions.Tweener;
	import starling.events.TouchPhase;
	import starling.textures.TextureSmoothing;
	import ui.scenes.game.objects.overlays.objects.objectStartGameMovePanel;
	import ui.scenes.game.objects.overlays.objects.objectStartGameTouchPanel;
	
	/**
	 * 2014-03-07
	 * @author Pavol Kusovsky
	 */
	public class overlayStartGame extends Sprite {
		public static const __EVENT_START:String = "eventStarted";
		private var __TWEEN_DURATION:Number = 0.3;
		private var __sprite:Image;
		private var __reload:Boolean;
		private var __panelTouch:objectStartGameTouchPanel;
		private var __panelMove:objectStartGameMovePanel;
		private var __switchButton:customButton;
		private var __playButton:customButton;
		
		public function overlayStartGame() {
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			__panelTouch = new objectStartGameTouchPanel(config.__DATA_OBJECT.leftHanededAlignment, uint(config.__WINDOW_WIDTH * config.__TOUCH_PANEL_SIZE));
			addChild(__panelTouch);
			__panelMove = new objectStartGameMovePanel(config.__DATA_OBJECT.leftHanededAlignment, uint(config.__WINDOW_WIDTH * (1 - config.__TOUCH_PANEL_SIZE)));
			addChild(__panelMove);
			__sprite = new Image(assets.getAtlas().getTexture("empty_1x1"));
			addChild(__sprite);
			__sprite.smoothing = TextureSmoothing.NONE;
			__sprite.width = config.__WINDOW_WIDTH;
			__sprite.height = config.__WINDOW_HEIGHT
			__sprite.alignPivot("left", "top");
			__sprite.x = 0;
			__sprite.y = 0;
			//switch button
			__switchButton = new customButton(assets.getAtlas().getTexture("buttonSwitch"));
			__switchButton.alignPivot("center", "center");
			addChild(__switchButton);
			__playButton = new customButton(assets.getAtlas().getTexture("buttonPlay"));
			__playButton.alignPivot("center", "center");
			addChild(__playButton);
			this.visible = false;
		}
		
		public function initialize():void {
			//set inital positions
			setPositions();
			if (config.__DATA_OBJECT.leftHanededAlignment) {
				Tweener.addTween(__panelTouch, {x: 0, time: __TWEEN_DURATION, delay: 0, transition: "easeInSine", onComplete: null});
				Tweener.addTween(__panelMove, {x: uint(Number(config.__TOUCH_PANEL_SIZE) * config.__WINDOW_WIDTH), time: __TWEEN_DURATION, delay: 0, transition: "easeInSine", onComplete: tweenInCompleted});
			} else {
				Tweener.addTween(__panelTouch, {x: uint(Number(1 - config.__TOUCH_PANEL_SIZE) * config.__WINDOW_WIDTH), time: __TWEEN_DURATION, delay: 0, transition: "easeInSine", onComplete: null});
				Tweener.addTween(__panelMove, {x: 0, time: __TWEEN_DURATION, delay: 0, transition: "easeInSine", onComplete: tweenInCompleted});
			}
			Tweener.addTween(__switchButton, {y: __switchButton.height / 2, time: __TWEEN_DURATION, delay: 0, transition: "easeInSine", onComplete: null});
			Tweener.addTween(__playButton, {y: config.__DEFAULT_HEIGHT - __switchButton.height, time: __TWEEN_DURATION, delay: 0, transition: "easeInSine", onComplete: null});
			__reload = false;
			//visualize
			this.visible = true;
		}
		
		private function setPositions():void {
			//set position
			__switchButton.y = -__switchButton.height / 2;
			__playButton.x = config.__WINDOW_WIDTH / 2;
			__playButton.y = config.__DEFAULT_HEIGHT + __switchButton.height / 2;
			if (config.__DATA_OBJECT.leftHanededAlignment) {
				__panelTouch.x = -uint(Number(config.__TOUCH_PANEL_SIZE) * config.__WINDOW_WIDTH);
				__panelMove.x = config.__WINDOW_WIDTH;
				__switchButton.x = uint(Number(config.__TOUCH_PANEL_SIZE) * config.__WINDOW_WIDTH);
			} else {
				__panelTouch.x = config.__WINDOW_WIDTH;
				__panelMove.x = -uint(Number(1 - config.__TOUCH_PANEL_SIZE) * config.__WINDOW_WIDTH);
				__switchButton.x = uint(Number(1 - config.__TOUCH_PANEL_SIZE) * config.__WINDOW_WIDTH);
			}
		}
		
		private function tweenInCompleted():void {
			//set handlers
			__switchButton.addEventListener(Event.TRIGGERED, onSwitchButtonClick);
			__playButton.addEventListener(Event.TRIGGERED, onPlayButtonClick);
		}
		
		private function onPlayButtonClick(e:Event):void {
			tweenOut();
		}
		
		private function onSwitchButtonClick(e:Event):void {
			tweenOut(true);
		}
		
		private function tweenOut(bReload:Boolean = false):void {
			//remove events
			__switchButton.removeEventListener(Event.TRIGGERED, onSwitchButtonClick);
			__playButton.removeEventListener(Event.TRIGGERED, onPlayButtonClick);
			//set tweeners
			if (config.__DATA_OBJECT.leftHanededAlignment) {
				Tweener.addTween(__panelTouch, {x: -uint(Number(config.__TOUCH_PANEL_SIZE) * config.__WINDOW_WIDTH), time: __TWEEN_DURATION, delay: 0, transition: "easeInSine", onComplete: null});
				Tweener.addTween(__panelMove, {x: config.__WINDOW_WIDTH, time: __TWEEN_DURATION, delay: 0, transition: "easeInSine", onComplete: tweenOutCompleted});
			} else {
				Tweener.addTween(__panelTouch, {x: config.__WINDOW_WIDTH, time: __TWEEN_DURATION, delay: 0, transition: "easeInSine", onComplete: null});
				Tweener.addTween(__panelMove, {x: -uint(Number(1 - config.__TOUCH_PANEL_SIZE) * config.__WINDOW_WIDTH), time: __TWEEN_DURATION, delay: 0, transition: "easeInSine", onComplete: tweenOutCompleted});
			}
			Tweener.addTween(__switchButton, {y: -__switchButton.height / 2, time: __TWEEN_DURATION, delay: 0, transition: "easeInSine", onComplete: null});
			Tweener.addTween(__playButton, {y: config.__DEFAULT_HEIGHT + __switchButton.height / 2, time: __TWEEN_DURATION, delay: 0, transition: "easeInSine", onComplete: null});
			__reload = bReload;
		}
		
		private function tweenOutCompleted():void {
			if (__reload) {
				config.__DATA_OBJECT.leftHanededAlignment = !config.__DATA_OBJECT.leftHanededAlignment;
				initialize();
			} else {
				deinitialize();
			}
		}
		
		public function deinitialize():void {
			//visualize
			this.visible = false;
			//dispatch event that I am finished
			dispatchEventWith(__EVENT_START);
		}
	
	}
}