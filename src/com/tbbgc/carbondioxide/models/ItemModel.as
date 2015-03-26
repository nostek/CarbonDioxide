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

			isSaved = false;

			_item = item;

			addChild( child );
		}

		public function get item():CDItem { return _item; }

		public function select():void {
			isSaved = false;
		}

		public var isSaved:Boolean;

		public function save():void {
			isSaved = true;

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
	}
}
