package com.tbbgc.carbondioxide.dialogues {
	import fl.controls.TextInput;

	/**
	 * @author Simon
	 */
	public class ReportDialogue extends BaseDialogue {
		private var _input:TextInput;
		
		public function ReportDialogue( text:String ) {
			const WIDTH:int = 500;
			const HEIGHT:int = 600;

			super("Report", false, false, false, true);

			_input = new TextInput();
			_input.width = WIDTH;
			_input.height = HEIGHT;
			_input.editable = true;
			_input.text = text;
			container.addChild(_input);

			init( WIDTH, HEIGHT );
		}
	}
}
