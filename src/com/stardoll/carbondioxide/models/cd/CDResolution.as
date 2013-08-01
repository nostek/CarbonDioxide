package com.stardoll.carbondioxide.models.cd {
	/**
	 * @author simonrodriguez
	 */
	public class CDResolution {
		private var _screenWidth:int;
		private var _screenHeight:int;

		public function CDResolution( width:int, height:int ):void {
			_screenWidth = width;
			_screenHeight = height;
		}

		public function get screenWidth():int { return _screenWidth; }
		public function get screenHeight():int { return _screenHeight; }

		//Percentages of parents width/height
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;
	}
}
