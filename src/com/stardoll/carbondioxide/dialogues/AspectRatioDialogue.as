package com.stardoll.carbondioxide.dialogues {
	import fl.controls.Button;

	import com.stardoll.carbondioxide.models.cd.CDAspectRatio;

	import org.osflash.signals.Signal;

	import flash.events.MouseEvent;

	/**
	 * @author simonrodriguez
	 */
	public class AspectRatioDialogue extends BaseDialogue {
		private var _onSelect:Signal;

		public function AspectRatioDialogue() {
			const WIDTH:int = 75 + EDGE + EDGE;
			const HEIGHT:int = 165;

			super("Align", false, true, false, true);

			addButton( 0, 	0, CDAspectRatio.TOP_LEFT);
			addButton( 25, 	0, CDAspectRatio.TOP);
			addButton( 50, 	0, CDAspectRatio.TOP_RIGHT);

			addButton( 0, 	25, CDAspectRatio.LEFT);
			addButton( 25, 	25, CDAspectRatio.CENTER);
			addButton( 50, 	25, CDAspectRatio.RIGHT);

			addButton( 0, 	50, CDAspectRatio.BOTTOM_LEFT);
			addButton( 25, 	50, CDAspectRatio.BOTTOM);
			addButton( 50, 	50, CDAspectRatio.BOTTOM_RIGHT);

			var btn:Button = new Button();
			btn.label = "None";
			btn.name = "";
			btn.x = 0;
			btn.y = 100;
			btn.width = 75;
			btn.height = 25;
			btn.addEventListener(MouseEvent.CLICK, onClick);
			container.addChild( btn );

			_onSelect = new Signal( int );

			init(WIDTH, HEIGHT);
		}

		override protected function close():void {
			_onSelect.removeAll();

			super.close();
		}

		public function get onSelect():Signal { return _onSelect; }

		private function addButton( x:Number, y:Number, id:int ):void {
			var btn:Button = new Button();
			btn.label = "";
			btn.name = id.toString();
			btn.x = x;
			btn.y = y;
			btn.width = btn.height = 25;
			btn.addEventListener(MouseEvent.CLICK, onClick);
			container.addChild( btn );
		}

		private function onClick(e:MouseEvent):void {
			var btn:Button = e.target as Button;

			_onSelect.dispatch( (btn.name == "") ? CDAspectRatio.NONE : int(btn.name) );

			close();
		}
	}
}
