package com.tbbgc.carbondioxide.dialogues {
	import fl.controls.Button;
	import fl.controls.List;
	import fl.controls.TextInput;
	import fl.events.ListEvent;

	import com.tbbgc.carbondioxide.managers.SettingsManager;
	import com.tbbgc.carbondioxide.models.DataModel;
	import com.tbbgc.carbondioxide.models.ItemModel;
	import com.tbbgc.carbondioxide.utils.Drawer;
	import com.tbbgc.carbondioxide.utils.Images;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FileListEvent;
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

		public function AssetsDialogue( fullSize:Boolean=true ) {
			const WIDTH:int = 300;
			const HEIGHT:int = 400;

			super( "Assets", true, false, true, true );

			DataModel.onFilterAssets.add( onFilterAssets );

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

			init( WIDTH, HEIGHT, 520, 10, !fullSize );

			onPopulateList();
		}

		public function initSettings():void {
			if( SettingsManager.haveItem(SettingsManager.SETTINGS_LAST_ASSETS) ||
				SettingsManager.haveItem(SettingsManager.SETTINGS_LAST_FONTS) ||
				SettingsManager.haveItem(SettingsManager.SETTINGS_IMAGES) ) {
					var dlg:YesNoDialogue = new YesNoDialogue("Load ALL assets ? ", "Without asking");
					dlg.onYes.addOnce( onInitDontAsk );
					dlg.onNo.addOnce( onInitAsk );
			}
		}

		private function onInitDontAsk():void {
			initAssets( false );
		}
		private function onInitAsk():void {
			initAssets( true );
		}

		private function initAssets(ask:Boolean):void {
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

		////

		private function onNoRestoreImage( url:String ):void {
			removeFromSaveList(SettingsManager.SETTINGS_IMAGES, url);
		}

		private function onRestoreImage( url:String ):void {
			addToSaveList( SettingsManager.SETTINGS_IMAGES, url );

			doLoadFileImage( url );
		}

		private function onLoadImages(e:Event):void {
			var f:File = new File();

			f.browseForOpenMultiple("Load Image", [ new FileFilter("PNG/JPG/BMP File", "*.png;*.jpg;*.bmp") ]);
			f.addEventListener(FileListEvent.SELECT_MULTIPLE, onFileSelectedImage);
		}

		private function onFileSelectedImage(e:FileListEvent):void {
			for each( var target:File in e.files ) {
				addToSaveList( SettingsManager.SETTINGS_IMAGES, target.url );

				doLoadFileImage( target.url );
			}
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

			if( DataModel.currentView != null ) {
				DataModel.setView( DataModel.currentView );
			}
		}

		////

		private function onNoRestoreAssets( url:String ):void {
			removeFromSaveList(SettingsManager.SETTINGS_LAST_ASSETS, url);
		}

		private function onRestoreAssets( url:String ):void {
			addToSaveList( SettingsManager.SETTINGS_LAST_ASSETS, url );

			doLoadFile( url );
		}

		private function onLoadSWF(e:Event):void {
			var f:File = new File();

			f.browseForOpenMultiple("Load SWF", [ new FileFilter("SWF File", "*.swf") ]);
			f.addEventListener(FileListEvent.SELECT_MULTIPLE, onFileSelected);
		}

		private function onFileSelected(e:FileListEvent):void {
			for each( var target:File in e.files ) {
				addToSaveList( SettingsManager.SETTINGS_LAST_ASSETS, target.url );

				doLoadFile( target.url );
			}
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

			Drawer.addPack( nameFromURL(info.url), mc );

			onPopulateList();

			if( DataModel.currentView != null ) {
				DataModel.setView( DataModel.currentView );
			}
		}

		////

		private function onNoRestoreFonts( url:String ):void {
			SettingsManager.setItem(SettingsManager.SETTINGS_LAST_FONTS, null);
		}

		private function onRestoreFonts( url:String ):void {
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

			if( DataModel.currentView != null ) {
				DataModel.setView( DataModel.currentView );
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

			for each( name in Images.names ) {
				if( filter != null ) {
					if( name.indexOf(filter) >= 0 ) {
						_externals.addItem({label:name, frame:name});
					}
				} else {
					_externals.addItem({label:name, frame:name});
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

		private function onFilterAssets( filter:String ):void {
			_filter.text = filter;

			onPopulateList();
		}

		private static function nameFromURL( url:String ):String {
			if( url.lastIndexOf("/") ) {
				return url.substr( url.lastIndexOf("/")+1 );
			}
			return url;
		}
	}
}
