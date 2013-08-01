package com.stardoll.carbondioxide.dialogues {
	import fl.controls.Button;

	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * @author simonrodriguez
	 */
	public class PopupDialogue extends BaseDialogue {
		private var _label:TextField;
		private var _button:Button;

		public function PopupDialogue( caption:String, text:String ) {
			const WIDTH:int = 300;
			const HEIGHT:int = 150;

			super(WIDTH, HEIGHT, caption, false, true, false, false);

			var fmt:TextFormat = new TextFormat("Verdana", 10, 0xffffffff, null, true, null, null, null, TextFormatAlign.CENTER);

			_label = new TextField();
			_label.autoSize = TextFieldAutoSize.LEFT;
			_label.selectable = false;
			_label.wordWrap = true;
			_label.defaultTextFormat = fmt;
			_label.text = text;
			container.addChild(_label);

			_button = new Button();
			_button.label = "OK";
			_button.addEventListener(MouseEvent.CLICK, onButton);
			container.addChild(_button);

			init(WIDTH, HEIGHT);
		}

		override protected function onResize( width:int, height:int ):void {
			_button.x = width/2 - _button.width/2;
			_button.y = height - _button.height;

			_label.width = width;
			_label.y = _button.y/2 - _label.height/2;
		}

		private function onButton(e:MouseEvent):void {
			close();
		}
	}
}
