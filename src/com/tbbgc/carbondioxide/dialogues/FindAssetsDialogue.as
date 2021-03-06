package com.tbbgc.carbondioxide.dialogues {
	import fl.controls.List;
	import fl.controls.TextInput;
	import fl.events.ListEvent;

	import com.tbbgc.carbondioxide.managers.EventManager;
	import com.tbbgc.carbondioxide.managers.SettingsManager;
	import com.tbbgc.carbondioxide.managers.ViewsManager;
	import com.tbbgc.carbondioxide.models.DataModel;
	import com.tbbgc.carbondioxide.models.cd.CDItem;
	import com.tbbgc.carbondioxide.models.cd.CDView;

	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	/**
	 * @author simonrodriguez
	 */
	public class FindAssetsDialogue extends BaseDialogue {
		private var _list:List;

		private var _filter:TextInput;

		public function FindAssetsDialogue() {
			const WIDTH:int = 300;
			const HEIGHT:int = 450;

			super("Find", true, false, true, true);

			_list = new List();
			_list.doubleClickEnabled = true;
			_list.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, onShowItem);
			container.addChild( _list );

			_filter = new TextInput();
			_filter.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			container.addChild(_filter);

			init(WIDTH, HEIGHT);
		}

		override protected function get dialogueID():String { return SettingsManager.SETTINGS_FIND; }

		override protected function onResize( width:int, height:int ):void {
			_filter.width = width;
			_filter.y = height - _filter.height;

			_list.width = width;
			_list.height = _filter.y;
		}

		private function onKeyUp(e:KeyboardEvent):void {
			if( e.keyCode == Keyboard.ENTER ) {
				build();
			}
		}

		private function build():void {
			_list.removeAll();

			var name:String = _filter.text;
			if( name == "" ) return;
			name = name.toLowerCase();

			const views:Vector.<CDView> = ViewsManager.views;

			var rec:Function = function( view:CDView, item:CDItem, path:String ):void {
				if( item.asset != null && item.asset.toLowerCase().indexOf(name) >= 0 ) {
					_list.addItem({
						label: view.name + " - " + path + "/" + item.name,
						view: view,
						item: item
					});
				}

				for each( var ch:CDItem in item.children ) {
					rec( view, ch, path + "/" + item.name);
				}
			};

			for each( var view:CDView in views ) {
				for each( var ch:CDItem in view.children ) {
					rec( view, ch, "");
				}
			}
		}

		override protected function close():void {
			_filter.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);

			super.close();
		}

		private function onShowItem(e:ListEvent):void {
			const index:int = e.index;

			var data:Object = _list.getItemAt(index);
			var view:CDView = data["view"];
			var item:CDItem = data["item"];

			if( DataModel.currentView != view ) {
				DataModel.setView(view);
			}

			if( item.parent != DataModel.currentLayer ) {
				DataModel.setLayer( item.parent );
			}

			EventManager.selectItems([item]);
		}
	}
}
