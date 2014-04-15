package ui.scenes.coloring.objects {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
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
	
	/**
	 * 2014-04-14
	 * @author pavol Kusovsky
	 */
	public class freePaintingObject extends Sprite {
		private var __image:Image;
		private var __fullImage:Image;
		private var __objectSize:Point;
		private var __finalScale:Number;
		private var __finalSize:Point;
		private var __inputBitmap:Bitmap;
		private var __bitmapData:BitmapData;
		private var __deltaPoint:Point;
		
		public function freePaintingObject(contents:DisplayObject = null) {
			super();
			addEventListener(TouchEvent.TOUCH, onTouch);
			useHandCursor = true;
			
			if (contents) {
				contents.x = int(contents.width / -2);
				contents.y = int(contents.height / -2);
				addChild(contents);
			}
		}
		
		public function init(bBitmap:Bitmap, uWidth:uint, uHeight:uint):void {
			__inputBitmap = bBitmap;
			__image = Image.fromBitmap(__inputBitmap);
			__objectSize = new Point(uWidth, uHeight);
			reset(true);
		}
		
		public function reset(bFirstTime:Boolean = false):void {
			var frame:Rectangle;
			var point:Point;
			var objectScale:Number = __objectSize.x / __objectSize.y;
			var imageScale:Number = __image.width / __image.height;
			if (objectScale > imageScale) {
				__finalScale = __objectSize.y / __image.height;
				point = new Point((__objectSize.x / __finalScale - __image.width) / 2, 0);
				frame = new Rectangle(0, 0, __objectSize.x / __finalScale, __image.height);
			} else {
				__finalScale = __objectSize.x / __image.width;
				point = new Point(0, (__objectSize.y / __finalScale - __image.height) / 2);
				frame = new Rectangle(0, 0, __image.width, __objectSize.y / __finalScale);
			}
			
			//inicialize bitmap data
			__bitmapData = new BitmapData(frame.width, frame.height, false, 0xffffffff);
			__bitmapData.copyPixels(__inputBitmap.bitmapData, frame, point);
			if (bFirstTime) {
				__fullImage = new Image(Texture.fromBitmapData(__bitmapData));
				__fullImage.smoothing = TextureSmoothing.NONE;
				__finalSize = new Point(__fullImage.width, __fullImage.height);
				addChild(__fullImage);
			} else {
				__fullImage.texture = Texture.fromBitmapData(__bitmapData);
				;
			}
			this.x = 0;
			this.y = 0;
			this.pivotX = 0;
			this.pivotY = 0;
			this.scaleX = __finalScale;
			this.scaleY = __finalScale;
			
			__deltaPoint = new Point();
		}
		
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
					trace(__deltaPoint.length);
					if (__deltaPoint.length == 0) {
						//hodnota kam user klikol - koli kresleniu do bitmapy
						var click:Point = touchesEnded[0].getLocation(this);
						//kontrola ci som klikol na ciernu - v tom pripade nevyfarbujem
						if (__bitmapData.getPixel32(click.x, click.y) != 0xff000000) {
							trace("getPixel32");
							__bitmapData.floodFill(click.x, click.y, Color.argb(1, 256 * Math.random(), 256 * Math.random(), 256 * Math.random()));
							__fullImage.texture = Texture.fromBitmapData(__bitmapData);
						}
					}
					if ((touchesStationary.length == 0) && (touchesMoved.length == 0)) {
						trace("reset");
						__deltaPoint.x = 0;
						__deltaPoint.y = 0;
					}
				}
				//ak sa skoncil zoom IN/OUT - tak zistim ci nie som mimo hranic - ak hej tak "prilepim objekt ku krajom"
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
			}
		
		/*
		   if (touchEnded && touchEnded.tapCount == 2) {
		   //zoom?
		   //reset();
		   //parent.addChild(this);
		   // bring self to front
		   }
		 */
		}
		
		public override function dispose():void {
			removeEventListener(TouchEvent.TOUCH, onTouch);
			super.dispose();
		}
	}

}