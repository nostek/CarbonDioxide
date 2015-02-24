package com.tbbgc.carbondioxide.dialogues {
	import fl.controls.List;
	import fl.events.ListEvent;

	import com.tbbgc.carbondioxide.models.resolutions.ResolutionsModel;

	import org.osflash.signals.Signal;

	/**
	 * @author Simon
	 */
	public class SelectResolutionDialogue extends BaseDialogue {
		private var _list:List;

		private var _onSelect:Signal;

		public function SelectResolutionDialogue() {
			const WIDTH:int = 400;
			const HEIGHT:int = 300;

			super("Select resolution", false, true, false, true);

			_onSelect = new Signal( Object );

			_list = new List();
			_list.width = 400;
			_list.height = 300;
			_list.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, onSelected);
			container.addChild(_list);

			init( WIDTH, HEIGHT );

			populate();
		}

		override protected function close():void {
			_onSelect.removeAll();

			super.close();
		}

		public function get onSelect():Signal { return _onSelect; }

		private function populate():void {
			_list.removeAll();

			var reses:Array = ResolutionsModel.resolutions;

			reses = reses.sort( sort );

			var w:int;
			var h:int;

			for each( var o:Object in reses ) {
				w = o["width"];
				h = o["height"];

				_list.addItem({label:String(o["label"]),data:o});
			}
		}

		private static function sort( a:Object, b:Object ):int {
			if( Number(a["size"]) == Number(b["size"]) ) {
				var ai:int = a["width"] * a["height"];
				var bi:int = b["width"] * b["height"];
				if( ai == bi ) return 0;
				return (ai < bi) ? -1 : 1;
			}
			return (Number(a["size"]) < Number(b["size"])) ? -1 : 1;
		}

		private function onSelected( e:ListEvent ):void {
			_onSelect.dispatch( e.item["data"] );

			close();
		}
	}
}
