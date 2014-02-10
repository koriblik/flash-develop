package ui.scenes.game {
	import config;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;
	import ui.scenes.baseScene;
	
	/**
	 * 2014-01-15
	 * @author Pavol Kusovsky
	 */
	public class gameScene extends baseScene {
		//!test
		[Embed(source="../../../../assets/img1.png")]
		public static const img1:Class;
		[Embed(source="../../../../assets/img2.png")]
		public static const img2:Class;
		
		//!end test
		
		public function gameScene() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			//remove listener
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			//fade in can be called only after scene is ready on stage
			//this should be last thing to be displayed
			fadeIn({duration: config.__FADE_SCENE_DELAY, color: 0xff000000, width: config.__WINDOW_WIDTH, height: config.__WINDOW_HEIGHT});
			addEventListener("SCENE_INITIALIZED", onSceneInitialized);
			trace("[gameScene] addedToStage");
		}
		
		private function onSceneInitialized(e:Event):void {
			removeEventListener("SCENE_INITIALIZED", onSceneInitialized);
			//in this point scene is fully visible
			//...
			//!test
			var texture1:Texture = Texture.fromBitmap(new img1());
			var texture2:Texture = Texture.fromBitmap(new img2());
			var image:Image = new Image(texture1);
			addChild(image);
			image.texture = texture2;
			image.width = texture2.width;
			image.height = texture2.height;
			trace(texture1.width);
			trace(texture2.width);
			//!end test
		}
	}
}
