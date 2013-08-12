package com.stardoll.carbondioxide.managers {
	import com.stardoll.carbondioxide.models.cd.CDItem;
	import com.stardoll.carbondioxide.models.cd.CDResolution;
	/**
	 * @author Simon
	 */
	public class UndoManager {
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
			
			_redo.length = 0;
			
			_undo.push( new UndoModel( item, res ) );
		}
		
		public static function runUndo():void {
			if( _undo.length ) {
				var model:UndoModel = _undo.pop();

				_redo.push( new UndoModel( model.item, model.res ) );				
				
				model.run();
			} 
		}
		
		public static function runRedo():void {
			if( _redo.length ) {
				var model:UndoModel = _redo.pop();
				
				_undo.push( new UndoModel( model.item, model.res ) );
				
				model.run();
			} 
		}
	}
}



import com.stardoll.carbondioxide.managers.EventManager;
import com.stardoll.carbondioxide.models.cd.CDItem;
import com.stardoll.carbondioxide.models.cd.CDResolution;



internal class UndoModel {
	public var item:CDItem;
	public var res:CDResolution;
	
	private var _x:Number;
	private var _y:Number;
	private var _w:Number;
	private var _h:Number;
	private var _a:Number;
	
	public function UndoModel( item:CDItem, res:CDResolution ):void {
		this.item = item;
		this.res = res;
		
		_x = res.x;
		_y = res.y;
		_w = res.width;
		_h = res.height;
		_a = res.aspectRatio;		
	}
	
	public function run():void {
		res.x = _x;
		res.y = _y;
		res.width = _w;
		res.height = _h;
		res.aspectRatio = _a;
		
		item.updateDisplayProperties();
		
		EventManager.add( item );
	}
}
