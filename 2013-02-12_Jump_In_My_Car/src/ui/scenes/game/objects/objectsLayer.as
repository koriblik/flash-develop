package ui.scenes.game.objects {
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * 2014-02-24
	 * @author Pavol Kusovsky
	 */
	public class objectsLayer extends Sprite {
		private var __layers:Vector.<Sprite>;
		private var __layerPlayer:objectPlayer;
		private var __playerIndex:uint;
		public function objectsLayer() {
			super()
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			//remove listener
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			__layers = new Vector.<Sprite>();
			__layers.push(new Sprite());
			__layers.push(new Sprite());
			__layers.push(new Sprite());
			__layers.push(new Sprite());
			__layers.push(new Sprite());
			__layers.push(new Sprite());
			__layers[5].y = 340+120;
			__layers[4].y = 370+120;
			__layers[3].y = 400+120;
			__layers[2].y = 340;
			addChild(__layers[2]);
			__layers[1].y = 370;
			addChild(__layers[1]);
			__layers[0].y = 400;
			addChild(__layers[0]);
			__layerPlayer = new objectPlayer();
			addChild(__layerPlayer);
			__playerIndex = 0;
		}
		
		public function addObjectToLayer(sObject:Sprite, uLayer:uint):void {
			__layers[uLayer].addChild(sObject);
		}
		public function removeObjectFromLayer(sObject:Sprite, uLayer:uint):void {
			__layers[uLayer].removeChild(sObject);
		}
		
		public function updateFrame(nPosition:Number):void {
			var i:uint;
			for (i = 0; i < __layers.length; i++) {
				__layers[i].x = -int(nPosition);
			}
		}
	}
}