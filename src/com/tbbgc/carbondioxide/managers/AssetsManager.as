package com.tbbgc.carbondioxide.managers {
	import com.tbbgc.carbondioxide.dialogues.YesNoDialogue;
	import com.tbbgc.carbondioxide.models.DataModel;
	import com.tbbgc.carbondioxide.utils.Images;
	import com.tbbgc.carbondioxide.utils.SWFDrawer;

	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.Font;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	/**
	 * @author simon
	 */
	public class AssetsManager {
		private static var _images:Images;
		private static var _swfs:SWFDrawer;

		public function AssetsManager() {
			_images = new Images();
			_swfs = new SWFDrawer();
		}

		public static function load():void {
			if( SettingsManager.haveItem(SettingsManager.SETTINGS_LAST_FONTS) ||
				SettingsManager.haveItem(SettingsManager.SETTINGS_LAST_ASSETS) ||
				SettingsManager.haveItem(SettingsManager.SETTINGS_IMAGES) ) {
				var dlg:YesNoDialogue = new YesNoDialogue("Load ALL assets ? ", "Without asking");
				dlg.onYes.addOnce( onInitDontAsk );
				dlg.onNo.addOnce( onInitAsk );
			}
		}

		public static function get names():Vector.<Object> {
			var r:Vector.<Object> = new Vector.<Object>();

			r = r.concat( _swfs.names );
			r = r.concat( _images.names );

			return r;
		}

		public static function get images():Images {
			return _images;
		}

		public static function get swfs():SWFDrawer {
			return _swfs;
		}

		public static function isImage(url:String):Boolean {
			return _images.haveImage(url);
		}

		public static function isSWF(frame:String):Boolean {
			return _swfs.haveFrame(frame);
		}

		public static function getBounds(asset:String):Rectangle {
			if( asset == null ) {
				return null;
			}

			if( _images.haveImage(asset) ) {
				var img:BitmapData = _images.getImage(asset);
				return new Rectangle(0, 0, img.width, img.height);
			}

			if( _swfs.haveFrame(asset) ) {
				return _swfs.getBounds(asset);
			}

			return null;
		}

		public static function getPackNameFromAsset(asset:String):String {
			if( asset == null ) {
				return "";
			}

			if( _swfs.haveFrame(asset) ) {
				return _swfs.getPackNameFromAsset(asset);
			}

			return "";
		}

		//Startup
		///////

		private static function onInitDontAsk():void {
			initAssets( false );
		}
		private static function onInitAsk():void {
			initAssets( true );
		}

		private static function initAssets(ask:Boolean):void {
			var files:Array;
			var i:int;
			var dlg:YesNoDialogue;

			if( SettingsManager.haveItem(SettingsManager.SETTINGS_LAST_ASSETS) ) {
				files = SettingsManager.getItem( SettingsManager.SETTINGS_LAST_ASSETS ) as Array;

				for( i = 0; i < files.length; i++ ) {
					if( ask ) {
						dlg = new YesNoDialogue("Load assets ? ", "Load file? " + files[i], files[i]);
						dlg.onYes.addOnce( onRestoreAssets );
						dlg.onNo.addOnce( onNoRestoreAssets );
					} else {
						onRestoreAssets(files[i]);
					}
				}
			}

			if( SettingsManager.haveItem(SettingsManager.SETTINGS_LAST_FONTS) ) {
				if( ask ) {
					dlg = new YesNoDialogue("Load fonts ? ", "Load file? " + SettingsManager.getItem( SettingsManager.SETTINGS_LAST_FONTS )[0], SettingsManager.getItem( SettingsManager.SETTINGS_LAST_FONTS )[0]);
					dlg.onYes.addOnce( onRestoreFonts );
					dlg.onNo.addOnce( onNoRestoreFonts );
				} else {
					onRestoreFonts(SettingsManager.getItem( SettingsManager.SETTINGS_LAST_FONTS )[0]);
				}
			}

			if( SettingsManager.haveItem(SettingsManager.SETTINGS_IMAGES) ) {
				files = SettingsManager.getItem( SettingsManager.SETTINGS_IMAGES ) as Array;

				for( i = 0; i < files.length; i++ ) {
					if( ask ) {
						dlg = new YesNoDialogue("Load image ? ", "Load image? " + files[i], files[i]);
						dlg.onYes.addOnce( onRestoreImage );
						dlg.onNo.addOnce( onNoRestoreImage );
					} else {
						onRestoreImage(files[i]);
					}
				}
			}
		}


		//Fonts
		///////

		private static function onNoRestoreFonts( url:String ):void {
			SettingsManager.setItem(SettingsManager.SETTINGS_LAST_FONTS, null);
		}

		private static function onRestoreFonts( url:String ):void {
			doLoadFonts( url );
		}

		public static function importFonts():void {
			var f:File = new File();

			f.browseForOpen("Load Fonts", [ new FileFilter("SWF File", "*.swf") ]);
			f.addEventListener(Event.SELECT, onFileFontSelected);
		}

		private static function onFileFontSelected(e:Event):void {
			var f:File = e.target as File;
			f.removeEventListener(Event.SELECT, onFileFontSelected);

			SettingsManager.setItem(SettingsManager.SETTINGS_LAST_FONTS, [f.url]);

			doLoadFonts(f.url);
		}

		private static function doLoadFonts( url:String ):void {
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onLoadFontComplete);
			loader.load( new URLRequest(url) );
		}

		private static function onLoadFontComplete(e:Event):void {
			(e.target as URLLoader).removeEventListener(Event.COMPLETE, onLoadFontComplete);

			var bytes:ByteArray = (e.target as URLLoader).data as ByteArray;
			bytes.position = 0;

			var ctx:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			ctx.allowCodeImport = true;

			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderFontComplete);
			loader.loadBytes(bytes, ctx);
		}

		private static function onLoaderFontComplete(e:Event):void {
			var info:LoaderInfo = e.target as LoaderInfo;
			info.removeEventListener(Event.COMPLETE, onLoaderFontComplete);

			var dom:ApplicationDomain = info.loader.contentLoaderInfo.applicationDomain;

			var vec:Vector.<String> = dom.getQualifiedDefinitionNames();

			for each( var t:String in vec ) {
				if( t.toLowerCase().indexOf("font")>=0 ){
					var obj:Object = getDefinitionByName(t);
					var fnt:Font = new obj() as Font;
					trace( "Register font:", fnt.fontName );
					Font.registerFont(obj as Class);
				}
			}

			DataModel.onAssetsUpdated.dispatch();
		}

		//Images
		///////

		private static function onNoRestoreImage( url:String ):void {
			removeFromSaveList(SettingsManager.SETTINGS_IMAGES, url);
		}

		private static function onRestoreImage( url:String ):void {
			addToSaveList( SettingsManager.SETTINGS_IMAGES, url );

			_images.load( url );
		}

		public static function importImages():void {
			var f:File = new File();

			f.browseForOpenMultiple("Load Image", [ new FileFilter("PNG/JPG/BMP File", "*.png;*.jpg;*.bmp") ]);
			f.addEventListener(FileListEvent.SELECT_MULTIPLE, onFileImageSelected);
		}

		private static function onFileImageSelected(e:FileListEvent):void {
			(e.target as File).removeEventListener(FileListEvent.SELECT_MULTIPLE, onFileImageSelected);

			for each( var target:File in e.files ) {
				addToSaveList( SettingsManager.SETTINGS_IMAGES, target.url );

				_images.load( target.url );
			}
		}

		//SWF
		///////

		private static function onNoRestoreAssets( url:String ):void {
			removeFromSaveList(SettingsManager.SETTINGS_LAST_ASSETS, url);
		}

		private static function onRestoreAssets( url:String ):void {
			addToSaveList( SettingsManager.SETTINGS_LAST_ASSETS, url );

			_swfs.load( url );
		}

		public static function importSWFs():void {
			var f:File = new File();

			f.browseForOpenMultiple("Load SWF", [ new FileFilter("SWF File", "*.swf") ]);
			f.addEventListener(FileListEvent.SELECT_MULTIPLE, onFileSWFSelected);
		}

		private static function onFileSWFSelected(e:FileListEvent):void {
			(e.target as File).removeEventListener(FileListEvent.SELECT_MULTIPLE, onFileSWFSelected);

			for each( var target:File in e.files ) {
				addToSaveList( SettingsManager.SETTINGS_LAST_ASSETS, target.url );

				_swfs.load( target.url );
			}
		}

		//Utils
		///////

		private static function addToSaveList( id:String, url:String ):void {
			var list:Array = SettingsManager.getItem(id) as Array;

			if( list == null ) {
				SettingsManager.setItem(id, [url]);
				return;
			}

			if( list.indexOf(url) < 0 ) {
				list.push( url );

				SettingsManager.setItem(id, list);
			}
		}

		private static function removeFromSaveList( id:String, url:String ):void {
			var list:Array = SettingsManager.getItem(id) as Array;

			if( list == null ) {
				return;
			}

			if( list.indexOf(url) >= 0 ) {
				list.splice( list.indexOf(url), 1 );

				if( list.length == 0 ) {
					SettingsManager.setItem(id, null);
				} else {
					SettingsManager.setItem(id, list);
				}
			}
		}
	}
}
