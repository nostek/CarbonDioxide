package com.stardoll.carbondioxide.dialogues {
	import fl.controls.Button;
	import fl.controls.List;
	import fl.events.ComponentEvent;

	import com.stardoll.carbondioxide.managers.ViewsManager;
	import com.stardoll.carbondioxide.models.DataModel;
	import com.stardoll.carbondioxide.models.cd.CDView;

	/**
	 * @author simonrodriguez
	 */
	public class ManageViewsDialogue extends BaseDialogue {
		private var _list:List;

		private var _rename:Button;
		private var _delete:Button;

		public function ManageViewsDialogue() {
			const WIDTH:int = 400;
			const HEIGHT:int = 500;

			super(WIDTH, HEIGHT, "Manage Views", false, true, true, true);

			_rename = new Button();
			_rename.label = "Rename";
			_rename.addEventListener(ComponentEvent.BUTTON_DOWN, onRename);
			container.addChild(_rename);

			_delete = new Button();
			_delete.label = "Delete";
			_delete.addEventListener(ComponentEvent.BUTTON_DOWN, onDelete);
			container.addChild(_delete);

			_list = new List();
			container.addChild(_list);

			buildList();

			init(WIDTH, HEIGHT);
		}

		override protected function onResize( width:int, height:int ):void {
			_rename.x = width - _rename.width;

			_delete.x = _rename.x;
			_delete.y = _rename.y + _rename.height + 10;

			_list.width = _rename.x - 10;
			_list.height = height;
		}

		private function buildList():void {
			_list.removeAll();

			const views:Vector.<CDView> = ViewsManager.views;
			const len:int = views.length;
			for( var i:int = 0; i < len; i++ ) {
				_list.addItem({label: views[i].name, view:views[i]});
			}
		}

		private function onRename(e:ComponentEvent):void {
			if( _list.selectedIndex >= 0 ) {
				const view:CDView = _list.selectedItem["view"];
				if( view != null ) {
					var dlg:InputDialogue = new InputDialogue("Rename Flow", "Enter name:", view.name);
					dlg.onOK.addOnce( onRenameFlow );
				}
			}
		}

		private function onRenameFlow( dlg:InputDialogue ):void {
			const text:String = dlg.text;

			if( text == null || text == "" ) return;

			const view:CDView = _list.selectedItem["view"];
			if( view != null ) {
				view.name = text;

				buildList();

				DataModel.setView( view );
			}
		}

		private function onDelete(e:ComponentEvent):void {
			if( ViewsManager.views.length > 1 && _list.selectedIndex >= 0 ) {

				const view:CDView = _list.selectedItem["view"];
				if( view != null ) {
					ViewsManager.removeView( view );
				}

				buildList();

				DataModel.setView(ViewsManager.views[0]);
			}
		}
	}
}
