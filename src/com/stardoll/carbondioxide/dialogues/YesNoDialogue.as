package com.stardoll.carbondioxide.dialogues {
	import fl.controls.Button;

	import org.osflash.signals.Signal;

	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * @author simonrodriguez
	 */
	public class YesNoDialogue extends BaseDialogue {
		private var _label:TextField;
		private var _yes:Button;
		private var _no:Button;

		private var _onYes:Signal;
		private var _onNo:Signal;

		public function YesNoDialogue( caption:String, text:String ) {
			const WIDTH:int = 300;
			const HEIGHT:int = 150;

			super(caption, false, true, false, false);

			var fmt:TextFormat = new TextFormat("Verdana", 10, 0xffffffff, null, true, null, null, null, TextFormatAlign.CENTER);

			_onYes = new Signal();
			_onNo = new Signal();

			_label = new TextField();
			_label.autoSize = TextFieldAutoSize.LEFT;
			_label.selectable = false;
			_label.wordWrap = true;
			_label.defaultTextFormat = fmt;
			_label.text = text;
			container.addChild(_label);

			_yes = new Button();
			_yes.label = "YES";
			_yes.addEventListener(MouseEvent.CLICK, onButtonYes);
			container.addChild(_yes);

			_no = new Button();
			_no.label = "NO";
			_no.addEventListener(MouseEvent.CLICK, onButtonNo);
			container.addChild(_no);

			init(WIDTH, HEIGHT);
		}

		public function get onYes():Signal { return _onYes; }
		public function get onNo():Signal { return _onNo; }

		override protected function onResize( width:int, height:int ):void {
			_yes.x = 10;
			_no.x = width - _no.width - 10;
			_yes.y = _no.y = height - _yes.height;

			_label.width = width;
			_label.y = _yes.y/2 - _label.height/2;
		}

		private function onButtonYes(e:MouseEvent):void {
			_onYes.dispatch();
			close();
		}

		private function onButtonNo(e:MouseEvent):void {
			_onNo.dispatch();
			close();
		}
	}
}
