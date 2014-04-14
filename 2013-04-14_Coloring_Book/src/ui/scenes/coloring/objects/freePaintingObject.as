package ui.scenes.coloring.objects {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
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
		[Embed(source="../../../../../assets/coloring_book/pooh01.png")]
		public static const Pooh:Class;
		
		public function freePaintingObject(contents:DisplayObject = null) {
			super();
			addEventListener(TouchEvent.TOUCH, onTouch);
			useHandCursor = true;
			
			if (contents) {
				contents.x = int(contents.width / -2);
				contents.y = int(contents.height / -2);
				addChild(contents);
			}
			
			__image = Image.fromBitmap(new Pooh());
			__objectSize = new Point(config.__WINDOW_WIDTH, config.__WINDOW_HEIGHT);
			var frame:Rectangle;
			var objectScale:Number = __objectSize.x / __objectSize.y;
			var imageScale:Number = __image.width / __image.height;
			if (objectScale > imageScale) {
				__finalScale = __objectSize.y / __image.height;
				frame = new Rectangle(-(config.__WINDOW_WIDTH / __finalScale - __image.width) / 2, 0, config.__WINDOW_WIDTH / __finalScale, __image.height);
			} else {
				__finalScale = __objectSize.x / __image.width;
				frame = new Rectangle(0, -(config.__WINDOW_HEIGHT / __finalScale - __image.height) / 2, __image.width, config.__WINDOW_HEIGHT / __finalScale);
			}
			
			__fullImage = new Image(Texture.fromTexture(__image.texture, null, frame));
			__fullImage.alignPivot("left", "top");
			__finalSize = new Point(__fullImage.width, __fullImage.height);
			addChild(__fullImage);
			
			this.scaleX = __finalScale;
			this.scaleY = __finalScale;
		}
		
		private function onTouch(event:TouchEvent):void {
			var touchesMoved:Vector.<Touch> = event.getTouches(this, TouchPhase.MOVED);
			var touches:Vector.<Touch> = event.getTouches(this, TouchPhase.BEGAN);
			if (touches.length == 1) {
				trace(touches[0].getLocation(this));
			}
			if (touchesMoved.length == 1) {
				//NO MOVE
				// one finger touching -> move
				/*
				   var delta:Point = touchesMoved[0].getMovement(parent);
				   x += delta.x;
				   y += delta.y;
				 */
			} else if (touchesMoved.length == 2) {
				// two fingers touching -> rotate and scale
				var touchA:Touch = touchesMoved[0];
				var touchB:Touch = touchesMoved[1];
				
				var currentPosA:Point = touchA.getLocation(parent);
				var previousPosA:Point = touchA.getPreviousLocation(parent);
				var currentPosB:Point = touchB.getLocation(parent);
				var previousPosB:Point = touchB.getPreviousLocation(parent);
				
				var currentVector:Point = currentPosA.subtract(currentPosB);
				var previousVector:Point = previousPosA.subtract(previousPosB);
				
				//NO ROTATION
				/*
				var currentAngle:Number = Math.atan2(currentVector.y, currentVector.x);
				var previousAngle:Number = Math.atan2(previousVector.y, previousVector.x);
				var deltaAngle:Number = currentAngle - previousAngle;
				*/
				// update pivot point based on previous center
				var previousLocalA:Point = touchA.getPreviousLocation(this);
				var previousLocalB:Point = touchB.getPreviousLocation(this);
				pivotX = (previousLocalA.x + previousLocalB.x) * 0.5;
				pivotY = (previousLocalA.y + previousLocalB.y) * 0.5;
				
				// update location based on the current center
				this.x = (currentPosA.x + currentPosB.x) * 0.5;
				this.y = (currentPosA.y + currentPosB.y) * 0.5;
				
				//NO ROTATION
				// rotate
				/*
				   rotation += deltaAngle;
				 */
				
				// scale
				var sizeDiff:Number = currentVector.length / previousVector.length;
				this.scaleX = Math.max(__finalScale, this.scaleX * sizeDiff);
				this.scaleY = Math.max(__finalScale, this.scaleY * sizeDiff);
				
			} else {
				trace(__fullImage.x)
			}
			
			var touch:Touch = event.getTouch(this, TouchPhase.ENDED);
			
			if (touch && touch.tapCount == 2)
				parent.addChild(this); // bring self to front
		}
		
		public override function dispose():void {
			removeEventListener(TouchEvent.TOUCH, onTouch);
			super.dispose();
		}
	}

}