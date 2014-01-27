package com.stardoll.carbondioxide.dialogues {
	import fl.controls.Button;
	import fl.controls.List;
	import fl.controls.TextInput;
	import fl.events.ListEvent;

	import com.stardoll.carbondioxide.managers.SettingsManager;
	import com.stardoll.carbondioxide.models.DataModel;
	import com.stardoll.carbondioxide.models.ItemModel;
	import com.stardoll.carbondioxide.utils.Drawer;
	import com.stardoll.carbondioxide.utils.Images;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
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
	 * @author simonrodriguez
	 */
	public class AssetsDialogue extends BaseDialogue {
		private var _loadSwf:Button;
		private var _loadFonts:Button;
		private var _loadImages:Button;

		private var _externals:List;
		private var _filter:TextInput;

		private var _bitmap:Bitmap;
		private var _bitmapSize:int;

		private var _pendingImages:Array;

		public function AssetsDialogue( fullSize:Boolean=true ) {
			const WIDTH:int = 300;
			const HEIGHT:int = 400;

			super( "Assets", true, false, true, true );

			_loadSwf = new Button();
			_loadSwf.label = "Load Assets";
			_loadSwf.addEventListener(MouseEvent.CLICK, onLoadSWF);
			container.addChild(_loadSwf);

			_loadFonts = new Button();
			_loadFonts.label = "Load Fonts";
			_loadFonts.addEventListener(MouseEvent.CLICK, onLoadFonts);
			container.addChild(_loadFonts);

			_loadImages = new Button();
			_loadImages.label = "Load Image";
			_loadImages.addEventListener(MouseEvent.CLICK, onLoadImages);
			container.addChild(_loadImages);

			_externals = new List();
			_externals.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, onSelectExternal);
			_externals.addEventListener(Event.CHANGE, onSelectExternalChange);
			container.addChild(_externals);

			_filter = new TextInput();
			_filter.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			container.addChild(_filter);

			_bitmap = new Bitmap( new BitmapData(1, 1, true, 0xffffffff), "auto", true );
			container.addChild(_bitmap);

			_pendingImages = [];

			init( WIDTH, HEIGHT, 520, 10, !fullSize );

			onPopulateList();
		}

		public function initSettings():void {
			if( SettingsManager.haveItem(SettingsManager.SETTINGS_LAST_ASSETS) ) {
				var dlg:YesNoDialogue = new YesNoDialogue("Load assets ? ", "Load file? " + SettingsManager.getItem( SettingsManager.SETTINGS_LAST_ASSETS )[0]);
				dlg.onYes.addOnce( onRestore );
				dlg.onNo.addOnce( onNoRestore );
			}

			if( SettingsManager.haveItem(SettingsManager.SETTINGS_LAST_FONTS) ) {
				var dlg2:YesNoDialogue = new YesNoDialogue("Load fonts ? ", "Load file? " + SettingsManager.getItem( SettingsManager.SETTINGS_LAST_FONTS )[0]);
				dlg2.onYes.addOnce( onRestoreFonts );
				dlg2.onNo.addOnce( onNoRestoreFonts );
			}

			if( SettingsManager.haveItem(SettingsManager.SETTINGS_IMAGES) ) {
				_pendingImages = SettingsManager.getItem( SettingsManager.SETTINGS_IMAGES ) as Array;

				for( var i:int = _pendingImages.length-1; i >= 0; i-- ) {
					var dlg3:YesNoDialogue = new YesNoDialogue("Load image ? ", "Load image? " + _pendingImages[i]);
					dlg3.onYes.addOnce( onRestoreImage );
					dlg3.onNo.addOnce( onNoRestoreImage );
				}
			}
		}

		override protected function close():void {
			_filter.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);

			super.close();
		}

		override protected function get dialogueID():String { return SettingsManager.SETTINGS_ASSETS; }

		override protected function onResize( width:int, height:int ):void {
			_loadSwf.width = width;

			_loadFonts.y = _loadSwf.y + _loadSwf.height + 10;
			_loadFonts.width = width;

			_loadImages.y = _loadFonts.y + _loadFonts.height + 10;
			_loadImages.width = width;

			_bitmap.height = _bitmap.width = _bitmapSize = Math.min( width, height, 150 );
			_bitmap.x = width/2 - _bitmapSize/2;
			_bitmap.y = height - _bitmapSize;

			_filter.width = width;
			_filter.y = _bitmap.y - _filter.height - 10;

			_externals.width = width;
			_externals.y = _loadImages.y + _loadImages.height + 10;
			_externals.height = (_filter.y-_externals.y) - 10;
		}

		////

		private function onNoRestoreImage():void {
			_pendingImages.splice( 0, 1 );

			Images.addImage(null, null);
		}

		private function onRestoreImage():void {
			var url:String = _pendingImages[0];

			_pendingImages.splice( 0, 1 );

			doLoadFileImage( url );
		}

		private function onLoadImages(e:Event):void {
			var f:File = new File();

			f.browseForOpen("Load Image", [ new FileFilter("PNG/JPG/BMP File", "*.png;*.jpg;*.bmp") ]);
			f.addEventListener(Event.SELECT, onFileSelectedImage);
		}

		private function onFileSelectedImage(e:Event):void {
			var target:File = e.target as File;

			doLoadFileImage( target.url );
		}

		private function doLoadFileImage( url:String ):void {
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderCompleteImage);
			loader.load( new URLRequest(url) );
		}

		private function onLoaderCompleteImage(e:Event):void {
			var info:LoaderInfo = e.target as LoaderInfo;
			info.removeEventListener(Event.COMPLETE, onLoaderCompleteImage);

			var bm:Bitmap = info.loader.content as Bitmap;

			Images.addImage(info.url, bm.bitmapData);

			onPopulateList();
		}

		////

		private function onNoRestore():void {
			SettingsManager.setItem(SettingsManager.SETTINGS_LAST_ASSETS, null);
		}

		private function onRestore():void {
			var url:String = SettingsManager.getItem( SettingsManager.SETTINGS_LAST_ASSETS )[0];

			doLoadFile( url );
		}

		private function onLoadSWF(e:Event):void {
			var f:File = new File();

			f.browseForOpen("Load SWF", [ new FileFilter("SWF File", "*.swf") ]);
			f.addEventListener(Event.SELECT, onFileSelected);
		}

		private function onFileSelected(e:Event):void {
			var target:File = e.target as File;

			SettingsManager.setItem(SettingsManager.SETTINGS_LAST_ASSETS, [target.url]);

			doLoadFile( target.url );
		}

		private function doLoadFile( url:String ):void {
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			loader.load( new URLRequest(url) );
		}

		private function onLoaderComplete(e:Event):void {
			var info:LoaderInfo = e.target as LoaderInfo;
			info.removeEventListener(Event.COMPLETE, onLoaderComplete);

			var mc:MovieClip = info.loader.content as MovieClip;
			mc.gotoAndStop(1);

			new Drawer( mc );

			onPopulateList();

			if( DataModel.currentView != null ) {
				DataModel.setView( DataModel.currentView );
			}
		}

		////

		private function onNoRestoreFonts():void {
			SettingsManager.setItem(SettingsManager.SETTINGS_LAST_FONTS, null);
		}

		private function onRestoreFonts():void {
			var url:String = SettingsManager.getItem( SettingsManager.SETTINGS_LAST_FONTS )[0];

			doLoadFonts( url );
		}

		private function onLoadFonts(e:Event):void {
			var f:File = new File();

			f.browseForOpen("Load Fonts", [ new FileFilter("SWF File", "*.swf") ]);
			f.addEventListener(Event.SELECT, onFileFontSelected);
		}

		private function onFileFontSelected(e:Event):void {
			var target:File = e.target as File;

			SettingsManager.setItem(SettingsManager.SETTINGS_LAST_FONTS, [target.url]);

			doLoadFonts(target.url);
		}

		private function doLoadFonts( url:String ):void {
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onLoadDataComplete);
			loader.load( new URLRequest(url) );
		}

		private function onLoadDataComplete(e:Event):void {
			var bytes:ByteArray = (e.target as URLLoader).data as ByteArray;
			bytes.position = 0;

			var ctx:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			ctx.allowCodeImport = true;

			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderFontComplete);
			loader.loadBytes(bytes, ctx);
		}

		private function onLoaderFontComplete(e:Event):void {
			var info:LoaderInfo = e.target as LoaderInfo;
			info.removeEventListener(Event.COMPLETE, onLoaderComplete);

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
		}

		////

		private function onPopulateList():void {
			const filter:String = (_filter.text.length > 0 ? _filter.text : null);

			_externals.removeAll();

			var data:Object;
			var frame:String;
			var name:String;

			for each( data in Drawer.names ) {
				name = data["name"];
				frame = data["frame"];
				if( filter != null ) {
					if( name.indexOf(filter) >= 0 ) {
						_externals.addItem({label:name, frame:frame});
					}
				} else {
					_externals.addItem({label:name, frame:frame});
				}
			}

			for each( data in Images.names ) {
				name = data["name"];
				frame = data["frame"];
				if( filter != null ) {
					if( name.indexOf(filter) >= 0 ) {
						_externals.addItem({label:name, frame:frame});
					}
				} else {
					_externals.addItem({label:name, frame:frame});
				}
			}

			_externals.sortItemsOn("label");
		}

		private function onSelectExternal(e:ListEvent):void {
			if( _externals != null ) {
				var data:Object = _externals.getItemAt(e.index);
				if( data ) {
					var frame:String = data["frame"];
					if( frame != null ) {
						for each( var item:ItemModel in DataModel.SELECTED ) {
							item.item.asset = frame;
						}
					}
				}
			}
		}

		private function onSelectExternalChange(e:Event):void {
			var frame:String = _externals.selectedItem["frame"];

			if( frame == null ) return;

			if( Images.haveImage( frame ) ) {
				return;
			}

			_bitmap.bitmapData = Drawer.drawCenter( frame, _bitmapSize, _bitmapSize );
			_bitmap.scaleX = _bitmap.scaleY = 1;
		}

		private function onKeyUp(e:KeyboardEvent):void {
			onPopulateList();
		}
	}
}
