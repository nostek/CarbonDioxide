package com.tbbgc.carbondioxide.utils {
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	/**
	 * @author Simon
	 */
	public class Legacy {
		public static var LEGACY:Array;

		public static function load():void {
			var f:File = new File();
			var filter:FileFilter = new FileFilter("Design", "*.json");

			f.browseForOpen("Load Design", [filter]);
			f.addEventListener(Event.SELECT, onSelectedFile);
		}

		private static function onSelectedFile( e:Event ):void {
			var f:File = e.target as File;

			doLoadFile(f);
		}

		private static function doLoadFile( f:File ):void {
			var file:FileStream = new FileStream();
			file.open(f, FileMode.READ);
				var json:Object = JSON.parse(file.readUTFBytes(file.bytesAvailable));
			file.close();

			LEGACY = loadData( json );
		}

		private static function loadData( data:Object ):Array {
			var r:Array = [];

			var items:Object;
			var item:Object;
			var name:String;

			for each( var view:Object in data ) {
				items = view["items"];
				if( items != null ) {

					for each( item in items ) {
						if( item["parameters"] != null && item["parameters"]["asset"] != null ) {
							name = item["parameters"]["asset"];

							if( r.indexOf( name ) <= 0 ) {
								r.push( name );
							}
						}
					}

				}
			}

			return r.length > 0 ? r : null;
		}
	}
}
