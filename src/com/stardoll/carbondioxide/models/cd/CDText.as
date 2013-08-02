package com.stardoll.carbondioxide.models.cd {
	import com.stardoll.carbondioxide.models.cd.CDItem;

	/**
	 * @author Simon
	 */
	public class CDText extends CDItem {
		public function CDText(parent : CDItem, name : String) {
			super(parent, name);
			
			text = "DEFAULT";
		}
		
		public var text:String;
	}
}
