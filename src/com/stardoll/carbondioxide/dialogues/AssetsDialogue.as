package com.stardoll.carbondioxide.dialogues {
	import fl.controls.Button;
	import fl.controls.List;
	import fl.controls.TextInput;
	import fl.events.ListEvent;

	import com.stardoll.carbondioxide.models.DataModel;
	import com.stardoll.carbondioxide.models.ItemModel;
	import com.stardoll.carbondioxide.utils.Drawer;

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
		private var _database:Vector.<String>;

		private var _loadSwf:Button;
		private var _loadFonts:Button;
		private var _externals:List;
		private var _filter:TextInput;

		private var _bitmap:Bitmap;
		private var _bitmapSize:int;

		public function AssetsDialogue( fullSize:Boolean=true ) {
			const WIDTH:int = 300;
			const HEIGHT:int = 400;

			super( WIDTH, HEIGHT, "Assets", true, false, true, true );

			_loadSwf = new Button();
			_loadSwf.label = "Load Assets";
			_loadSwf.addEventListener(MouseEvent.CLICK, onLoadSWF);
			container.addChild(_loadSwf);

			_loadFonts = new Button();
			_loadFonts.label = "Load Fonts";
			_loadFonts.addEventListener(MouseEvent.CLICK, onLoadFonts);
			container.addChild(_loadFonts);

			_externals = new List();
			_externals.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, onSelectExternal);
			_externals.addEventListener(Event.CHANGE, onSelectExternalChange);
			container.addChild(_externals);

			_filter = new TextInput();
			_filter.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			container.addChild(_filter);

			_bitmap = new Bitmap( new BitmapData(1, 1, true, 0xffffffff), "auto", true );
			container.addChild(_bitmap);

			init( WIDTH, HEIGHT );

			this.x = 520;
			this.y = 10;

			if( !fullSize ) {
				minimize();
			}

			if( Drawer.isLoaded ) {
				runFrames();
			} else {
				_database = new Vector.<String>();
			}
		}

		override protected function onResize( width:int, height:int ):void {
			_loadSwf.width = width;

			_loadFonts.y = _loadSwf.y + _loadSwf.height + 10;
			_loadFonts.width = width;

			_bitmap.height = _bitmap.width = _bitmapSize = Math.min( width, height, 150 );
			_bitmap.x = width/2 - _bitmapSize/2;
			_bitmap.y = height - _bitmapSize;

			_filter.width = width;
			_filter.y = _bitmap.y - _filter.height - 10;

			_externals.width = width;
			_externals.y = _loadFonts.y + _loadFonts.height + 10;
			_externals.height = (_filter.y-_externals.y) - 10;

		}

		////

		private function onLoadSWF(e:Event):void {
			var f:File = new File();

			f.browseForOpen("Load SWF", [ new FileFilter("SWF File", "*.swf") ]);
			f.addEventListener(Event.SELECT, onFileSelected);
		}

		private function onFileSelected(e:Event):void {
			var target:File = e.target as File;

			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			loader.load( new URLRequest(target.url) );
		}

		private function onLoaderComplete(e:Event):void {
			var info:LoaderInfo = e.target as LoaderInfo;
			info.removeEventListener(Event.COMPLETE, onLoaderComplete);

			var mc:MovieClip = info.loader.content as MovieClip;
			mc.gotoAndStop(1);

			new Drawer( mc );

			runFrames();

			if( DataModel.currentView != null ) {
				DataModel.setView( DataModel.currentView );
			}
		}

		private function runFrames():void {
			_database = Drawer.names;

			onPopulateList();
		}

		////

		private function onLoadFonts(e:Event):void {
			var f:File = new File();

			f.browseForOpen("Load Fonts", [ new FileFilter("SWF File", "*.swf") ]);
			f.addEventListener(Event.SELECT, onFileFontSelected);
		}

		private function onFileFontSelected(e:Event):void {
			var target:File = e.target as File;

			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onLoadDataComplete);
			loader.load( new URLRequest(target.url) );
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
			for each( var frame:String in _database ) {
				if( filter != null ) {
					if( frame.indexOf(filter) >= 0 ) {
						_externals.addItem({label:frame});
					}
				} else {
					_externals.addItem({label:frame});
				}
			}
			_externals.sortItemsOn("label");
		}

		private function onSelectExternal(e:ListEvent):void {
			if( _externals != null ) {
				var data:Object = _externals.getItemAt(e.index);
				if( data ) {
					var frame:String = data["label"];
					if( frame != null ) {
						for each( var item:ItemModel in DataModel.SELECTED ) {
							item.item.asset = frame;

							DataModel.itemChanged( item );
						}
					}
				}
			}
		}

		private function onSelectExternalChange(e:Event):void {
			var frame:String = _externals.selectedItem["label"];

			if( frame == null ) return;

			_bitmap.bitmapData = Drawer.drawCenter( frame, _bitmapSize, _bitmapSize );
			_bitmap.scaleX = _bitmap.scaleY = 1;
		}

		private function onKeyUp(e:KeyboardEvent):void {
			onPopulateList();
		}
	}
}
