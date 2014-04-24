package {
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import utils.algorithms;
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
		public static var __coloringBookStickers:Vector.<String>;
		public static var __coloringBookStamps:Vector.<String>;
		public static var __coloringBookParticles:Vector.<String>;
		public static var __coloringBookToolsPallete:Vector.<uint>;
		//
		private static var coloringBookTextureAtlas:TextureAtlas;
		//texture atlas ...
		private static var Textures:Dictionary = new Dictionary();
		private static var __selectedSpriteSheet:String;
		static public function initialize():void {
			__selectedSpriteSheet = "";
			__coloringBookStickers = new Vector.<String>();
			__coloringBookStickers.push("stickers/easter/basket-egs", "stickers/easter/bunny", "stickers/easter/chicken-egs-flowers", "stickers/easter/egg01", "stickers/easter/egg02", "stickers/easter/egg03", "stickers/easter/egg04");
			__coloringBookStamps = new Vector.<String>();
			__coloringBookParticles = new Vector.<String>();
			__coloringBookParticles.push("particles/star");
			__coloringBookToolsPallete = new Vector.<uint>(); 0xff000000,
			__coloringBookToolsPallete.push(0xFF000000, 0xFFFFFFFF, 0xFFFF0000, 0xFF00FF00, 0xFF0000FF, 0xFFFFFF00, 0xFFFF00FF, 0xFF00FFFF, 0xFF800000, 0xFF008000, 0xFF000080, 0xFF808000, 0xFF800080, 0xFF008080, 0xFFC0C0C0, 0xFF808080, 0xFF9999FF, 0xFF993366, 0xFFFFFFCC, 0xFFCCFFFF, 0xFF660066, 0xFFFF8080, 0xFF0066CC, 0xFFCCCCFF, 0xFF000080, 0xFFFF00FF, 0xFFFFFF00, 0xFF00FFFF, 0xFF800080, 0xFF800000, 0xFF008080, 0xFF0000FF, 0xFF00CCFF, 0xFFCCFFFF, 0xFFCCFFCC, 0xFFFFFF99, 0xFF99CCFF, 0xFFFF99CC, 0xFFCC99FF, 0xFFFFCC99, 0xFF3366FF, 0xFF33CCCC, 0xFF99CC00, 0xFFFFCC00, 0xFFFF9900, 0xFFFF6600, 0xFF666699, 0xFF969696, 0xFF003366, 0xFF339966, 0xFF003300, 0xFF333300, 0xFF993300, 0xFF993366, 0xFF333399, 0xFF333333);
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