package com.stardoll.carbondioxide.models.cd {
	/**
	 * @author simonrodriguez
	 */
	public class CDAspectRatio {
		public static const NONE:int 			= 0;
		public static const TOP_LEFT:int 		= 1;
		public static const TOP:int 			= 2;
		public static const TOP_RIGHT:int 		= 3;
		public static const LEFT:int 			= 4;
		public static const CENTER:int 			= 5;
		public static const RIGHT:int 			= 6;
		public static const BOTTOM_LEFT:int 	= 7;
		public static const BOTTOM:int 			= 8;
		public static const BOTTOM_RIGHT:int 	= 9;

		static public function toString( id:int ):String {
			switch( id ) {
				case 0:
					return "NONE";
				break;
				case 1:
					return "TOP_LEFT";
				break;
				case 2:
					return "TOP";
				break;
				case 3:
					return "TOP_RIGHT";
				break;
				case 4:
					return "LEFT";
				break;
				case 5:
					return "CENTER";
				break;
				case 6:
					return "RIGHT";
				break;
				case 7:
					return "BOTTOM_LEFT";
				break;
				case 8:
					return "BOTTOM";
				break;
				case 9:
					return "BOTTOM_RIGHT";
				break;
			}
			return null;
		}
	}
}
