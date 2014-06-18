package com.stardoll.carbondioxide.models.cd {
	/**
	 * @author simonrodriguez
	 */
	public class CDResolution {
		private var _screenWidth:int;
		private var _screenHeight:int;
		private var _screenDPI:int;

		public function CDResolution( width:int, height:int, dpi:int ):void {
			_screenWidth = width;
			_screenHeight = height;
			_screenDPI = dpi;
		}

		public function get screenWidth():int { return _screenWidth; }
		public function get screenHeight():int { return _screenHeight; }
		public function get screenDPI():int { return _screenDPI; }

		//Percentages of parents width/height
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;

		//Width/Height of pixel values
		public var aspectRatio:Number;
	}
}
