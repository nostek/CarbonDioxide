package com.stardoll.carbondioxide.dialogues {
	import fl.controls.Button;
	import fl.controls.TextInput;

	import org.osflash.signals.Signal;

	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;

	/**
	 * @author simonrodriguez
	 */
	public class InputDialogue extends BaseDialogue {
		private var _input:TextInput;
		private var _label:TextField;
		private var _button:Button;

		private var _onOK:Signal;

		public function InputDialogue( caption:String, text:String, start:String=null ) {
			const WIDTH:int = 300;
			const HEIGHT:int = 150;

			super(caption, false, true, false, false);

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

			_input = new TextInput();
			if( start != null ) _input.text = start;
			_input.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			container.addChild(_input);

			_onOK = new Signal( InputDialogue );

			init( WIDTH, HEIGHT );

			stage.focus = _input;
		}

		public function get onOK():Signal { return _onOK; }

		public function get text():String {
			return _input.text;
		}

		override protected function onResize( width:int, height:int ):void {
			_label.width = width;

			_button.x = width/2 - _button.width/2;
			_button.y = height - _button.height;

			_input.width = width;
			_input.y = _label.y + _label.height + 10;
		}

		private function onButton(e:MouseEvent):void {
			_onOK.dispatch( this );

			close();
		}

		private function onKeyUp(e:KeyboardEvent):void {
			if( e.keyCode == Keyboard.ENTER ) {
				onButton(null);
			}
			if( e.keyCode == Keyboard.ESCAPE ) {
				close();
			}
		}
	}
}
