package com.stardoll.carbondioxide.dialogues {
	import fl.controls.List;
	import fl.controls.TextInput;
	import com.stardoll.carbondioxide.managers.ViewsManager;
	import com.stardoll.carbondioxide.models.cd.CDItem;
	import com.stardoll.carbondioxide.models.cd.CDView;
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

			super(WIDTH, HEIGHT, "Find", true, false, true, true);

			_list = new List();
			container.addChild( _list );

			_filter = new TextInput();
			_filter.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			container.addChild(_filter);

			init(WIDTH, HEIGHT);
		}

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

			const name:String = _filter.text;
			if( name == "" ) return;

			const views:Vector.<CDView> = ViewsManager.views;

			var rec:Function = function( view:CDView, item:CDItem, path:String ):void {
				if( item.asset == name ) {
					_list.addItem({label: view.name + " - " + path + "/" + item.name} );
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
	}
}
