package ui {
	import feathers.themes.MinimalMobileTheme;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import starling.display.Sprite;
	import starling.events.Event;
	import ui.scenes.baseScene;
	import ui.scenes.coloring.coloringScene;
	import ui.scenes.loader.loaderScene;
	import ui.scenes.mainMenu.mainMenuScene;
	
	/**
	 * 2014-04-14
	 * @author Pavol Kusovsky
	 */
	public class applicationClass extends Sprite {
		private var __currentScene:baseScene;
		private var __theme:MinimalMobileTheme;
		/**
		 * Constructor
		 */
		public function applicationClass() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener("SCENE_CLOSED", onSceneClosing);
		}
		
		private function onAddedToStage(e:Event):void {
			//remove initialization listener
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			//setup Scenes
			config.__SCENES["loaderScene"] = loaderScene;
			config.__SCENES["mainMenuScene"] = mainMenuScene;
			config.__SCENES["coloringScene"] = coloringScene;
			//... continue to add scenes here
			
			//init theme
			__theme = new MinimalMobileTheme(this.stage);

			//activate first scene
			config.__ACTIVE_SCENE = "coloringScene";
			showScene();
		}
		
		private function onSceneClosing(event:Event):void {
			//scene is removed a initialize new one
			if (__currentScene) {
				__currentScene = null;
			}
			showScene();
		}
		
		private function showScene():void {
			if (config.__ACTIVE_SCENE != "") {
				var sceneClass:Class = getDefinitionByName(getQualifiedClassName(config.__SCENES[config.__ACTIVE_SCENE])) as Class;
				__currentScene = new sceneClass() as baseScene;
				addChild(__currentScene);
			}
		}
	}
}