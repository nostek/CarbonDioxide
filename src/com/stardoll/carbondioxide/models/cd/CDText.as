package com.stardoll.carbondioxide.models.cd {
	import flash.text.TextFormatAlign;

	/**
	 * @author Simon
	 */
	public class CDText extends CDItem {
		public static const ALIGN_LEFT:int 		= 0;
		public static const ALIGN_CENTER:int 	= 1;
		public static const ALIGN_RIGHT:int 	= 2;

		public static function getAlignAsFormat( a:int ):String {
			switch( a ) {
				case ALIGN_LEFT:
					return TextFormatAlign.LEFT;
				break;
				case ALIGN_CENTER:
					return TextFormatAlign.CENTER;
				break;
				case ALIGN_RIGHT:
					return TextFormatAlign.RIGHT;
				break;
			}
			return null;
		}

		public static function getAlignAsString( a:int ):String {
			switch( a ) {
				case ALIGN_LEFT:
					return "LEFT";
				break;
				case ALIGN_CENTER:
					return "CENTER";
				break;
				case ALIGN_RIGHT:
					return "RIGHT";
				break;
			}
			return null;
		}

		private var _text:String;
		private var _align:int;

		public function CDText(parent : CDItem, name : String) {
			super(parent, name);

			_text = "DEFAULT";
			_align = ALIGN_LEFT;
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

		public function get align():int {
			return _align;
		}

		public function set align( a:int ):void {
			_align = a;

			itemChanged();
		}
	}
}
