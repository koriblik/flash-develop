package {
	
	/**
	 * ...
	 * @author pk
	 */
	public class moveTheTree {
		import flash.geom.Vector3D;
		private var putTheTreeHere:Vector3D = new Vector3D(50, 0, 5000);
		private var moveItByThisMuch:Vector3D = new Vector3D(50, 0, 555);
		private var moveItByThisMuchDelta:Vector3D;
		public function moveTheTree():void {
			trace('The tree started here: ' + putTheTreeHere);
			putTheTreeHere = putTheTreeHere.add(moveItByThisMuch);
			trace('The tree is now here: ' + putTheTreeHere);
		}
		public function moveTheTreeDelta(delta:uint):void {
			moveItByThisMuchDelta = moveItByThisMuch.clone();
			moveItByThisMuchDelta.scaleBy(Number(delta / 1000));
			putTheTreeHere = putTheTreeHere.add(moveItByThisMuchDelta);
			trace('The tree is now here: ' + putTheTreeHere);
		}
	}
}