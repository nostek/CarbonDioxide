package com.stardoll.carbondioxide.managers {
	import flash.data.EncryptedLocalStore;
	import flash.utils.ByteArray;
	/**
	 * @author simonrodriguez
	 */
	public class SettingsManager {
		public static const SETTINGS_TREE:String 		= "tree";
		public static const SETTINGS_ASSETS:String 		= "assets";
		public static const SETTINGS_PROPERTIES:String 	= "properties";
		public static const SETTINGS_ALIGN:String 		= "align";
		public static const SETTINGS_FIND:String 		= "find";
		public static const SETTINGS_ITEMS:String 		= "items";
		public static const SETTINGS_ZOOM:String 		= "zoom";
		public static const SETTINGS_LAST_ASSETS:String = "last_assets";
		public static const SETTINGS_LAST_FONTS:String 	= "last_fonts";
		public static const SETTINGS_LAST_LAYOUT:String = "last_layout";
		public static const SETTINGS_WINDOW:String 		= "window";
		public static const SETTINGS_BGCOLOR:String 	= "bgcolor";
		public static const SETTINGS_RESOLUTION:String 	= "resolution";
		public static const SETTINGS_IMAGES:String 		= "images";
		public static const SETTINGS_COPYPASTE:String 	= "copypaste";
		public static const SETTINGS_MISSING:String 	= "missing";
		public static const SETTINGS_LAST_VIEW:String 	= "last_view";

		private static var _data:Object;

		public function SettingsManager() {
			load();
		}

		private static function load():void {
			_data = {};

			var ba:ByteArray = EncryptedLocalStore.getItem("carbon");

			if( ba != null ) {
				ba.position = 0;
				_data = JSON.parse( ba.readUTFBytes( ba.length ) );
			}
		}

		private static function save():void {
			var ba:ByteArray = new ByteArray();

			ba.writeUTFBytes( JSON.stringify(_data) );

			EncryptedLocalStore.setItem("carbon", ba);
		}

		//////////////////////////////

		public static function setItem( key:String, data:Object ):void {
			_data[ key ] = data;

//			trace( "save", key, data );
//			trace( new Error().getStackTrace());

			save();
		}

		public static function getItem( key:String ):Object {
			if( _data[ key ] == null ) {
				return {};
			}
			return _data[ key ];
		}

		public static function haveItem( key:String ):Boolean {
			return (_data[ key ] != null);
		}
	}
}
