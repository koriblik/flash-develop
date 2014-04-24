package ui.scenes.coloring.objects {
	import adobe.utils.CustomActions;
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.RenderTexture;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	import starling.utils.Color;
	import utils.algorithms;
	
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
		public const __MODE_STAMP:String = "stamp";
		public const __MODE_PENCIL:String = "pencil";
		public const __MODE_BRUSH:String = "brush";
		public const __MODE_CHALK:String = "chalk";
		public const __MODE_SPRAY:String = "spray";
		public const __MODE_PARTICLE:String = "particle";
		public const __MODE_STICKER:String = "sticker";
		public const __MODE_ERASER:String = "eraser";
		public const __MODE_MAGNIFYING_GLASS:String = "magnifying_glass";
		private var __currentMode:String = __MODE_NONE;
		//common
		private var __contourImage:Image;
		private var __image:Image;
		private var __fullImage:Image;
		private var __objectSize:Point;
		private var __finalScale:Number;
		private var __finalSize:Point;
		private var __inputBitmap:Bitmap;
		private var __canvasColor:uint;
		private var __bitmapData:BitmapData;
		private var __bitmapDataBackup:BitmapData;
		//paint bucket
		private var __deltaPoint:Point;
		private var __deltaPreviousPoint:Point;
		//pencil
		private var __pencilImage:Image;
		//brush
		private var __brushImage:Image
		private var __brushPreviousDistance:Number;
		private var __brushDistance:Number;
		private var __BRUSH_MAX_DISTANCE:Number = 10000;
		//spray
		private var __chalkImage:Image;
		//spray
		private var __sprayImage:Image;
		//particle
		private var __particleImage:Image;
		//sticker
		private var __stickerImage:Image;
		//eraser
		private var __eraserImage:Image;
		//comon
		private var __movedInPaint:Boolean;
		private var __toolsScale:Number;
		public const __MIN_SCALE_VALUE:Number = 0.1;
		private var __toolsAlpha:Number;
		private var __toolsColorR:uint;
		private var __toolsColorG:uint;
		private var __toolsColorB:uint;
		private var __startPoint:Point;
		private const __ROTATION_DISTANCE:uint = 5;
		private var __line:Vector.<int>;
		//render texture for brush and pencil
		private var __renderTextureTool:RenderTexture;
		private var __canvasTool:Image;
		private var __renderTextureSticker:RenderTexture;
		private var __canvasSticker:Image;
		//history
		private const __HISTORY_SIZE:uint = 10;
		private var __historyBitmaps:Vector.<BitmapData>;
		private var __historyLayer:Vector.<String>;
		private const __HISTORY_LAYER_PAINTER_BUCKET:String = "history_layer_painter_bucket";
		private const __HISTORY_LAYER_TOOLS:String = "history_layer_tools";
		private const __HISTORY_LAYER_STICKER:String = "history_layer_sticker";
		private var __historyIndex:uint;
		private var __historyInitialized:Boolean;
		
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
						setMode(__MODE_STAMP);
						break;
					case __MODE_STAMP: 
						setMode(__MODE_PENCIL);
						break;
					case __MODE_PENCIL: 
						setMode(__MODE_BRUSH);
						break;
					case __MODE_BRUSH: 
						setMode((__MODE_CHALK));
						break;
					case __MODE_CHALK: 
						setMode(__MODE_SPRAY);
						break;
					case __MODE_SPRAY: 
						setMode(__MODE_PARTICLE);
						break;
					case __MODE_PARTICLE: 
						setMode(__MODE_STICKER);
						break;
					case __MODE_STICKER: 
						setMode(__MODE_ERASER);
						break;
					case __MODE_ERASER: 
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
				case __MODE_STAMP: 
					break;
				case __MODE_PENCIL: 
					removeEventListener(TouchEvent.TOUCH, onTouchPaint);
					break;
				case __MODE_BRUSH: 
					removeEventListener(TouchEvent.TOUCH, onTouchPaint);
					break;
				case __MODE_CHALK: 
					removeEventListener(TouchEvent.TOUCH, onTouchPaint);
					break;
				case __MODE_SPRAY: 
					removeEventListener(TouchEvent.TOUCH, onTouchPaint);
					break;
				case __MODE_PARTICLE: 
					removeEventListener(TouchEvent.TOUCH, onTouchParticle);
					break;
				case __MODE_STICKER: 
					removeEventListener(TouchEvent.TOUCH, onTouchSticker);
					break;
				case __MODE_ERASER: 
					removeEventListener(TouchEvent.TOUCH, onTouchPaint);
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
					break;
				case __MODE_STAMP: 
					break;
				case __MODE_PENCIL: 
					addEventListener(TouchEvent.TOUCH, onTouchPaint);
					break;
				case __MODE_BRUSH: 
					addEventListener(TouchEvent.TOUCH, onTouchPaint);
					break;
				case __MODE_CHALK: 
					addEventListener(TouchEvent.TOUCH, onTouchPaint);
					break;
				case __MODE_SPRAY: 
					addEventListener(TouchEvent.TOUCH, onTouchPaint);
					break;
				case __MODE_PARTICLE: 
					addEventListener(TouchEvent.TOUCH, onTouchParticle);
					break;
				case __MODE_STICKER: 
					addEventListener(TouchEvent.TOUCH, onTouchSticker);
					break;
				case __MODE_ERASER: 
					addEventListener(TouchEvent.TOUCH, onTouchPaint);
					break;
				case __MODE_MAGNIFYING_GLASS: 
					addEventListener(TouchEvent.TOUCH, onTouchMagnifyingGlass);
					break;
				case __MODE_NONE: 
					//nothing necessary - just to remove all listeners is I reset
					break;
			}
			Main.__tempOutput.htmlText = "MODE: " + __currentMode + "\n";
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
				trace("restore: (" + __historyIndex + ") " + __historyLayer[__historyIndex]);
				switch (__historyLayer[__historyIndex]) {
					case __HISTORY_LAYER_PAINTER_BUCKET: 
						__bitmapData.copyPixels(__historyBitmaps[__historyIndex], new Rectangle(0, 0, __finalSize.x, __finalSize.y), new Point(0, 0));
						__fullImage.texture = Texture.fromBitmapData(__bitmapData);
						break;
					case __HISTORY_LAYER_TOOLS: 
						__renderTextureTool.clear();
						__renderTextureTool.draw(new Image(Texture.fromBitmapData(__historyBitmaps[__historyIndex])));
						break;
					case __HISTORY_LAYER_STICKER: 
						__renderTextureSticker.clear();
						__renderTextureSticker.draw(new Image(Texture.fromBitmapData(__historyBitmaps[__historyIndex])));
						break;
				}
				return true;
			}
			return false
		}
		
		/**
		 * Method to store "snaps" from current screen - to use as history
		 * @param	bFromGPU	take snap from GPU?
		 */
		private function historyAdd(sTarget:String):void {
			//ak uz mam plne pole tak beriem prvy prvok a hodim ho na koniec - a tam ulozim bitmapu
			if (__historyIndex == __HISTORY_SIZE) {
				__historyBitmaps.push(__historyBitmaps.shift());
				__historyLayer.push(__historyLayer.shift());
				__historyIndex--;
			}
			//uloz target pre identifikaciu pri vybere z history
			__historyLayer[__historyIndex] = sTarget;
			var target:Image;
			trace("store: (" + __historyIndex + ") " + sTarget);
			//vyber target
			switch (sTarget) {
				case __HISTORY_LAYER_PAINTER_BUCKET: 
					__historyBitmaps[__historyIndex].copyPixels(__bitmapData, new Rectangle(0, 0, __finalSize.x, __finalSize.y), new Point(0, 0));
					break;
				case __HISTORY_LAYER_TOOLS: 
					target = __canvasTool;
					break
				case __HISTORY_LAYER_STICKER: 
					target = __canvasSticker;
					break;
			}
			if (target != null) {
				//zoberem screenshot ak to nebol paintbucket
				var stage:Stage = Starling.current.stage;
				var rs:RenderSupport = new RenderSupport();
				rs.clear();
				rs.scaleMatrix(__finalSize.x / config.__WINDOW_WIDTH, __finalSize.y / config.__WINDOW_HEIGHT);
				rs.setOrthographicProjection(0, 0, __finalSize.x, __finalSize.y);
				target.render(rs, 1.0);
				rs.finishQuadBatch();
				var outBmp:BitmapData = new BitmapData(__finalSize.x, __finalSize.y, true);
				Starling.context.drawToBitmapData(outBmp);
				//algorithms.savePNGToPath("output.png", outBmp);
				//zapis do history
				__historyBitmaps[__historyIndex].copyPixels(outBmp, new Rectangle(0, 0, __finalSize.x, __finalSize.y), new Point(0, 0));
			}
			//posun index
			__historyIndex += 1;
			trace(__historyLayer);
			trace("----");
		}
		
		public function init(bBitmap:Bitmap, uWidth:uint, uHeight:uint, uCanvasColor:uint = 0xffffffff):void {
			//ak nezadam null to znamena ze mam kde vyfarbovat - ak null tak layer bude prazdny
			if (bBitmap != null) {
				__inputBitmap = bBitmap;
			} else {
				__inputBitmap = new Bitmap(new BitmapData(config.__DEFAULT_WIDTH, config.__DEFAULT_HEIGHT, true, 0x00000000));
			}
			__canvasColor = uCanvasColor;
			__image = Image.fromBitmap(__inputBitmap);
			__objectSize = new Point(uWidth, uHeight);
			__historyBitmaps = new Vector.<BitmapData>(10);
			__historyLayer = new Vector.<String>(10);
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
			__historyInitialized = false;
			//inicialize bitmap data
			__bitmapData = new BitmapData(frame.width, frame.height, false, __canvasColor);
			__bitmapDataBackup = new BitmapData(frame.width, frame.height, false, __canvasColor);
			__bitmapData.copyPixels(__inputBitmap.bitmapData, frame, point);
			__bitmapDataBackup.copyPixels(__inputBitmap.bitmapData, frame, point);
			if (bFirstTime) {
				//
				__fullImage = new Image(Texture.fromBitmapData(__bitmapData));
				__finalSize = new Point(__fullImage.width, __fullImage.height);
				__fullImage.smoothing = TextureSmoothing.NONE;
				addChild(__fullImage);
				//canvasTool
				__renderTextureTool = new RenderTexture(__finalSize.x, __finalSize.y);
				__canvasTool = new Image(__renderTextureTool);
				__canvasTool.smoothing = TextureSmoothing.NONE;
				addChild(__canvasTool);
				//contour
				var tempBitmapData:BitmapData = new BitmapData(frame.width, frame.height, true, 0x00000000);
				tempBitmapData.copyPixels(__inputBitmap.bitmapData, frame, point, null, null, true);
				__contourImage = new Image(Texture.fromBitmapData(tempBitmapData));
				addChild(__contourImage);
				//canvasSticker
				__renderTextureSticker = new RenderTexture(__finalSize.x, __finalSize.y);
				__canvasSticker = new Image(__renderTextureSticker);
				__canvasSticker.smoothing = TextureSmoothing.NONE;
				addChild(__canvasSticker);
				//history init if first time only
				var bitmapData:BitmapData;
				for (i = 0; i < __HISTORY_SIZE; i++) {
					bitmapData = new BitmapData(__finalSize.x, __finalSize.y, true, 0x00ffffff);
					__historyBitmaps[i] = bitmapData;
				}
				//brush and pencil and spray and eraser
				__pencilImage = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture("pencil"));
				//__pencilImage.smoothing = TextureSmoothing.NONE;
				__pencilImage.blendMode = BlendMode.NORMAL;
				__brushImage = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture("brush"));
				//__brushImage.smoothing = TextureSmoothing.NONE;
				__brushImage.blendMode = BlendMode.NORMAL;
				__chalkImage = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture("chalk"));
				//__brushImage.smoothing = TextureSmoothing.NONE;
				__chalkImage.blendMode = BlendMode.NORMAL;
				__sprayImage = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture("spray"));
				//__sprayImage.smoothing = TextureSmoothing.NONE;
				__sprayImage.blendMode = BlendMode.NORMAL;
				__eraserImage = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture("eraser"));
				//__eraserImage.smoothing = TextureSmoothing.NONE;
				__eraserImage.blendMode = BlendMode.ERASE;
				//
				__particleImage = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture(assets.__coloringBookParticles[0]));
				__particleImage.smoothing = TextureSmoothing.NONE;
				//sticker
				__stickerImage = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture(assets.__coloringBookStickers[0]));
				__stickerImage.smoothing = TextureSmoothing.NONE;
				// scale, alpha and color initialization is done by toolBar.as
				//deltas
				__startPoint = new Point();
				__deltaPoint = new Point();
				__deltaPreviousPoint = new Point();
			} else {
				__fullImage.texture = Texture.fromBitmapData(__bitmapData);
			}
			//reset position
			this.x = 0;
			this.y = 0;
			this.pivotX = 0;
			this.pivotY = 0;
			this.scaleX = __finalScale;
			this.scaleY = __finalScale;
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
			Main.__tempOutput.htmlText += "MODE: " + __currentMode + "\n";
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
			//set default zoom
			if ((touchesEnded.length == 1) && (touchesEnded[0].tapCount == 2)) {
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
			Main.__tempOutput.htmlText += "MODE: " + __currentMode + "\n";
			
			//BEGAN Touch
			if (touchesBegan.length > 0) {
				if (touchesBegan.length == 1) {
					//hodnota kam user klikol - koli kresleniu do bitmapy
					var click:Point = touchesBegan[0].getLocation(this);
					//kontrola ci som klikol na ciernu - v tom pripade nevyfarbujem
					if (__bitmapData.getPixel32(click.x, click.y) != 0xff000000) {
						//ulozim co bolo pred vyplnou do historie
						historyAdd(__HISTORY_LAYER_PAINTER_BUCKET);
						//spravim vypln
						__bitmapData.floodFill(click.x, click.y, Color.argb(__toolsAlpha, __toolsColorR, __toolsColorG, __toolsColorB));
						__fullImage.texture = Texture.fromBitmapData(__bitmapData);
					}
					if ((touchesStationary.length == 0) && (touchesMoved.length == 0)) {
						__deltaPoint.x = 0;
						__deltaPoint.y = 0;
					}
				}
			}
		}
		
		private function onTouchSticker(event:TouchEvent):void {
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
			Main.__tempOutput.htmlText += "MODE: " + __currentMode + "\n";
			var matrix:Matrix = new Matrix();
			matrix.scale(__toolsScale, __toolsScale);
			__stickerImage = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture(assets.__coloringBookStickers[Math.floor(assets.__coloringBookStickers.length * Math.random())]));
			__stickerImage.smoothing = TextureSmoothing.NONE;
			__stickerImage.readjustSize();
			__stickerImage.alpha = __toolsAlpha;
			//BEGAN Touch
			if (touchesBegan.length > 0) {
				if (touchesBegan.length == 1) {
					//ulozim pred stlacemin stickera
					historyAdd(__HISTORY_LAYER_STICKER);
					//hodnota kam user klikol - koli kresleniu do bitmapy
					var click:Point = touchesBegan[0].getLocation(this);
					matrix.tx = click.x - __toolsScale * (__stickerImage.width / 2);
					matrix.ty = click.y - __toolsScale * (__stickerImage.height / 2);
					__renderTextureSticker.draw(__stickerImage, matrix);
				}
			}
		}
		
		private function onTouchParticle(event:TouchEvent):void {
			var touchBegan:Touch = event.getTouch(this, TouchPhase.BEGAN);
			var touchEnded:Touch = event.getTouch(this, TouchPhase.ENDED);
			var touchMoved:Touch = event.getTouch(this, TouchPhase.MOVED);
			var touchesHover:Vector.<Touch> = event.getTouches(this, TouchPhase.HOVER);
			var touchesStationary:Vector.<Touch> = event.getTouches(this, TouchPhase.STATIONARY);
			Main.__tempOutput.htmlText = "BEGAN: " + (touchBegan != null) + "\n";
			Main.__tempOutput.htmlText += "ENDED: " + (touchEnded != null) + "\n";
			Main.__tempOutput.htmlText += "MOVED: " + (touchMoved != null) + "\n";
			Main.__tempOutput.htmlText += "HOVER: " + touchesHover.length + "\n";
			Main.__tempOutput.htmlText += "STATIONARY: " + touchesStationary.length + "\n";
			Main.__tempOutput.htmlText += "MODE: " + __currentMode + "\n";
			var matrix:Matrix = new Matrix();
			var image:Image;
			matrix.scale(__toolsScale, __toolsScale);
			__particleImage.texture = assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture(assets.__coloringBookParticles[Math.floor(assets.__coloringBookParticles.length * Math.random())]);
			__particleImage.smoothing = TextureSmoothing.NONE;
			__particleImage.readjustSize();
			image = __particleImage;
			if (touchBegan) {
				__movedInPaint = false;
			}
			if (touchMoved) {
				// one finger moving -> drawing
				//ak som sa pohol po prvy krat tak ulozim to co bolo do history
				if (!__movedInPaint) {
					historyAdd(__HISTORY_LAYER_STICKER);
				}
				__movedInPaint = true;
				__deltaPoint = touchMoved.getLocation(this);
				__deltaPreviousPoint = touchMoved.getPreviousLocation(this);
				//v pripade spray robim aj nahodnu rotaciu image koli lepsej vizualizacii
				__line = algorithms.bresenhamsLine(__deltaPreviousPoint, __deltaPoint);
				__renderTextureSticker.drawBundled(function():void {
					//v pripade brushu robim aj rotaciu image koli lepsej vizualizacii
						var length:uint = __line.length / 2;
						for (var i:uint = 0; i < length; i++) {
							//10%sanca ze hodim particle
							if (Math.random() > 0.9) {
								image.scaleX = __toolsScale * Math.random();
								image.scaleY = image.scaleX;
								matrix.scale(image.scaleX, image.scaleX);
								image.rotation = Math.PI * 2 * Math.random();
								matrix.tx = __line[i * 2] - __toolsScale * (image.width / 2) - image.width / 2 + image.width * Math.random();
								matrix.ty = __line[i * 2 + 1] - __toolsScale * (image.height / 2) - image.height / 2 + image.height * Math.random();
								__renderTextureSticker.draw(image, matrix);
							}
						}
					});
			}
		}
		
		private function onTouchPaint(event:TouchEvent):void {
			var touchBegan:Touch = event.getTouch(this, TouchPhase.BEGAN);
			var touchEnded:Touch = event.getTouch(this, TouchPhase.ENDED);
			var touchMoved:Touch = event.getTouch(this, TouchPhase.MOVED);
			var touchesHover:Vector.<Touch> = event.getTouches(this, TouchPhase.HOVER);
			var touchesStationary:Vector.<Touch> = event.getTouches(this, TouchPhase.STATIONARY);
			Main.__tempOutput.htmlText = "BEGAN: " + (touchBegan != null) + "\n";
			Main.__tempOutput.htmlText += "ENDED: " + (touchEnded != null) + "\n";
			Main.__tempOutput.htmlText += "MOVED: " + (touchMoved != null) + "\n";
			Main.__tempOutput.htmlText += "HOVER: " + touchesHover.length + "\n";
			Main.__tempOutput.htmlText += "STATIONARY: " + touchesStationary.length + "\n";
			Main.__tempOutput.htmlText += "MODE: " + __currentMode + "\n";
			//
			var matrix:Matrix = new Matrix();
			var image:Image;
			var scale:Number = __toolsScale;
			matrix.scale(scale, scale);
			switch (__currentMode) {
				case __MODE_PENCIL: 
					image = __pencilImage;
					break;
				case __MODE_BRUSH: 
					image = __brushImage;
					break;
				case __MODE_CHALK: 
					image = __chalkImage;
					break;
				case __MODE_SPRAY: 
					image = __sprayImage;
					break;
				case __MODE_ERASER: 
					image = __eraserImage;
					break;
			}
			if (touchBegan) {
				__movedInPaint = false;
				image.color = Color.rgb(__toolsColorR, __toolsColorG, __toolsColorB);
				//ak som pencil tak alpha musi ist brutal dole / 10
				image.alpha = __toolsAlpha;
				if ((__currentMode == __MODE_PENCIL)) {
					//image.alpha = __toolsAlpha / (10 * __toolsScale);
				}
				if (__currentMode == __MODE_BRUSH) {
					__brushDistance = 0;
					image.alpha = __toolsAlpha / (5 * __toolsScale);
				}
				if (__currentMode == __MODE_CHALK) {
					image.alpha = __toolsAlpha / (8 * __toolsScale);
				}
			}
			if (touchMoved) {
				// one finger moving -> drawing
				//ak som sa pohol po prvy krat tak ulozim to co bolo do history
				if (!__movedInPaint) {
					historyAdd(__HISTORY_LAYER_TOOLS);
				}
				__movedInPaint = true;
				__deltaPoint = touchMoved.getLocation(this);
				__deltaPreviousPoint = touchMoved.getPreviousLocation(this);
				//v pripade spray robim aj nahodnu rotaciu image koli lepsej vizualizacii
				if (__currentMode == __MODE_BRUSH) {
					__brushDistance = Math.min(__brushDistance + touchMoved.getMovement(this).length, __BRUSH_MAX_DISTANCE);
					scale = __toolsScale * (1 - (__brushDistance / __BRUSH_MAX_DISTANCE));
					matrix.scale(scale, scale);
				}
				__line = algorithms.bresenhamsLine(__deltaPreviousPoint, __deltaPoint);
				__renderTextureTool.drawBundled(function():void {
					//v pripade brushu robim aj rotaciu image koli lepsej vizualizacii
						var length:uint = __line.length / 2;
						for (var i:uint = 0; i < length; i++) {
							if ((__currentMode == __MODE_SPRAY) || (__currentMode == __MODE_CHALK)) {
								image.rotation = Math.PI * 2 * Math.random();
							}
							matrix.tx = __line[i * 2] - scale * (image.width / 2);
							matrix.ty = __line[i * 2 + 1] - scale * (image.height / 2);
							__renderTextureTool.draw(image, matrix);
						}
					});
			}
		}
		
		public override function dispose():void {
			super.dispose();
		}
		
		/****************************GETTERs & SETTERs***************************/
		public function get toolsScale():Number {
			return __toolsScale;
		}
		
		public function set toolsScale(value:Number):void {
			//interval <__MIN_SCALE_VALUE,1>
			__toolsScale = Math.min(1, Math.max(__MIN_SCALE_VALUE, value));
		}
		
		public function set toolsAlpha(value:Number):void {
			//interval <0,1>
			__toolsAlpha = Math.min(1, Math.max(0, value));
		}
		
		public function set toolsColorR(value:uint):void {
			//interval <0..255>
			__toolsColorR = Math.min(255, Math.max(0, value));
		}
		
		public function set toolsColorG(value:uint):void {
			//interval <0..255>
			__toolsColorG = Math.min(255, Math.max(0, value));
		}
		
		public function set toolsColorB(value:uint):void {
			//interval <0..255>
			__toolsColorB = Math.min(255, Math.max(0, value));
		}
	}
}