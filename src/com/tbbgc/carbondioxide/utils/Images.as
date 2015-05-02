package com.tbbgc.carbondioxide.utils {
	import flash.display.BitmapData;
	/**
	 * @author simonrodriguez
	 */
	public class Images {
		private var _images:Vector.<BitmapModel>;

		public function Images() {
			_images = new Vector.<BitmapModel>();
		}

		public function addImage( url:String, bmd:BitmapData ):void {
			if( url != null ) {
				var name:String = nameFromURL(url);

				if( haveImage(name) ) {
					removeImage(name);
				}

				var model:BitmapModel = new BitmapModel();
				model.name = name;
				model.url = url;
				model.bmd = bmd;

				_images.push( model );
			}
		}

		public function getImage( url:String ):BitmapData {
			for each( var model:BitmapModel in _images ) {
				if( model.name == url ) {
					return model.bmd;
				}
			}
			return null;
		}

		public function haveImage( url:String ):Boolean {
			for each( var model:BitmapModel in _images ) {
				if( model.name == url ) {
					return true;
				}
			}
			return false;
		}

		private function removeImage( url:String ):void {
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

		public function get names():Vector.<Object> {
			var ret:Vector.<Object> = new Vector.<Object>();

			for each( var model:BitmapModel in _images ) {
				ret[ret.length] = {
					name: model.name,
					frame: model.name,
					type: "image"
				};
			}

			return ret;
		}

		public function get urls():Object {
			var ret:Object = {};

			for each( var model:BitmapModel in _images ) {
				ret[model.name] = model.url;
			}

			return ret;
		}
	}
}



import flash.display.BitmapData;



internal class BitmapModel {
	public var name:String;
	public var url:String;
	public var bmd:BitmapData;
}
