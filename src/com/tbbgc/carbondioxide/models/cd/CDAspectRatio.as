package com.tbbgc.carbondioxide.models.cd {
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

		public static const ALIGN_BOTH:int		= 0;
		public static const ALIGN_WIDTH:int		= 1;
		public static const ALIGN_HEIGHT:int	= 2;

		static public function toString( id:int ):String {
			switch( id ) {
				case 0:
					return "NONE";
				case 1:
					return "TOP_LEFT";
				case 2:
					return "TOP";
				case 3:
					return "TOP_RIGHT";
				case 4:
					return "LEFT";
				case 5:
					return "CENTER";
				case 6:
					return "RIGHT";
				case 7:
					return "BOTTOM_LEFT";
				case 8:
					return "BOTTOM";
				case 9:
					return "BOTTOM_RIGHT";
			}
			return null;
		}

		static public function toAlignString( id:int ):String {
			switch( id ) {
				case 0:
					return "BOTH";
				case 1:
					return "WIDTH";
				case 2:
					return "HEIGHT";
			}
			return null;
		}
	}
}
