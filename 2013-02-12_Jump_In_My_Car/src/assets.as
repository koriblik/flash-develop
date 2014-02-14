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
		//texture atlas
		[Embed(source = "../assets/textures_64.png")]
		private static const __gameTexture64SpriteSheet:Class;
		[Embed(source="../assets/textures_64.xml", mimeType = "application/octet-stream")]
		public static const __gameTexture64SpriteSheetXML:Class;
		//
		private static var gameTextures:Dictionary = new Dictionary();
		private static var gameTextureAtlas:TextureAtlas;
		private static var __selectedTextureSheet:String;
		/*
		//levels
		[Embed(source="../lib/data/levels.xml",mimeType="application/octet-stream")]
		private static const __levelsClass:Class;
		public static var __levelsXML:XML;
		*/
		static public function initialize():void {
			/*
			__levelsXML = XML(new __levelsClass());
			*/
			//TODO tu pridat vyber texturoveho subory na zaklade rozlisenia
			__selectedTextureSheet = "__gameTexture64SpriteSheet";
		}
		
		/**
		 * Vrati mi TextureAtlas /na zaklade vybratej textury/.
		 * @return
		 */
		public static function getAtlas():TextureAtlas {
			if (gameTextureAtlas == null) {
				var texture:Texture = getTexture(__selectedTextureSheet);
				var xml:XML = new XML(new __gameTexture64SpriteSheetXML());
				gameTextureAtlas = new TextureAtlas(texture, xml);
			}
			return gameTextureAtlas;
		}
		
		/**
		 * Vrati texturu ktora nie je Atlas. Musim mat zadefinovanu ako class!
		 * @param	sName
		 * @return
		 */
		public static function getTexture(sName:String):Texture {
			if (gameTextures[sName] == undefined) {
				var bitmap:Bitmap = new assets[sName]();
				gameTextures[sName] = Texture.fromBitmap(bitmap);
			}
			return gameTextures[sName];
		}
	}
}