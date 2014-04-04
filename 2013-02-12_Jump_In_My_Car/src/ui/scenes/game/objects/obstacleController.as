package ui.scenes.game.objects {
	import ui.scenes.game.objects.items.obstacle;
	import ui.scenes.game.objects.utils.objectPool;
	
	/**
	 * 2014-02-24
	 * @author Pavol Kusovsky
	 */
	public class obstacleController {
		static public const __HIT:String = "HIT";
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
			var playerHeight:Number = oObjectPlayer.getJumpHeight();
			var obstacleX:int;
			var tempObstacle:obstacle;
			//check if there are obstacles on scene
			if (__activeObstacles.length > 0) {
				//load the number of active obstacles
				var i:int = __activeObstacles.length - 1;
				//get the players line
				var playerLine:uint = oObjectPlayer.line;
				//go through all obstacles if there is touching
				while (i >= 0) {
					//if obstacle has not been hit before
					if (!__activeObstacles[i].hit) {
						//get obstacle colision point
						obstacleX = __activeObstacles[i].__data.position + __activeObstacles[i].__data.collisionXPoint;
						//check if obstacle is in the position of player
						if ((playerX <= obstacleX) && (playerXW > obstacleX)) {
							//check if player is in the same line as obstacle
							if ((playerLine >= __activeObstacles[i].__data.line) && (playerLine <= __activeObstacles[i].__data.line + __activeObstacles[i].__data.wide)) {
								//if row = 0
								switch (__activeObstacles[i].__data.row) {
									case 0: 
										//if player height is lower that the obstacle tall
										if (playerHeight <= __activeObstacles[i].__data.tall) {
											//TODO - hit of the row 0
											__activeObstacles[i].hit = true;
											switch (__activeObstacles[i].__data.action) {
												case "jumpSmall": 
													//call small jump - will not occure more than once on the same obstacle
													oObjectPlayer.smallJump();
													break;
												case "end": 
													returnValue = "HIT";
													break;
											}
										}
										break;
									case 1: 
										//if player height is greater than 0 and less that (row height + obstacle height)
										if ((playerHeight > 0) && (playerHeight < obstacle.__UP_ROW_SPACE + __activeObstacles[i].__data.tall)) {
											//set hit status for this obstacle
											switch (__activeObstacles[i].__data.action) {
												case "jumpBig": 
													//check if player is not too under the jump obstacle - otherwise skip
													if (playerHeight > __activeObstacles[i].__data.pivotY) {
														//call big jump - will not occure more than once on the same obstacle
														__activeObstacles[i].hit = true;
														oObjectPlayer.bigJump();
													}
													break;
												case "end": 
													__activeObstacles[i].hit = true;
													returnValue = __HIT;
													break;
											}
										}
										break;
								}
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