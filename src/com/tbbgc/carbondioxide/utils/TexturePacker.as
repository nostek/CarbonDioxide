package com.tbbgc.carbondioxide.utils {
	import com.tbbgc.carbondioxide.models.DataModel;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	/**
	 * @author simon
	 */
	public class TexturePacker {
		private var _packs:Vector.<PackModel>;

		public function TexturePacker() {
			_packs = new Vector.<PackModel>();
		}

		public function load( url:String ):void {
			var loader:URLLoaderEx = new URLLoaderEx();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onLoadJSONComplete);
			loader.url = url;
			loader.load( new URLRequest(url) );
		}

		public function get names():Vector.<Object> {
			var r:Vector.<Object> = new Vector.<Object>();

			for( var y:int = 0; y < _packs.length; y++ ) {
				for( var i:int = 0; i < _packs[y].frames.length; i++ ) {
					r[r.length] = {
						name: _packs[y].frames[i].name,
						frame: _packs[y].frames[i].name,
						pack: _packs[y].name,
						type: "texturepacker"
					};
				}
			}

			return r;
		}

		public function haveFrame( frame:String ):Boolean {
			return (getFrame(frame) != null);
		}

		public function getPackNameFromAsset( frame:String ):String {
			var m:FrameModel;

			const len:int = _packs.length;
			for( var i:int = 0; i < len; i++ ) {
				m = _packs[i].hash[ frame ];
				if( m != null ) {
					return _packs[i].name;
				}
			}

			return null;
		}

		public function getImage( frame:String ):BitmapData {
			var m:FrameModel = getFrame( frame );
			if ( m != null ) {
				return m.data;
			}
			return null;
		}

		private function getFrame( frame:String ):FrameModel {
			var m:FrameModel;

			const len:int = _packs.length;
			for( var i:int = 0; i < len; i++ ) {
				m = _packs[i].hash[ frame ];
				if( m != null ) {
					return m;
				}
			}

			return null;
		}

		private function onLoadJSONComplete(e:Event):void {
			var url:URLLoaderEx = (e.target as URLLoaderEx);
			url.removeEventListener(Event.COMPLETE, onLoadJSONComplete);

			var bytes:ByteArray = (e.target as URLLoader).data as ByteArray;
			bytes.position = 0;

			var s:String = bytes.readUTFBytes(bytes.length);

			var j:Object = JSON.parse(s);

			var loader:LoaderJSON = new LoaderJSON();
			loader.url = url.url;
			loader.json = j;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.load( new URLRequest(folderFromURL(url.url) + j["meta"]["image"]) );
		}

		private function onLoadComplete(e:Event):void {
			var info:LoaderInfo = e.target as LoaderInfo;
			info.removeEventListener(Event.COMPLETE, onLoadComplete);

			var loader:LoaderJSON = info.loader as LoaderJSON;

			var url:String = loader.url;
			var json:Object = loader.json;
			var bm:Bitmap = loader.content as Bitmap;

			addPack( nameFromURL(url), json, bm.bitmapData );

			DataModel.onAssetsUpdated.dispatch();
		}

		private function addPack( name:String, json:Object, bm:BitmapData ):void {
			var p:PackModel = getPackByName(name);
			var m:FrameModel;
			var o:Object;

			var r:Rectangle = new Rectangle();
			var pt:Point = new Point();

			for( var key:String in json["frames"] ) {
				o = json["frames"][key];

				m = new FrameModel();
				m.name = key;

				r.setTo(o["frame"]["x"], o["frame"]["y"], o["frame"]["w"], o["frame"]["h"]);

				m.data = new BitmapData(r.width, r.height, true, 0x0 );
				m.data.copyPixels(bm, r, pt);

				p.frames[p.frames.length] = m;
				p.hash[key] = m;
			}
		}

		private function getPackByName( name:String ):PackModel {
			for each( var p:PackModel in _packs ) {
				if( p.name == name ) {
					return p;
				}
			}

			p = new PackModel();
			p.name = name;
			p.frames = new Vector.<FrameModel>();
			p.hash = new Dictionary();

			_packs[_packs.length] = p;

			return p;
		}

		private static function nameFromURL( url:String ):String {
			if( url.lastIndexOf("/") ) {
				return url.substr( url.lastIndexOf("/")+1 );
			}
			return url;
		}

		private static function folderFromURL( url:String ):String {
			if( url.lastIndexOf("/") ) {
				return url.substr( 0, url.lastIndexOf("/")+1 );
			}
			return url;
		}
	}
}



import flash.display.BitmapData;
import flash.display.Loader;
import flash.net.URLLoader;



internal class URLLoaderEx extends URLLoader {
	public var url:String;
}



internal class LoaderJSON extends Loader {
	public var json:Object;
	public var url:String;
}



internal final class PackModel {
	public var name:String;

	public var frames:Vector.<FrameModel>;
	public var hash:Object;
}



internal final class FrameModel {
	public var name:String;

	public var data:BitmapData;
}
