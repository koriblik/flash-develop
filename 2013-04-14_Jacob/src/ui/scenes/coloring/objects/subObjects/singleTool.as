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
		private var __imageBg:Image;
		private var __imageTint:Image;
		private var __color:uint;
		public function singleTool() {
			super();
			__imageBg = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture("tool_empty"));
			addChild(__imageBg);
			__imageTint = new Image(assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture("tool_empty"));
			addChild(__imageTint);
		}
		
		public function init(sTool:String, uColor:uint):void {
			__imageBg.texture = assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture(sTool + "_bg");
			__imageBg.readjustSize();
			__imageTint.texture = assets.getAtlas(assets.TEXTURE_ATLAS_COLORING_BOOK).getTexture(sTool + "_tint");
			__imageTint.readjustSize();
			__color = uColor;
			__imageTint.color = uColor;
		}
	}
}