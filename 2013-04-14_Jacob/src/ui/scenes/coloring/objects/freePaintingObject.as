package ui.scenes.coloring.objects {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	import starling.utils.Color;
	import flash.events.KeyboardEvent;
	import starling.events.KeyboardEvent;
	import flash.desktop.NativeApplication;
	
	/**
	 * 2014-04-14
	 * @author pavol Kusovsky
	 *
	 * 	undo()
	 *  reset()
	 *  setMode() - select mode of the
	 */
	public class freePaintingObject extends Sprite {
		//mode constants
		public const __MODE_NONE:String = "none";
		public const __MODE_PAINT_BUCKET:String = "paint_bucket";
		public const __MODE_PENCIL:String = "pencil";
		public const __MODE_BRUSH:String = "brush";
		public const __MODE_SPRAY:String = "spray";
		public const __MODE_STICKER:String = "sticker";
		public const __MODE_ERASER:String = "eraser";
		public const __MODE_MAGNIFYING_GLASS:String = "magnifying_glass";
		private var __currentMode:String = __MODE_NONE;
		//
		private var __image:Image;
		private var __fullImage:Image;
		private var __objectSize:Point;
		private var __finalScale:Number;
		private var __finalSize:Point;
		private var __inputBitmap:Bitmap;
		private var __bitmapData:BitmapData;
		private var __deltaPoint:Point;
		//history
		private const __HISTORY_SIZE:uint = 10;
		private var __historyBitmaps:Vector.<BitmapData>;
		private var __historyIndex:uint;
		
		public function freePaintingObject(contents:DisplayObject = null) {
			super();
			useHandCursor = true;
			
			if (contents) {
				contents.x = int(contents.width / -2);
				contents.y = int(contents.height / -2);
				addChild(contents);
			}
			//TODO nahradit tieto dva listenery volanim priamo undo z toolbaru
			addEventListener(starling.events.KeyboardEvent.KEY_UP, onKeyUp);
			NativeApplication.nativeApplication.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, onNativeKeyDown);
		}
		
		private function onNativeKeyDown(e:flash.events.KeyboardEvent):void {
			if (e.keyCode == Keyboard.BACK) {
				e.preventDefault();
				undo();
			}
			if (e.keyCode == Keyboard.MENU) {
				switch (__currentMode) {
					case __MODE_NONE: 
						setMode(__MODE_PAINT_BUCKET);
						break;
					case __MODE_PAINT_BUCKET: 
						setMode(__MODE_MAGNIFYING_GLASS);
						break;
					case __MODE_MAGNIFYING_GLASS: 
						setMode(__MODE_NONE);
						break;
				}
			}
		}
		
		private function onKeyUp(e:starling.events.KeyboardEvent):void {
			//reset ak stlacim backspace
			if (e.keyCode == Keyboard.BACKSPACE) {
				undo();
			}
		}
		
		public function setMode(sMode:String):void {
			//remove all listeners and so on in the case of mode change
			switch (__currentMode) {
				case __MODE_PAINT_BUCKET: 
					removeEventListener(TouchEvent.TOUCH, onTouchPaintBucket);
					break;
				case __MODE_PENCIL: 
					break;
				case __MODE_BRUSH: 
					break;
				case __MODE_SPRAY: 
					break;
				case __MODE_STICKER: 
					break;
				case __MODE_ERASER: 
					break;
				case __MODE_MAGNIFYING_GLASS: 
					removeEventListener(TouchEvent.TOUCH, onTouchMagnifyingGlass);
					break;
				case __MODE_NONE: 
					//nothing necessary - just to remove all listeners is I reset
					break;
			}
			//set new mode
			__currentMode = sMode;
			//set all listeners based on mode
			switch (__currentMode) {
				case __MODE_PAINT_BUCKET: 
					addEventListener(TouchEvent.TOUCH, onTouchPaintBucket);
					break
				case __MODE_MAGNIFYING_GLASS: 
					addEventListener(TouchEvent.TOUCH, onTouchMagnifyingGlass);
					break;
				case __MODE_NONE: 
					//nothing necessary - just to remove all listeners is I reset
					break;
			}
		}
		
		/**
		 * Undo method
		 * @return	Boolean	[true/false] depends on it, if undo was available
		 */
		public function undo():Boolean {
			//ak je este moznost spravit undo
			if (__historyIndex > 0) {
				//znizime index a restornem bitmapu
				__historyIndex--;
				__bitmapData.copyPixels(__historyBitmaps[__historyIndex], new Rectangle(0, 0, __finalSize.x, __finalSize.y), new Point(0, 0));
				__fullImage.texture = Texture.fromBitmapData(__bitmapData);
				return true;
			}
			return false
		}
		
		/**
		 * Method to store "snaps" from current screen - to use as history
		 */
		private function historyAdd():void {
			//ak uz mam plne pole tak beriem prvy prvok a hodim ho na koniec - a tam ulozim bitmapu
			if (__historyIndex == __HISTORY_SIZE - 1) {
				__historyBitmaps.push(__historyBitmaps.shift());
			}
			__historyIndex = Math.min(__HISTORY_SIZE - 1, (__historyIndex + 1));
			__historyBitmaps[__historyIndex].copyPixels(__bitmapData, new Rectangle(0, 0, __finalSize.x, __finalSize.y), new Point(0, 0));
		}
		
		public function init(bBitmap:Bitmap, uWidth:uint, uHeight:uint):void {
			__inputBitmap = bBitmap;
			__image = Image.fromBitmap(__inputBitmap);
			__objectSize = new Point(uWidth, uHeight);
			__historyBitmaps = new Vector.<BitmapData>(10);
			//set mode
			setMode(__MODE_NONE);
			reset(true);
		}
		
		public function reset(bFirstTime:Boolean = false):void {
			var frame:Rectangle;
			var point:Point;
			var objectScale:Number = __objectSize.x / __objectSize.y;
			var imageScale:Number = __image.width / __image.height;
			var i:uint;
			if (objectScale > imageScale) {
				__finalScale = __objectSize.y / __image.height;
				point = new Point((__objectSize.x / __finalScale - __image.width) / 2, 0);
				frame = new Rectangle(0, 0, __objectSize.x / __finalScale, __image.height);
			} else {
				__finalScale = __objectSize.x / __image.width;
				point = new Point(0, (__objectSize.y / __finalScale - __image.height) / 2);
				frame = new Rectangle(0, 0, __image.width, __objectSize.y / __finalScale);
			}
			
			//history initialize
			__historyIndex = 0;
			//inicialize bitmap data
			__bitmapData = new BitmapData(frame.width, frame.height, false, 0xffffffff);
			__bitmapData.copyPixels(__inputBitmap.bitmapData, frame, point);
			if (bFirstTime) {
				__fullImage = new Image(Texture.fromBitmapData(__bitmapData));
				__fullImage.smoothing = TextureSmoothing.NONE;
				__finalSize = new Point(__fullImage.width, __fullImage.height);
				addChild(__fullImage);
				//history init if first time only
				var bitmapData:BitmapData;
				for (i = 0; i < __HISTORY_SIZE; i++) {
					bitmapData = new BitmapData(__finalSize.x, __finalSize.y, false, 0xffffffff);
					__historyBitmaps[i] = bitmapData;
				}
				
			} else {
				__fullImage.texture = Texture.fromBitmapData(__bitmapData);
			}
			//set first history snap as empty
			__historyBitmaps[0].copyPixels(__bitmapData, new Rectangle(0, 0, __finalSize.x, __finalSize.y), new Point(0, 0));
			//reset position
			this.x = 0;
			this.y = 0;
			this.pivotX = 0;
			this.pivotY = 0;
			this.scaleX = __finalScale;
			this.scaleY = __finalScale;
			__deltaPoint = new Point();
		}
		
		/************************  TOUCH HANDLERS *************************/
		private function onTouchMagnifyingGlass(event:TouchEvent):void {
			var touchesBegan:Vector.<Touch> = event.getTouches(this, TouchPhase.BEGAN);
			var touchesEnded:Vector.<Touch> = event.getTouches(this, TouchPhase.ENDED);
			var touchesMoved:Vector.<Touch> = event.getTouches(this, TouchPhase.MOVED);
			var touchesHover:Vector.<Touch> = event.getTouches(this, TouchPhase.HOVER);
			var touchesStationary:Vector.<Touch> = event.getTouches(this, TouchPhase.STATIONARY);
			Main.__tempOutput.htmlText = "BEGAN: " + touchesBegan.length + "\n";
			Main.__tempOutput.htmlText += "ENDED: " + touchesEnded.length + "\n";
			Main.__tempOutput.htmlText += "MOVED: " + touchesMoved.length + "\n";
			Main.__tempOutput.htmlText += "HOVER: " + touchesHover.length + "\n";
			Main.__tempOutput.htmlText += "STATIONARY: " + touchesStationary.length + "\n";
			//MOVED Touch
			if (touchesMoved.length == 1) {
				// one finger touching -> posun
				var delta:Point = touchesMoved[0].getMovement(parent);
				this.x += delta.x;
				this.y += delta.y;
				__deltaPoint = __deltaPoint.add(delta);
				Main.__tempOutput.htmlText += "touchesMoved 1: " + __deltaPoint + "\n";
			} else if (touchesMoved.length == 2) {
				// two fingers touching -> scale
				var touchA:Touch = touchesMoved[0];
				var touchB:Touch = touchesMoved[1];
				__deltaPoint = __deltaPoint.add(touchesMoved[1].getMovement(parent));
				Main.__tempOutput.htmlText += "touchesMoved 2: " + __deltaPoint + "\n";
				// update pivota na zaklade predchadzajuceho centra (THIS)
				var previousLocalA:Point = touchA.getPreviousLocation(this);
				var previousLocalB:Point = touchB.getPreviousLocation(this);
				this.pivotX = (previousLocalA.x + previousLocalB.x) * 0.5;
				this.pivotY = (previousLocalA.y + previousLocalB.y) * 0.5;
				
				// zmena lokacie zratana na zaklade noveho centra (PARENT)
				var currentPosA:Point = touchA.getLocation(parent);
				var previousPosA:Point = touchA.getPreviousLocation(parent);
				var currentPosB:Point = touchB.getLocation(parent);
				var previousPosB:Point = touchB.getPreviousLocation(parent);
				this.x = (currentPosA.x + currentPosB.x) * 0.5;
				this.y = (currentPosA.y + currentPosB.y) * 0.5;
				
				// zrataj scale
				var currentVector:Point = currentPosA.subtract(currentPosB);
				var previousVector:Point = previousPosA.subtract(previousPosB);
				var sizeDiff:Number = currentVector.length / previousVector.length;
				this.scaleX = Math.max(__finalScale, this.scaleX * sizeDiff);
				this.scaleY = Math.max(__finalScale, this.scaleY * sizeDiff);
			}
			//zistim ci nie som mimo hranic - ak hej tak "prilepim objekt ku krajom"
			var top:Number = (this.y - this.pivotY * this.scaleY);
			var left:Number = (this.x - this.pivotX * this.scaleX);
			if (top > 0) {
				this.y = __objectSize.y / 2;
				this.pivotY = this.y / this.scaleY;
			}
			if ((top + this.height) < __objectSize.y) {
				this.y = __objectSize.y / 2;
				this.pivotY = __finalSize.y - this.y / this.scaleY;
			}
			if (left > 0) {
				this.x = __objectSize.x / 2;
				this.pivotX = this.x / this.scaleX;
			}
			if ((left + this.width) < __objectSize.x) {
				this.x = __objectSize.x / 2;
				this.pivotX = __finalSize.x - this.x / this.scaleX;
			}
			
			if ((touchesEnded.length == 1) && (touchesEnded[0].tapCount == 2)) {
				//set default zoom
				this.x = 0;
				this.y = 0;
				this.pivotX = 0;
				this.pivotY = 0;
				this.scaleX = __finalScale;
				this.scaleY = __finalScale;
			}
		}
		
		private function onTouchPaintBucket(event:TouchEvent):void {
			var touchesBegan:Vector.<Touch> = event.getTouches(this, TouchPhase.BEGAN);
			var touchesEnded:Vector.<Touch> = event.getTouches(this, TouchPhase.ENDED);
			var touchesMoved:Vector.<Touch> = event.getTouches(this, TouchPhase.MOVED);
			var touchesHover:Vector.<Touch> = event.getTouches(this, TouchPhase.HOVER);
			var touchesStationary:Vector.<Touch> = event.getTouches(this, TouchPhase.STATIONARY);
			Main.__tempOutput.htmlText = "BEGAN: " + touchesBegan.length + "\n";
			Main.__tempOutput.htmlText += "ENDED: " + touchesEnded.length + "\n";
			Main.__tempOutput.htmlText += "MOVED: " + touchesMoved.length + "\n";
			Main.__tempOutput.htmlText += "HOVER: " + touchesHover.length + "\n";
			Main.__tempOutput.htmlText += "STATIONARY: " + touchesStationary.length + "\n";
			
			//MOVED Touch
			if (touchesMoved.length == 1) {
				// one finger touching -> posun
				var delta:Point = touchesMoved[0].getMovement(parent);
				/*
				   this.x += delta.x;
				   this.y += delta.y;
				 */
				__deltaPoint = __deltaPoint.add(delta);
				Main.__tempOutput.htmlText += "touchesMoved 1: " + __deltaPoint + "\n";
			} else if (touchesMoved.length == 2) {
				/*
				   // two fingers touching -> scale
				   var touchA:Touch = touchesMoved[0];
				   var touchB:Touch = touchesMoved[1];
				   __deltaPoint = __deltaPoint.add(touchesMoved[1].getMovement(parent));
				   Main.__tempOutput.htmlText += "touchesMoved 2: " + __deltaPoint + "\n";
				   // update pivota na zaklade predchadzajuceho centra (THIS)
				   var previousLocalA:Point = touchA.getPreviousLocation(this);
				   var previousLocalB:Point = touchB.getPreviousLocation(this);
				   this.pivotX = (previousLocalA.x + previousLocalB.x) * 0.5;
				   this.pivotY = (previousLocalA.y + previousLocalB.y) * 0.5;
				
				   // zmena lokacie zratana na zaklade noveho centra (PARENT)
				   var currentPosA:Point = touchA.getLocation(parent);
				   var previousPosA:Point = touchA.getPreviousLocation(parent);
				   var currentPosB:Point = touchB.getLocation(parent);
				   var previousPosB:Point = touchB.getPreviousLocation(parent);
				   this.x = (currentPosA.x + currentPosB.x) * 0.5;
				   this.y = (currentPosA.y + currentPosB.y) * 0.5;
				
				   // zrataj scale
				   var currentVector:Point = currentPosA.subtract(currentPosB);
				   var previousVector:Point = previousPosA.subtract(previousPosB);
				   var sizeDiff:Number = currentVector.length / previousVector.length;
				   this.scaleX = Math.max(__finalScale, this.scaleX * sizeDiff);
				   this.scaleY = Math.max(__finalScale, this.scaleY * sizeDiff);
				 */
			}
			
			//ENDED Touch
			if (touchesEnded.length > 0) {
				if (touchesEnded.length == 1) {
					if (__deltaPoint.length == 0) {
						//hodnota kam user klikol - koli kresleniu do bitmapy
						var click:Point = touchesEnded[0].getLocation(this);
						//kontrola ci som klikol na ciernu - v tom pripade nevyfarbujem
						if (__bitmapData.getPixel32(click.x, click.y) != 0xff000000) {
							__bitmapData.floodFill(click.x, click.y, Color.argb(1, 256 * Math.random(), 256 * Math.random(), 256 * Math.random()));
							__fullImage.texture = Texture.fromBitmapData(__bitmapData);
							historyAdd();
						}
					}
					if ((touchesStationary.length == 0) && (touchesMoved.length == 0)) {
						__deltaPoint.x = 0;
						__deltaPoint.y = 0;
					}
				}
			}
		}
		
		/* BACKUP
		   private function onTouch(event:TouchEvent):void {
		   var touchesBegan:Vector.<Touch> = event.getTouches(this, TouchPhase.BEGAN);
		   var touchesEnded:Vector.<Touch> = event.getTouches(this, TouchPhase.ENDED);
		   var touchesMoved:Vector.<Touch> = event.getTouches(this, TouchPhase.MOVED);
		   var touchesHover:Vector.<Touch> = event.getTouches(this, TouchPhase.HOVER);
		   var touchesStationary:Vector.<Touch> = event.getTouches(this, TouchPhase.STATIONARY);
		   Main.__tempOutput.htmlText = "BEGAN: " + touchesBegan.length + "\n";
		   Main.__tempOutput.htmlText += "ENDED: " + touchesEnded.length + "\n";
		   Main.__tempOutput.htmlText += "MOVED: " + touchesMoved.length + "\n";
		   Main.__tempOutput.htmlText += "HOVER: " + touchesHover.length + "\n";
		   Main.__tempOutput.htmlText += "STATIONARY: " + touchesStationary.length + "\n";
		   //MOVED Touch
		   if (touchesMoved.length == 1) {
		   // one finger touching -> posun
		   var delta:Point = touchesMoved[0].getMovement(parent);
		   this.x += delta.x;
		   this.y += delta.y;
		   __deltaPoint = __deltaPoint.add(delta);
		   Main.__tempOutput.htmlText += "touchesMoved 1: " + __deltaPoint + "\n";
		   } else if (touchesMoved.length == 2) {
		   // two fingers touching -> scale
		   var touchA:Touch = touchesMoved[0];
		   var touchB:Touch = touchesMoved[1];
		   __deltaPoint = __deltaPoint.add(touchesMoved[1].getMovement(parent));
		   Main.__tempOutput.htmlText += "touchesMoved 2: " + __deltaPoint + "\n";
		   // update pivota na zaklade predchadzajuceho centra (THIS)
		   var previousLocalA:Point = touchA.getPreviousLocation(this);
		   var previousLocalB:Point = touchB.getPreviousLocation(this);
		   this.pivotX = (previousLocalA.x + previousLocalB.x) * 0.5;
		   this.pivotY = (previousLocalA.y + previousLocalB.y) * 0.5;
		
		   // zmena lokacie zratana na zaklade noveho centra (PARENT)
		   var currentPosA:Point = touchA.getLocation(parent);
		   var previousPosA:Point = touchA.getPreviousLocation(parent);
		   var currentPosB:Point = touchB.getLocation(parent);
		   var previousPosB:Point = touchB.getPreviousLocation(parent);
		   this.x = (currentPosA.x + currentPosB.x) * 0.5;
		   this.y = (currentPosA.y + currentPosB.y) * 0.5;
		
		   // zrataj scale
		   var currentVector:Point = currentPosA.subtract(currentPosB);
		   var previousVector:Point = previousPosA.subtract(previousPosB);
		   var sizeDiff:Number = currentVector.length / previousVector.length;
		   this.scaleX = Math.max(__finalScale, this.scaleX * sizeDiff);
		   this.scaleY = Math.max(__finalScale, this.scaleY * sizeDiff);
		   }
		
		   //ENDED Touch
		   if (touchesEnded.length > 0) {
		   if (touchesEnded.length == 1) {
		   if (__deltaPoint.length == 0) {
		   //hodnota kam user klikol - koli kresleniu do bitmapy
		   var click:Point = touchesEnded[0].getLocation(this);
		   //kontrola ci som klikol na ciernu - v tom pripade nevyfarbujem
		   if (__bitmapData.getPixel32(click.x, click.y) != 0xff000000) {
		   __bitmapData.floodFill(click.x, click.y, Color.argb(1, 256 * Math.random(), 256 * Math.random(), 256 * Math.random()));
		   __fullImage.texture = Texture.fromBitmapData(__bitmapData);
		   historyAdd();
		   }
		   }
		   if ((touchesStationary.length == 0) && (touchesMoved.length == 0)) {
		   __deltaPoint.x = 0;
		   __deltaPoint.y = 0;
		   }
		   }
		
		   }
		   //zistim ci nie som mimo hranic - ak hej tak "prilepim objekt ku krajom"
		   var top:Number = (this.y - this.pivotY * this.scaleY);
		   var left:Number = (this.x - this.pivotX * this.scaleX);
		   if (top > 0) {
		   this.y = __objectSize.y / 2;
		   this.pivotY = this.y / this.scaleY;
		   }
		   if ((top + this.height) < __objectSize.y) {
		   this.y = __objectSize.y / 2;
		   this.pivotY = __finalSize.y - this.y / this.scaleY;
		   }
		   if (left > 0) {
		   this.x = __objectSize.x / 2;
		   this.pivotX = this.x / this.scaleX;
		   }
		   if ((left + this.width) < __objectSize.x) {
		   this.x = __objectSize.x / 2;
		   this.pivotX = __finalSize.x - this.x / this.scaleX;
		   }
		
		   if (touchEnded && touchEnded.tapCount == 2) {
		   //zoom?
		   //reset();
		   //parent.addChild(this);
		   // bring self to front
		   //}
		   }
		 */
		public override function dispose():void {
			super.dispose();
		}
	}

}