package com.tbbgc.carbondioxide.dialogues {
	import fl.controls.List;
	import fl.controls.TextInput;
	import fl.events.ListEvent;

	import com.tbbgc.carbondioxide.managers.AssetsManager;
	import com.tbbgc.carbondioxide.managers.SettingsManager;
	import com.tbbgc.carbondioxide.models.DataModel;
	import com.tbbgc.carbondioxide.models.ItemModel;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.KeyboardEvent;

	/**
	 * @author simonrodriguez
	 */
	public class AssetsDialogue extends BaseDialogue {
		private var _externals:List;
		private var _filter:TextInput;

		private var _bitmap:Bitmap;
		private var _bitmapSize:int;

		public function AssetsDialogue( fullSize:Boolean=true ) {
			const WIDTH:int = 300;
			const HEIGHT:int = 400;

			super( "Assets", true, false, true, true );

			DataModel.onFilterAssets.add( onFilterAssets );
			DataModel.onAssetsUpdated.add( onPopulateList );

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

		override protected function close():void {
			_filter.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);

			super.close();
		}

		override protected function get dialogueID():String { return SettingsManager.SETTINGS_ASSETS; }

		override protected function onResize( width:int, height:int ):void {
			_bitmap.height = _bitmap.width = _bitmapSize = Math.min( width, height, 150 );
			_bitmap.x = width/2 - _bitmapSize/2;
			_bitmap.y = height - _bitmapSize;

			_filter.width = width;
			_filter.y = _bitmap.y - _filter.height - 10;

			_externals.width = width;
			_externals.y = 10;
			_externals.height = (_filter.y-_externals.y) - 10;
		}

		////

		private function onPopulateList():void {
			const filter:String = (_filter.text.length > 0 ? _filter.text : null);

			_externals.removeAll();

			var data:Object;
			var name:String;
			var frame:String;

			for each( data in AssetsManager.names ) {
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

						stage.focus = null;
					}
				}
			}
		}

		private function onSelectExternalChange(e:Event):void {
			var frame:String = _externals.selectedItem["frame"];

			if( frame == null ) return;

			if( AssetsManager.isImage( frame ) ) {
				_bitmap.bitmapData = AssetsManager.images.getImage( frame );
				_bitmap.width = _bitmapSize;
				_bitmap.height = _bitmapSize;
			}
			if( AssetsManager.isSWF( frame) ) {
				_bitmap.bitmapData = AssetsManager.swfs.drawCenter( frame, _bitmapSize, _bitmapSize );
				_bitmap.scaleX = _bitmap.scaleY = 1;
			}
		}

		private function onKeyUp(e:KeyboardEvent):void {
			onPopulateList();
		}

		private function onFilterAssets( filter:String ):void {
			_filter.text = filter;

			onPopulateList();
		}
	}
}
