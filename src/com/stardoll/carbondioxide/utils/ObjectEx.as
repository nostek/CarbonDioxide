package com.stardoll.carbondioxide.utils {
	/**
	 * @author Simon
	 */
	public class ObjectEx {
		public static function select( data:Object, key:String, _def:*):* {
			if( data[key] != null ) {
				return data[key];
			}
			return _def;
		}
	}
}
