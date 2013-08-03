package com.stardoll.carbondioxide.utils {
	import com.stardoll.carbondioxide.models.DataModel;
	/**
	 * @author Simon
	 */
	public class SaveLoad {
		public static function save():void {
			var obj:Object = DataModel.currentView.save();
			
			trace( JSON.stringify(obj) );
		}
	}
}
