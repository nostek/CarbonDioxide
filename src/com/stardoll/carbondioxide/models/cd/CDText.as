package com.stardoll.carbondioxide.models.cd {

	/**
	 * @author Simon
	 */
	public class CDText extends CDItem {
		private var _text:String;

		public function CDText(parent : CDItem, name : String) {
			super(parent, name);

			_text = "DEFAULT";
		}

		override public function get type():int {
			return TYPE_TEXT;
		}

		public function get text():String {
			return _text;
		}

		public function set text( text:String ):void {
			_text = text;

			itemChanged();
		}
	}
}
