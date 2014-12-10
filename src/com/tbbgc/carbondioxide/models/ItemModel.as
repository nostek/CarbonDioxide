package com.tbbgc.carbondioxide.models {
	import com.tbbgc.carbondioxide.models.cd.CDItem;

	import flash.display.DisplayObject;
	import flash.display.Sprite;

	/**
	 * @author simonrodriguez
	 */
	public class ItemModel extends Sprite {
		private var _item:CDItem;

		public function ItemModel( item:CDItem, child:DisplayObject ) {
			super();

			_item = item;

			addChild( child );
		}

		public function get item():CDItem { return _item; }

		public function save():void {
			save_x 		= _item.x;
			save_y 		= _item.y;
			save_width 	= _item.width;
			save_height = _item.height;
			save_holder_width 	= width;
			save_holder_height 	= height;
		}

		public var save_x:Number;
		public var save_y:Number;
		public var save_width:Number;
		public var save_height:Number;

		public var save_holder_width:Number;
		public var save_holder_height:Number;

	//	public function set selected( sel:Boolean ):void {
	//		this.graphics.clear();
	//
	//		if( sel ) {
	//			with( this.graphics ) {
	//				lineStyle(2, 0x00ff00, 0.8);
	//				moveTo(0, 0);
	//				lineTo(_item.width, 0);
	//				lineTo(_item.width, _item.height);
	//				lineTo(0, _item.height);
	//				lineTo(0, 0);
	//			}
	//		}
	//	}
	}
}
