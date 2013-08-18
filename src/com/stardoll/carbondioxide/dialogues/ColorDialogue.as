package com.stardoll.carbondioxide.dialogues {
	import fl.controls.ColorPicker;
	import fl.events.ColorPickerEvent;

	import com.stardoll.carbondioxide.models.DataModel;

	import flash.events.Event;

	/**
	 * @author simonrodriguez
	 */
	public class ColorDialogue extends BaseDialogue {
		private var _picker:ColorPicker;

		private var _color:uint;

		public function ColorDialogue() {
			const WIDTH:int = 200;
			const HEIGHT:int = 200;

			super("Select Color", false, true, false, false);

			_picker = new ColorPicker();
			_picker.addEventListener(ColorPickerEvent.CHANGE, onColor);
			_picker.addEventListener(Event.CLOSE, onClose);
			container.addChild( _picker );

			init( WIDTH, HEIGHT );
		}

		override protected function onResize( width:int, height:int ):void {
			_picker.width = width;
			_picker.height = height;
		}

		private function onColor(e:ColorPickerEvent):void {
			_color = e.color;
		}

		private function onClose(e:Event):void {
			stage.addEventListener(Event.ENTER_FRAME, onFrameSkip);
		}

		private function onFrameSkip(e:Event):void {
			stage.removeEventListener(Event.ENTER_FRAME, onFrameSkip);

			DataModel.setBGColor( _color );

			close();
		}
	}
}
