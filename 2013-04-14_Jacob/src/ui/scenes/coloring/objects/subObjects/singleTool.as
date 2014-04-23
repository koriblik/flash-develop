package ui.scenes.coloring.objects.subObjects {
	import feathers.controls.ImageLoader;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	/**
	 * 2014-04-22
	 * @author Pavol Kusovsky
	 */
	public class singleTool extends Sprite {
		private var __imageTint:Image;
		private var __color:uint;
		public function singleTool() {
			super();
			__imageTint = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture("tool_empty"));
			addChild(__imageTint);
		}
		
		public function init(sTool:String, uColor:uint):void {
			__imageTint.texture = assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture(sTool + "_tint_"+uColor.toString(16));
			__imageTint.readjustSize();
			__color = uColor;
		}
	}
}