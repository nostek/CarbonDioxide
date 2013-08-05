package com.stardoll.carbondioxide.models.cd {
	import com.stardoll.carbondioxide.utils.ObjectEx;

	/**
	 * @author Simon
	 */
	public class CDText extends CDItem {
		public function CDText(parent : CDItem, name : String) {
			super(parent, name);

			text = "DEFAULT";
		}

		override public function get type():int {
			return TYPE_TEXT;
		}

		public var text:String;

		///////////////////////////////////
		// Save & Load

		private static const KEY_TEXT:String = "text";

		override public function load( version:int, data:Object ):void {
			if( version >= 1 ) {
				this.text = ObjectEx.select( data, KEY_TEXT, null );
			}

			super.load( version, data );
		}
	}
}
