package com.tbbgc.carbondioxide.dialogues {
	import fl.controls.Button;

	import com.tbbgc.carbondioxide.models.cd.CDText;

	import org.osflash.signals.Signal;

	import flash.events.MouseEvent;

	/**
	 * @author simonrodriguez
	 */
	public class TextAlignDialogue extends BaseDialogue {
		private var _onSelect:Signal;

		public function TextAlignDialogue() {
			const WIDTH:int = 250 + EDGE + EDGE;
			const HEIGHT:int = 70;

			super("Text Align", false, true, false, false);

			addButton( 0, 	0, CDText.ALIGN_LEFT);
			addButton( 85, 	0, CDText.ALIGN_CENTER);
			addButton( 170, 0, CDText.ALIGN_RIGHT);

			_onSelect = new Signal( int );

			init(WIDTH, HEIGHT);
		}

		public function get onSelect():Signal { return _onSelect; }

		private function addButton( x:Number, y:Number, id:int ):void {
			var btn:Button = new Button();
			btn.label = CDText.getAlignAsString(id);
			btn.name = id.toString();
			btn.x = x;
			btn.y = y;
			btn.width = 80;
			btn.addEventListener(MouseEvent.CLICK, onClick);
			container.addChild( btn );
		}

		private function onClick(e:MouseEvent):void {
			var btn:Button = e.target as Button;

			_onSelect.dispatch( int(btn.name) );

			close();
		}
	}
}
