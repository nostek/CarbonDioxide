package com.tbbgc.carbondioxide.managers {
	import com.tbbgc.carbondioxide.models.cd.CDItem;
	import com.tbbgc.carbondioxide.models.cd.CDResolution;
	/**
	 * @author Simon
	 */
	public class UndoManager {
		public static var GROUP_LAST_UNDO:Boolean = false;

		private static var _undo:Vector.<UndoModel>;
		private static var _redo:Vector.<UndoModel>;

		public function UndoManager() {
			_undo = new Vector.<UndoModel>();
			_redo = new Vector.<UndoModel>();
		}

		public static function add( item:CDItem, res:CDResolution ):void {
			if( isNaN( res.x ) ) {
				return;
			}

			if( GROUP_LAST_UNDO && _undo.length > 0 ) {
				_undo[_undo.length-1].push( new UndoModel( item, res ) );
				return;
			}

			_redo.length = 0;

			_undo.push( new UndoModel( item, res ) );
		}

		public static function runUndo():void {
			if( _undo.length ) {
				var model:UndoModel = _undo.pop();

				_redo.push( new UndoModel( model.item, model.res, model.group ) );

				model.run();
			}
		}

		public static function runRedo():void {
			if( _redo.length ) {
				var model:UndoModel = _redo.pop();

				_undo.push( new UndoModel( model.item, model.res, model.group ) );

				model.run();
			}
		}
	}
}



import com.tbbgc.carbondioxide.managers.EventManager;
import com.tbbgc.carbondioxide.models.cd.CDItem;
import com.tbbgc.carbondioxide.models.cd.CDResolution;



internal class UndoModel {
	public var item:CDItem;
	public var res:CDResolution;

	public var group:Vector.<UndoModel>;

	private var _x:Number;
	private var _y:Number;
	private var _w:Number;
	private var _h:Number;
	private var _a:Number;

	public function UndoModel( item:CDItem, res:CDResolution, group:Vector.<UndoModel> = null ):void {
		this.item = item;
		this.res = res;
		this.group = group;

		_x = res.x;
		_y = res.y;
		_w = res.width;
		_h = res.height;
		_a = res.aspectRatio;

		if( group != null ) {
			this.group = new Vector.<UndoModel>();
			const len:int = group.length;
			for( var i:int = 0; i < len; i++ ) {
				this.group.push( new UndoModel( group[i].item, group[i].res, group[i].group ) );
			}
		}
	}

	public function run():void {
		res.x = _x;
		res.y = _y;
		res.width = _w;
		res.height = _h;
		res.aspectRatio = _a;

		item.updateDisplayProperties();

		EventManager.add( item );

		if( group != null ) {
			const len:int = group.length;
			for( var i:int = 0; i < len; i++ ) {
				group[i].run();
			}
		}
	}

	public function push( model:UndoModel ):void {
		if( group == null ) {
			group = new Vector.<UndoModel>();
		}

		group.push( model );
	}
}
