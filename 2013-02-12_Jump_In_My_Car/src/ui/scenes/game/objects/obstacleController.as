package ui.scenes.game.objects {
	import ui.scenes.game.objects.items.obstacle;
	import ui.scenes.game.objects.utils.objectPool;
	
	/**
	 * 2014-02-24
	 * @author Pavol Kusovsky
	 */
	public class obstacleController {
		private var __pooler:objectPool;
		private var __activeObstacles:Vector.<obstacle>;
		private var __objectsLayer:objectsLayer;
		private var __lastObjectTakenAtPosition:int;
		private var __lastPosition:uint;
		
		public function obstacleController(oObjectsLayer:objectsLayer) {
			__objectsLayer = oObjectsLayer;
			__pooler = new objectPool(obstacle, 20);
			__activeObstacles = new Vector.<obstacle>();
			initialize();
		}
		
		public function initialize():void {
			__lastObjectTakenAtPosition = 0;
			__lastPosition = 0;
			var tempObstacle:obstacle;
			//clear pool
			while (__activeObstacles.length > 0) {
				tempObstacle = __activeObstacles.splice(0, 1)[0];
				__objectsLayer.removeObjectFromLayer(tempObstacle, tempObstacle.getLine());
			}
			updateFrame(0);
		}
		
		public function updateFrame(nPosition:Number):void {
			var tempObstacle:obstacle;
			//if there are obstacles in the data
			if (__lastObjectTakenAtPosition < config.__LEVEL_OBSTACLES_DATA.length) {
				//check the obstacle vector if in the new range is obstacle to be added
				while (config.__LEVEL_OBSTACLES_DATA[__lastObjectTakenAtPosition].position <= (nPosition + config.__WINDOW_WIDTH)) {
					tempObstacle = __pooler.getObject();
					__activeObstacles.push(tempObstacle);
					tempObstacle.initialize(config.__LEVEL_OBSTACLES_DATA[__lastObjectTakenAtPosition]);
					__objectsLayer.addObjectToLayer(tempObstacle, tempObstacle.getLine());
					__lastObjectTakenAtPosition++;
					if (__lastObjectTakenAtPosition == config.__LEVEL_OBSTACLES_DATA.length) {
						break;
					}
				}
			}
			var i:uint;
			//update all obstacles
			for (i = 0; i < __activeObstacles.length; i++) {
				__activeObstacles[i].updateSprite();
				//if obstacle is out of screen
				if (__activeObstacles[i].checkVisibility(nPosition)) {
					tempObstacle = __activeObstacles.splice(i, 1)[0];
					__objectsLayer.removeObjectFromLayer(tempObstacle, tempObstacle.getLine());
					i--;
				}
			}
		}
		
		public function colisionWithPlayer(oObjectPlayer:objectPlayer, uPosition:uint):String {
			var returnValue:String = "";
			var playerX:uint = oObjectPlayer.__X_POSITION + uPosition;
			var playerXW:uint = oObjectPlayer.__X_POSITION + uPosition + oObjectPlayer.playerCollisionWidth();
			var obstacleX:int;
			var tempObstacle:obstacle;
			/*
			   var coinXW:uint;
			 */
			//check if there are obstacles on scene
			if (__activeObstacles.length > 0) {
				//load the number of active obstacles
				var i:int = __activeObstacles.length - 1;
				//get the players line
				var playerLine:uint = oObjectPlayer.line;
				//go through all obstacles if there is touching
				while (i >= 0) {
					//get obstacle colision point
					obstacleX = __activeObstacles[i].__data.position + __activeObstacles[i].__data.collisionxpoint;
					//!delete start
					Main.__tempOutput.htmlText += obstacleX.toString() + ":" + playerX.toString();
					Main.__tempDraw.graphics.lineStyle(1, 0x00ff00);
					Main.__tempDraw.graphics.moveTo(obstacleX-uPosition, 0);
					Main.__tempDraw.graphics.lineTo(obstacleX-uPosition, config.__WINDOW_HEIGHT);
					//!end
					//check if obstacle is in the position of player
					if ((playerX <= obstacleX) && (playerXW > obstacleX)) {
						Main.__tempDraw.graphics.lineStyle(1, 0xff0000);
						Main.__tempDraw.graphics.moveTo(obstacleX-uPosition, 0);
						Main.__tempDraw.graphics.lineTo(obstacleX-uPosition, config.__WINDOW_HEIGHT);
						/*
						   //check if player is in good height to take coin
						   if (oObjectPlayer.getJumpHeight() < __activeCoins[i].coinHeight()) {
						   //if on the same line
						   if (__activeCoins[i].line == playerLine) {
						   //check if the possition is fine to take coin
						 */ /*
						   coinXW = __activeCoins[i].position + __activeCoins[i].coinWidth();
						   if (((playerX <= coinX) && (playerXW > coinX)) || ((playerX <= coinXW) && (playerXW > coinXW))) {
						   Main.__tempDraw.graphics.clear();
						   Main.__tempDraw.graphics.lineStyle(1, 0xff0000);
						   Main.__tempDraw.graphics.drawRect(oObjectPlayer.__X_POSITION, 0, oObjectPlayer.playerCollisionWidth(), config.__WINDOW_HEIGHT);
						   //remove coin
						   tempCoin = __activeCoins.splice(i, 1)[0];
						   __objectsLayer.removeObjectFromLayer(tempCoin, tempCoin.line);
						   returnValue++;
						   }
						   }
						 */
					}
					i--;
				}
			}
			return returnValue;
		}
	}
}