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
					trace("removed");
					tempObstacle = __activeObstacles.splice(i, 1)[0];
					__objectsLayer.removeObjectFromLayer(tempObstacle, tempObstacle.getLine());
					i--;
				}
			}
		}
	
	}
}