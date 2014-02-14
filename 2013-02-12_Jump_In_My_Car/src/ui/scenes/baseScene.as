package ui.scenes {
	import extensions.starling.fadeObject;
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * 2014-01-14
	 * @author Pavol Kusovsky
	 */
	public class baseScene extends Sprite {
		private var __fadeObject:fadeObject;
		
		public function baseScene() {
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}

		protected function fadeIn(varParametres:Object):void {
			//add child fadeObject and set listener to completition
			//fadeIn will leave scene here
			if (varParametres) {
				__fadeObject = new fadeObject(varParametres, "IN");
				addChild(__fadeObject);
				__fadeObject.addEventListener("FADE_COMPLETED", onFadeInCompleted);
			} else {
				dispatchEvent(new Event("SCENE_INITIALIZED"));
			}
		}
		
		protected function onFadeInCompleted(e:Event):void {
			//remove listener
			__fadeObject.removeEventListener("FADE_COMPLETED", onFadeInCompleted);
			dispatchEvent(new Event("SCENE_INITIALIZED"));
		}
		
		protected function fadeOutAndClose(varParametres:Object):void {
			//add child fadeObject and set listener to completition
			//fadeOut will always remove scene and initialize
			if (varParametres) {
				__fadeObject = new fadeObject(varParametres, "OUT");
				addChild(__fadeObject);
				__fadeObject.addEventListener("FADE_COMPLETED", onFadeOutCompleted);
			} else {
				removeFromParent(true);
			}
		}
		
		protected function onFadeOutCompleted(e:Event):void {
			//remove this object and listener
			__fadeObject.removeEventListener("FADE_COMPLETED", onFadeOutCompleted);
			removeFromParent(true);
		}
		
		private function onRemovedFromStage(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			//this event should "bubles=true"
			dispatchEvent(new Event("SCENE_CLOSED", true));
		}
	}
}