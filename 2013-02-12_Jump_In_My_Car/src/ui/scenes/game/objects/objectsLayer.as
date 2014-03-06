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
		
		/**
		 * Contructor
		 * @param	oLayerPlayer	reference to player object
		 */
		public function objectsLayer(oLayerPlayer:objectPlayer) {
			super()
			__layerPlayer = oLayerPlayer;
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
			__layers[0].y = 340;
			addChild(__layers[0]);
			__layers[1].y = 370;
			addChild(__layers[1]);
			__layers[2].y = 400;
			addChild(__layers[2]);
			__layers[3].y = 340 - 52;
			addChild(__layers[3]);
			__layers[4].y = 370 - 52;
			addChild(__layers[4]);
			__layers[5].y = 400 - 52;
			addChild(__layers[5]);
			addChild(__layerPlayer);
			__layerPlayer.x = __layerPlayer.__X_POSITION;
			__layerPlayer.y = 340;
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
			//move layers with objects to correct position
			for (i = 0; i < __layers.length; i++) {
				__layers[i].x = -int(nPosition);
			}
			//if in jump then index + 3
			var inJump:uint = 0;
			if (__layerPlayer.status == __layerPlayer.__IN_JUMP) {
				inJump = 3;
			}
			//set z-index for player
			__playerIndex = (__layerPlayer.line + inJump) + 1;
			this.setChildIndex(__layerPlayer, __playerIndex);
		}
	}
}