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
		public const __MODE_PENCIL:String = "pencil";
		public const __MODE_BRUSH:String = "brush";
		public const __MODE_SPRAY:String = "spray";
		public const __MODE_STICKER:String = "sticker";
		public const __MODE_ERASER:String = "eraser";
		public const __MODE_MAGNIFYING_GLASS:String = "magnifying_glass";
		private var __currentMode:String = __MODE_NONE;
		//common
		private var __image:Image;
		private var __fullImage:Image;
		private var __objectSize:Point;
		private var __finalScale:Number;
		private var __finalSize:Point;
		private var __inputBitmap:Bitmap;
		private var __bitmapData:BitmapData;
		private var __bitmapDataBackup:BitmapData;
		//paint bucket
		private var __deltaPoint:Point;
		private var __deltaPreviousPoint:Point;
		//pencil
		private var __pencilImage:Image;
		//brush
		private var __brushImage:Image
		//eraser
		private var __eraserImage:Image;
		//sticker
		private var __sprayImage:Image;
		//sticker
		private var __stickerImage:Image;
		//comon
		private var __toolsScale:Number;
		public const __MIN_SCALE_VALUE:Number = 0.1;
		private var __toolsAlpha:Number;
		private var __toolsColorR:uint;
		private var __toolsColorG:uint;
		private var __toolsColorB:uint;
		private var __startPoint:Point;
		private var __distancePoint:Point; //koli brush - aby som rotation robil na zaklade nejakej distance nie kazdy frame (inak mi to toci kade tade)
		private const __ROTATION_DISTANCE:uint = 5;
		private var __line:Vector.<int>;
		//render texture for brush and pencil
		private var __renderTextureTool:RenderTexture;
		private var __canvas:Image;
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
						setMode(__MODE_PENCIL);
						break;
					case __MODE_PENCIL: 
						setMode(__MODE_BRUSH);
						break;
					case __MODE_BRUSH: 
						setMode(__MODE_STICKER);
						break;
					case __MODE_STICKER: 
						setMode(__MODE_SPRAY);
						break;
					case __MODE_SPRAY: 
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
				case __MODE_PENCIL: 
					removeEventListener(TouchEvent.TOUCH, onTouchPaint);
					break;
				case __MODE_BRUSH: 
					removeEventListener(TouchEvent.TOUCH, onTouchPaint);
					break;
				case __MODE_STICKER: 
					removeEventListener(TouchEvent.TOUCH, onTouchSticker);
					break;
				case __MODE_SPRAY: 
					removeEventListener(TouchEvent.TOUCH, onTouchPaint);
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
				case __MODE_PENCIL: 
					addEventListener(TouchEvent.TOUCH, onTouchPaint);
					break;
				case __MODE_BRUSH: 
					addEventListener(TouchEvent.TOUCH, onTouchPaint);
					break;
				case __MODE_STICKER: 
					addEventListener(TouchEvent.TOUCH, onTouchSticker);
					break;
				case __MODE_SPRAY: 
					addEventListener(TouchEvent.TOUCH, onTouchPaint);
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
				trace(__historyIndex + " = " + __historyLayer[__historyIndex]);
				if (__historyLayer[__historyIndex] == __HISTORY_LAYER_PAINTER_BUCKET) {
					__bitmapData.copyPixels(__historyBitmaps[__historyIndex], new Rectangle(0, 0, __finalSize.x, __finalSize.y), new Point(0, 0));
					__fullImage.texture = Texture.fromBitmapData(__bitmapData);
					return true;
				}
				if (__historyLayer[__historyIndex] == __HISTORY_LAYER_TOOLS) {
					__renderTextureTool.clear();
					__renderTextureTool.draw(new Image(Texture.fromBitmapData(__historyBitmaps[__historyIndex])));
					
					//TODO vyplnut renderTExtrue bitmapou
					//__bitmapData.copyPixels(__historyBitmaps[__historyIndex], new Rectangle(0, 0, __finalSize.x, __finalSize.y), new Point(0, 0));
					
					return true;
				}
			}
			return false
		}
		
		/**
		 * Method to store "snaps" from current screen - to use as history
		 * @param	bFromGPU	take snap from GPU?
		 */
		private function historyAdd(bFromGPU:Boolean = false):void {
			//ak uz mam plne pole tak beriem prvy prvok a hodim ho na koniec - a tam ulozim bitmapu
			if (__historyIndex == __HISTORY_SIZE - 1) {
				__historyBitmaps.push(__historyBitmaps.shift());
			}
			//ak este nemam inicializovanu historiu
			if (!__historyInitialized) {
				//ak to nie je z gpu tak uloz original obrazok
				if (!bFromGPU) {
					__historyLayer[__historyIndex] = __HISTORY_LAYER_PAINTER_BUCKET;
					__historyBitmaps[__historyIndex].copyPixels(__bitmapDataBackup, new Rectangle(0, 0, __finalSize.x, __finalSize.y), new Point(0, 0));
				} else {
					__historyLayer[__historyIndex] = __HISTORY_LAYER_TOOLS;
					__historyBitmaps[__historyIndex].fillRect(new Rectangle(0, 0, __finalSize.x, __finalSize.y), 0x00ffffff);
				}
				__historyInitialized = true;
			}
			__historyIndex = Math.min(__HISTORY_SIZE - 1, (__historyIndex + 1));
			if (bFromGPU) {
				//vypnem vsetko co netreba screenshotovat off a zoberiem screenshot z GPU
				__fullImage.visible = false;
				Starling.current.showStats = false;
				//zoberem screenshot
				var stage:Stage = Starling.current.stage;
				var rs:RenderSupport = new RenderSupport();
				rs.clear();
				rs.scaleMatrix(337/360, 1/1.125);
				rs.setOrthographicProjection(0, 0, __finalSize.x, __finalSize.y);
				__canvas.render(rs, 1.0);
				rs.finishQuadBatch();
				var outBmp:BitmapData = new BitmapData(__finalSize.x, __finalSize.y, true);
				Starling.context.drawToBitmapData(outBmp);
				//zapnem vsetko co nebolo treba screenshotovat spat
				__fullImage.visible = true;
				Starling.current.showStats = true;
				//zapis do history
				trace("stage: " + stage.stageWidth + " / " + stage.stageHeight);
				trace("__finalSize: " + __finalSize);
				trace("window_scale: "+Starling.current.contentScaleFactor);
				trace("store: " + __HISTORY_LAYER_TOOLS);
				__historyLayer[__historyIndex] = __HISTORY_LAYER_TOOLS;
				__historyBitmaps[__historyIndex].copyPixels(outBmp, new Rectangle(0, 0, __finalSize.x, __finalSize.y), new Point(0, 0));
			} else {
				trace("store: " + __HISTORY_LAYER_PAINTER_BUCKET);
				__historyLayer[__historyIndex] = __HISTORY_LAYER_PAINTER_BUCKET;
				__historyBitmaps[__historyIndex].copyPixels(__bitmapData, new Rectangle(0, 0, __finalSize.x, __finalSize.y), new Point(0, 0));
			}
			trace("----");
		}
		
		public function init(bBitmap:Bitmap, uWidth:uint, uHeight:uint):void {
			__inputBitmap = bBitmap;
			__image = Image.fromBitmap(__inputBitmap);
			__objectSize = new Point(uWidth, uHeight);
			__historyBitmaps = new Vector.<BitmapData>(10);
			__historyLayer = new Vector.<String>(10);
			//set mode
			setMode(__MODE_STICKER);
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
			__bitmapData = new BitmapData(frame.width, frame.height, false, 0xffffffff);
			__bitmapDataBackup = new BitmapData(frame.width, frame.height, false, 0xffffffff);
			__bitmapData.copyPixels(__inputBitmap.bitmapData, frame, point);
			__bitmapDataBackup.copyPixels(__inputBitmap.bitmapData, frame, point);
			if (bFirstTime) {
				__fullImage = new Image(Texture.fromBitmapData(__bitmapData));
				__fullImage.smoothing = TextureSmoothing.NONE;
				__finalSize = new Point(__fullImage.width, __fullImage.height);
				addChild(__fullImage);
				//history init if first time only
				var bitmapData:BitmapData;
				for (i = 0; i < __HISTORY_SIZE; i++) {
					bitmapData = new BitmapData(__finalSize.x, __finalSize.y, true, 0x00ffffff);
					__historyBitmaps[i] = bitmapData;
				}
				//brush and pencil and spray and eraser
				__pencilImage = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture("pencil"));
				__pencilImage.blendMode = BlendMode.NORMAL;
				__brushImage = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture("brush"));
				__brushImage.blendMode = BlendMode.NORMAL;
				__sprayImage = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture("spray"));
				__sprayImage.blendMode = BlendMode.NORMAL;
				__eraserImage = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture("eraser"));
				__eraserImage.blendMode = BlendMode.ERASE;
				//sticker
				__stickerImage = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture(assets.__coloringBooksStickers[0]));
				//canvas
				__renderTextureTool = new RenderTexture(__finalSize.x, __finalSize.y);
				__canvas = new Image(__renderTextureTool);
				__canvas.smoothing = TextureSmoothing.NONE;
				addChild(__canvas);
				// scale, alpha and color initialization is done by toolBar.as
				//deltas
				__startPoint = new Point();
				__deltaPoint = new Point();
				__deltaPreviousPoint = new Point();
				__distancePoint = new Point();
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
					//if (__deltaPoint.length == 0) {
					//hodnota kam user klikol - koli kresleniu do bitmapy
					var click:Point = touchesBegan[0].getLocation(this);
					//kontrola ci som klikol na ciernu - v tom pripade nevyfarbujem
					if (__bitmapData.getPixel32(click.x, click.y) != 0xff000000) {
						__bitmapData.floodFill(click.x, click.y, Color.argb(__toolsAlpha, __toolsColorR, __toolsColorG, __toolsColorB));
						__fullImage.texture = Texture.fromBitmapData(__bitmapData);
						historyAdd();
					}
					//}
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
			__stickerImage = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture(assets.__coloringBooksStickers[Math.floor(assets.__coloringBooksStickers.length * Math.random())]));
			__stickerImage.readjustSize();
			__stickerImage.scaleX = __toolsScale;
			__stickerImage.scaleY = __toolsScale;
			__stickerImage.alpha = __toolsAlpha;
			//BEGAN Touch
			if (touchesBegan.length > 0) {
				if (touchesBegan.length == 1) {
					//hodnota kam user klikol - koli kresleniu do bitmapy
					var click:Point = touchesBegan[0].getLocation(this);
					matrix.tx = click.x - __stickerImage.width / 2;
					matrix.ty = click.y - __stickerImage.height / 2;
					__renderTextureTool.draw(__stickerImage, matrix);
					historyAdd(true);
				}
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
			matrix.scale(__toolsScale, __toolsScale);
			switch (__currentMode) {
				case __MODE_PENCIL: 
					image = __pencilImage;
					break;
				case __MODE_BRUSH: 
					image = __brushImage;
					break;
				case __MODE_SPRAY: 
					image = __sprayImage;
					break;
				case __MODE_ERASER: 
					image = __eraserImage;
					break;
			}
			if (touchBegan) {
				__startPoint = touchBegan.getLocation(this);
				__distancePoint = __startPoint.clone();
				image.color = Color.rgb(__toolsColorR, __toolsColorG, __toolsColorB);
				image.scaleX = __toolsScale;
				image.scaleY = __toolsScale;
				//ak som pencil tak alpha musi ist brutal dole / 10
				if ((__currentMode == __MODE_PENCIL)) {
					image.alpha = __toolsAlpha / (10 * __toolsScale);
				} else {
					if (__currentMode == __MODE_BRUSH) {
						image.alpha = __toolsAlpha / (5 * __toolsScale);
					} else {
						image.alpha = __toolsAlpha;
					}
				}
				matrix.tx = __startPoint.x - image.width / 2;
				matrix.ty = __startPoint.y - image.height / 2;
				__renderTextureTool.draw(image, matrix);
			}
			if (touchMoved) {
				// one finger moving -> drawing
				__deltaPoint = touchMoved.getLocation(this);
				__deltaPreviousPoint = touchMoved.getPreviousLocation(this);
				__line = algorithms.bresenhamsLine(__deltaPreviousPoint, __deltaPoint);
				__renderTextureTool.drawBundled(function():void {
					//v pripade brushu robim aj rotaciu image koli lepsej vizualizacii
						if (__currentMode == __MODE_BRUSH) {
							//ak to robim hned (nie po minimalnej distance) tak sa mi to toci kade tade - kedze je maly rozdiel
							if (algorithms.distanceBetweenPoints(__distancePoint, __deltaPoint) != __ROTATION_DISTANCE) {
								image.rotation = Math.atan2((__deltaPoint.y - __distancePoint.y), (__deltaPoint.x - __distancePoint.x));
								__distancePoint = __deltaPoint.clone();
							}
						}
						var length:uint = __line.length / 2;
						for (var i:uint = 0; i < length; i++) {
							//v pripade spray robim aj nahodnu rotaciu image koli lepsej vizualizacii
							if (__currentMode == __MODE_SPRAY) {
								image.rotation = Math.PI * 2 * Math.random();
							}
							matrix.tx = __line[i * 2] - image.width / 2;
							matrix.ty = __line[i * 2 + 1] - image.height / 2;
							__renderTextureTool.draw(image, matrix);
						}
					});
			}
			if (touchEnded) {
				historyAdd(true);
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