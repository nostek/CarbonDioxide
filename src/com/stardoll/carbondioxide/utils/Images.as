package com.stardoll.carbondioxide.utils {
	import com.stardoll.carbondioxide.managers.SettingsManager;
	import flash.display.BitmapData;
	/**
	 * @author simonrodriguez
	 */
	public class Images {
		private static var _images:Vector.<BitmapModel>;

		public function Images() {

		}

		public static function addImage( url:String, bmd:BitmapData ):void {
			if( _images == null ) {
				_images = new Vector.<BitmapModel>();
			}

			if( url != null ) {
				var name:String = nameFromURL(url);

				if( haveImage(name) ) {
					removeImage(name);
				}

				var model:BitmapModel = new BitmapModel();
				model.url = url;
				model.name = name;
				model.bmd = bmd;

				_images.push( model );
			}

			var a:Array = [];
			for each( model in _images ) {
				a.push( model.url );
			}
			SettingsManager.setItem(SettingsManager.SETTINGS_IMAGES, a);
		}

		public static function getImage( url:String ):BitmapData {
			for each( var model:BitmapModel in _images ) {
				if( model.name == url ) {
					return model.bmd;
				}
			}
			return null;
		}

		public static function haveImage( url:String ):Boolean {
			if( _images != null ) {
				for each( var model:BitmapModel in _images ) {
					if( model.name == url ) {
						return true;
					}
				}
			}
			return false;
		}

		private static function removeImage( url:String ):void {
			for each( var model:BitmapModel in _images ) {
				if( model.name == url ) {
					_images.splice( _images.indexOf(model), 1);
					return;
				}
			}
		}

		private static function nameFromURL( url:String ):String {
			if( url.lastIndexOf("/") ) {
				return url.substr( url.lastIndexOf("/")+1 );
			}
			return url;
		}

		public static function get names():Vector.<String> {
			var ret:Vector.<String> = new Vector.<String>();

			if( _images != null ) {
				for each( var model:BitmapModel in _images ) {
					ret[ret.length] = model.name;
				}
			}

			return ret;
		}
	}
}



import flash.display.BitmapData;
internal class BitmapModel {
	public var url:String;
	public var name:String;
	public var bmd:BitmapData;
}
