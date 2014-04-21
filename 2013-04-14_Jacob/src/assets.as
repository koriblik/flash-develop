package {
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * 2014-02-11
	 * @author Pavol Kusovsky
	 */
	public class assets {
		//texture atlas coloring book
		[Embed(source="../assets/coloring_book/_textures/coloring_book.png")]
		private static const __coloringBookSpriteSheet:Class;
		[Embed(source="../assets/coloring_book/_textures/coloring_book.xml", mimeType = "application/octet-stream")]
		public static const __coloringBookSpriteSheetXML:Class;
		public static const TEXTURE_ATLAS_COLORING_BOOK:String = "__coloringBookSpriteSheet";
		//
		public static var __coloringBooksStickers:Vector.<String>;
		//
		private static var coloringBookTextureAtlas:TextureAtlas;
		//texture atlas ...
		private static var Textures:Dictionary = new Dictionary();
		private static var __selectedSpriteSheet:String;
		static public function initialize():void {
			__selectedSpriteSheet = "";
			__coloringBooksStickers = new Vector.<String>();
			__coloringBooksStickers.push("stickers/easter/basket-egs", "stickers/easter/bunny", "stickers/easter/chicken-egs-flowers", "stickers/easter/egg01", "stickers/easter/egg02", "stickers/easter/egg03", "stickers/easter/egg04");
		}
		
		/**
		 * Vrati mi TextureAtlas /na zaklade vybratej textury/.
		 * @return
		 */
		public static function getAtlas(sTextureAtlas:String):TextureAtlas {
			var texture:Texture;
			var xml:XML;
			switch (sTextureAtlas) {
					case TEXTURE_ATLAS_COLORING_BOOK:
						__selectedSpriteSheet = TEXTURE_ATLAS_COLORING_BOOK;
						if (coloringBookTextureAtlas == null) {
							texture = getTexture(TEXTURE_ATLAS_COLORING_BOOK);
							xml = new XML(new __coloringBookSpriteSheetXML());
							coloringBookTextureAtlas = new TextureAtlas(texture, xml);
						}
						return coloringBookTextureAtlas;
						break;
			}
			return null;
		}
		
		/**
		 * Vrati texturu ktora nie je Atlas. Musim mat zadefinovanu ako class!
		 * @param	sName
		 * @return
		 */
		public static function getTexture(sName:String):Texture {
			switch (__selectedSpriteSheet) {
				case TEXTURE_ATLAS_COLORING_BOOK:
					if (Textures[sName] == undefined) {
						var bitmap:Bitmap = new assets[sName]();
						Textures[sName] = Texture.fromBitmap(bitmap);
					}
					return Textures[sName];
					break;
			}
			return null;
		}
	}
}