package com.tbbgc.carbondioxide.models.cd {

	/**
	 * @author Simon
	 */
	public class CDGradient extends CDItem {
		public static const CORNER_TOP_LEFT:int 	= 0;
		public static const CORNER_TOP_RIGHT:int 	= 1;
		public static const CORNER_BOTTOM_LEFT:int 	= 2;
		public static const CORNER_BOTTOM_RIGHT:int = 3;

		private var _colors:Vector.<uint>;
		private var _alphas:Vector.<Number>;

		public function CDGradient( parent:CDItem, name:String ) {
			super( parent, name );

			_colors = new Vector.<uint>( 4, true );
			_colors[0] = 0xffff0000;
			_colors[1] = 0xff00ff00;
			_colors[2] = 0xff0000ff;
			_colors[3] = 0xffffff00;

			_alphas = new Vector.<Number>( 4, true );
			_alphas[0] = 1;
			_alphas[1] = 1;
			_alphas[2] = 1;
			_alphas[3] = 1;
		}

		override public function get type():int {
			return TYPE_GRADIENT;
		}

		public function getCornerColor( corner:int ):uint {
			return _colors[ corner ];
		}

		public function getCornerAlpha( corner:int ):Number {
			return _alphas[ corner ];
		}

		public function setCornerColor( corner:int, color:uint ):void {
			_colors[ corner ] = color;

			itemChanged( true );
		}

		public function setCornerAlpha( corner:int, alpha:Number ):void {
			_alphas[ corner ] = alpha;

			itemChanged( true );
		}

		public function get colors():Array {
			return [
				_colors[0],
				_colors[1],
				_colors[2],
				_colors[3]
			];
		}

		public function get alphas():Array {
			return [
				_alphas[0],
				_alphas[1],
				_alphas[2],
				_alphas[3]
			];
		}

		public function set colors( colors:Array ):void {
			if( colors == null ) return;

			_colors[0] = colors[0];
			_colors[1] = colors[1];
			_colors[2] = colors[2];
			_colors[3] = colors[3];

			itemChanged( true );
		}

		public function set alphas( alphas:Array ):void {
			if( alphas == null ) return;

			_alphas[0] = alphas[0];
			_alphas[1] = alphas[1];
			_alphas[2] = alphas[2];
			_alphas[3] = alphas[3];

			itemChanged( true );
		}
	}
}
