package com.stardoll.carbondioxide.models.cd {
	import com.stardoll.carbondioxide.utils.ObjectEx;
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
		
		///////////////////////////////////
		// Save & Load
		
		public function save():Object {
			return {
				screenWidth: 	_screenWidth,
				screenHeight: 	_screenHeight,
				
				x:	this.x,
				y: 	this.y,
				w:	this.width,
				h: 	this.height
			};
		}
		
		public function load( version:int, data:Object):void {
			if( version >= 1 ) {
				_screenWidth 	= ObjectEx.select(data, "screenWidth", 0);
				_screenHeight 	= ObjectEx.select(data, "screenHeight", 0);
				
				this.x 		= ObjectEx.select(data, "x", 0);
				this.y 		= ObjectEx.select(data, "y", 0);
				this.width 	= ObjectEx.select(data, "w", 0);
				this.height = ObjectEx.select(data, "h", 0);
			}
		}
	}
}
