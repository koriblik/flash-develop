package ui.scenes.coloring.objects {
	import feathers.controls.Button;
	import feathers.controls.Header;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Slider;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.VerticalLayout;
	import starling.display.Sprite;
	import starling.events.Event;
	import ui.scenes.coloring.objects.subObjects.toolSelection;
	
	/**
	 * 2014-04-22
	 * @author Pavol Kusovsky
	 */
	public class toolBar extends Sprite {
		private var __paintingObject:freePaintingObject;
		//my components
		private var __toolSelection:toolSelection;
		//components
		private var __panel:ScrollContainer;
		private var __sliderMode:Slider;
		private var __sliderSize:Slider;
		private var __sliderAlpha:Slider;
		private var __colorButton:Button;
		
		public function toolBar(oObject:freePaintingObject) {
			super();
			__paintingObject = oObject;
			addEventListener(Event.ADDED_TO_STAGE, onAddedOnStage);
		}
		
		private function onAddedOnStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedOnStage);
			//my components
			__toolSelection = new toolSelection(config.__WORKING_WIDTH - 16, 64);
			__toolSelection.x = 8;
			__toolSelection.y = 2;
			addChild(__toolSelection);
		/*
		   //
		   __panel = new ScrollContainer();
		   __panel.width = config.__WORKING_WIDTH;
		   __panel.height = 128;
		   var layout:AnchorLayout = new AnchorLayout();
		   __panel.layout = layout;
		   addChild(__panel);
		   //Scaling
		   __sliderSize = new Slider();
		   __sliderSize.setSize(config.__WORKING_WIDTH - 16, 16);
		   __sliderSize.minimum = __paintingObject.__MIN_SCALE_VALUE;
		   __sliderSize.maximum = 1;
		   __sliderSize.step = .01;
		   __sliderSize.page = .1;
		   var layoutDataSize:AnchorLayoutData = new AnchorLayoutData();
		   layoutDataSize.top = 8;
		   layoutDataSize.left = 8;
		   __sliderSize.layoutData = layoutDataSize;
		   __panel.addChild(__sliderSize);
		   __sliderSize.addEventListener(Event.CHANGE, sliderSizeChangeHandler);
		   //alpha
		   __sliderAlpha = new Slider();
		   __sliderAlpha.setSize(config.__WORKING_WIDTH - 16, 16);
		   __sliderAlpha.minimum = 0;
		   __sliderAlpha.maximum = 1;
		   __sliderAlpha.step = .01;
		   __sliderAlpha.page = .1;
		   var layoutDataAlpha:AnchorLayoutData = new AnchorLayoutData();
		   layoutDataAlpha.top = 8;
		   layoutDataAlpha.left = 8;
		   layoutDataAlpha.topAnchorDisplayObject = __sliderSize;
		   __sliderAlpha.layoutData = layoutDataAlpha;
		   __panel.addChild(__sliderAlpha);
		   __sliderAlpha.addEventListener(Event.CHANGE, sliderAlphaChangeHandler);
		   //mode change
		   __sliderMode = new Slider();
		   __sliderMode.setSize(config.__WORKING_WIDTH - 16, 16);
		   __sliderMode.minimum = 0;
		   __sliderMode.maximum = 7;
		   __sliderMode.step = 1;
		   __sliderMode.page = 1;
		   var layoutDataMode:AnchorLayoutData = new AnchorLayoutData();
		   layoutDataMode.top = 8;
		   layoutDataMode.left = 8;
		   layoutDataMode.topAnchorDisplayObject = __sliderAlpha;
		   __sliderMode.layoutData = layoutDataMode;
		   __panel.addChild(__sliderMode);
		   __sliderMode.addEventListener(Event.CHANGE, sliderModeChangeHandler);
		   //color change
		   __colorButton = new Button();
		   __colorButton.setSize(32, 32);
		   var layoutDataColor:AnchorLayoutData = new AnchorLayoutData();
		   layoutDataColor.bottom = 8;
		   layoutDataColor.left = 8;
		   __colorButton.layoutData = layoutDataColor;
		   __panel.addChild(__colorButton);
		   __colorButton.addEventListener(Event.TRIGGERED, colorButtonTriggeredHandler);
		 */
		}
		
		/**
		 * Inicializuje hodnoty pre paintng objekt podla tychto co mam tu
		 */
		public function init(nScale:Number = 1, nAlpha:Number = 1, sMode:String = __paintingObject.__MODE_NONE, uR:uint = 255, uG:uint = 255, uB:uint = 255):void {
			var mode:String;
			switch (sMode) {
				case __paintingObject.__MODE_NONE: 
					break;
				case __paintingObject.__MODE_PAINT_BUCKET: 
					__toolSelection.init("brush/brush");
					break;
				case __paintingObject.__MODE_STAMP: 
					mode = __paintingObject.__MODE_STAMP;
					break;
				case __paintingObject.__MODE_PENCIL: 
					__toolSelection.init("pencil/pencil");
					break;
				case __paintingObject.__MODE_BRUSH: 
					break;
				case __paintingObject.__MODE_CHALK: 
					break;
				case __paintingObject.__MODE_SPRAY: 
					break;
				case __paintingObject.__MODE_PARTICLE: 
					break;
				case __paintingObject.__MODE_STICKER: 
					break;
				case __paintingObject.__MODE_ERASER: 
					break;
				case __paintingObject.__MODE_MAGNIFYING_GLASS: 
					break;
			}
			__paintingObject.setMode(sMode);
			__paintingObject.toolsScale = nScale;
			__paintingObject.toolsAlpha = nAlpha;
			__paintingObject.toolsColorR = uR;
			__paintingObject.toolsColorG = uG;
			__paintingObject.toolsColorB = uB;
		
		}
		
		private function colorButtonTriggeredHandler(e:Event):void {
			__paintingObject.toolsColorR = 255 * Math.random();
			__paintingObject.toolsColorG = 255 * Math.random();
			__paintingObject.toolsColorB = 255 * Math.random();
		
		}
		
		private function sliderSizeChangeHandler(event:Event):void {
			var slider:Slider = Slider(event.currentTarget);
			__paintingObject.toolsScale = slider.value;
		}
		
		private function sliderAlphaChangeHandler(event:Event):void {
			var slider:Slider = Slider(event.currentTarget);
			__paintingObject.toolsAlpha = slider.value;
		}
	
	}
}