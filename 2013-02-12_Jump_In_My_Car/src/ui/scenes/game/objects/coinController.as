package ui.scenes.game.objects {
	import ui.scenes.game.objects.items.coin;
	import ui.scenes.game.objects.utils.objectPool;
	
	/**
	 * 2014-02-24
	 * @author Pavol Kusovsky
	 */
	public class coinController {
		private var __pooler:objectPool;
		private var __activeCoins:Vector.<coin>;
		private var __objectsLayer:objectsLayer;
		private var __lastObjectTakenAtPosition:int;
		private var __lastPosition:uint;
		
		public function coinController(oObjectsLayer:objectsLayer) {
			__objectsLayer = oObjectsLayer;
			__pooler = new objectPool(coin, 20);
			__activeCoins = new Vector.<coin>();
			initialize();
		}
		
		public function initialize():void {
			var tempCoin:coin;
			__lastObjectTakenAtPosition = 0;
			__lastPosition = 0;
			//clear pool
			while (__activeCoins.length > 0) {
				tempCoin = __activeCoins.splice(0, 1)[0];
				__objectsLayer.removeObjectFromLayer(tempCoin, tempCoin.line);
			}
			updateFrame(0);
		}
		
		public function updateFrame(nPosition:Number):void {
			var tempCoin:coin;
			//if there are coins in the data
			if (__lastObjectTakenAtPosition < config.__LEVEL_COINS_DATA.length) {
				//check the coin vector if in the new range is coin to be added
				while (config.__LEVEL_COINS_DATA[__lastObjectTakenAtPosition].position <= (nPosition + config.__WINDOW_WIDTH)) {
					tempCoin = __pooler.getObject();
					__activeCoins.push(tempCoin);
					tempCoin.initialize(config.__LEVEL_COINS_DATA[__lastObjectTakenAtPosition].position, config.__LEVEL_COINS_DATA[__lastObjectTakenAtPosition].line, config.__LEVEL_COINS_DATA[__lastObjectTakenAtPosition].position, 0);
					__objectsLayer.addObjectToLayer(tempCoin, config.__LEVEL_COINS_DATA[__lastObjectTakenAtPosition].line);
					__lastObjectTakenAtPosition++;
					if (__lastObjectTakenAtPosition == config.__LEVEL_COINS_DATA.length) {
						break;
					}
				}
			}
			var i:uint;
			//update all coins
			for (i = 0; i < __activeCoins.length; i++) {
				__activeCoins[i].updateSprite();
				//if coin is out of screen
				if (__activeCoins[i].checkVisibility(nPosition)) {
					tempCoin = __activeCoins.splice(i, 1)[0];
					__objectsLayer.removeObjectFromLayer(tempCoin, tempCoin.line);
					i--;
				}
			}
		}
		
		public function colisionWithPlayer(oObjectPlayer:objectPlayer, uPosition:uint):uint {
			var returnValue:uint = 0;
			var playerX:uint = oObjectPlayer.__X_POSITION + uPosition;
			var playerXW:uint = oObjectPlayer.__X_POSITION + uPosition + oObjectPlayer.playerCollisionWidth();
			var coinX:uint;
			var coinXW:uint;
			var tempCoin:coin;
			//check if there are coins on scene
			if (__activeCoins.length > 0) {
				var i:int = __activeCoins.length - 1;
				var playerLine:uint = oObjectPlayer.line;
				//go through all cains if there is touching
				while (i >= 0) {
					//check if player is in good height to take coin
					if (oObjectPlayer.getJumpHeight() < __activeCoins[i].coinHeight()) {
						//if on the same line
						if (__activeCoins[i].line == playerLine) {
							//check if the possition is fine to take coin
							coinX = __activeCoins[i].position;
							coinXW = __activeCoins[i].position + __activeCoins[i].coinWidth();
							if (((playerX <= coinX) && (playerXW > coinX)) || ((playerX <= coinXW) && (playerXW > coinXW))) {
								//remove coin
								tempCoin = __activeCoins.splice(i, 1)[0];
								__objectsLayer.removeObjectFromLayer(tempCoin, tempCoin.line);
								returnValue++;
							}
						}
					}
					i--;
				}
			}
			return returnValue;
		}
	}
}