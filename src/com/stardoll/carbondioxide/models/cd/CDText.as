package com.stardoll.carbondioxide.models.cd {

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
	}
}
