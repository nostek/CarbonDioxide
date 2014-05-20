package com.stardoll.carbondioxide.managers {
	import com.stardoll.carbondioxide.components.TreeDisplay;
	import com.stardoll.carbondioxide.models.DataModel;
	import com.stardoll.carbondioxide.models.cd.CDItem;

	import flash.display.Stage;
	import flash.events.Event;
	/**
	 * @author simonrodriguez
	 */
	public class EventManager {
		private static var _list:Vector.<CDItem>;

		private static var _onView:Function;
		private static var _onTree:Function;

		private static var _selects:Array;

		public function EventManager( stage:Stage ) {
			_list = new Vector.<CDItem>();

			_onView = null;
			_onTree = null;

			_selects = null;

			stage.addEventListener(Event.EXIT_FRAME, onRun);
		}

		private static function onRun(e:Event):void {
			if( _onView != null ) {
				_list.length = 0;

				var f:Function = _onView;
				_onView = null;
				f();
			}

			if( _onTree != null ) {
				f = _onTree;
				_onTree = null;
				f();
			}

			const len:int = _list.length;
			if( len ) {
				for( var i:int = 0; i < len; i++ ) {
					DataModel.onItemChanged.dispatch( _list[i] );
				}
				_list.length = 0;
			}

			if( _selects != null ) {
				var sel:Array = _selects;
				_selects = null;

				TreeDisplay.doSelectItems.dispatch( sel );
			}
		}

		public static function add( item:CDItem ):void {
			if( _list.indexOf( item ) < 0 ) {
				_list.push( item );
			}
		}

		public static function viewChanged( cb:Function ):void {
			_onView = cb;
		}

		public static function treeChanged( cb:Function ):void {
			_onTree = cb;
		}

		public static function selectItems( list:Array ):void {
			_selects = list;
		}
	}
}
