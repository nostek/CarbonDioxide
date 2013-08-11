package com.stardoll.carbondioxide.managers {
	import com.stardoll.carbondioxide.models.DataModel;
	import com.stardoll.carbondioxide.models.cd.CDItem;
	import flash.display.Stage;
	import flash.events.Event;
	/**
	 * @author simonrodriguez
	 */
	public class EventManager {
		private static var _list:Vector.<CDItem>;

		public function EventManager( stage:Stage ) {
			_list = new Vector.<CDItem>();

			stage.addEventListener(Event.EXIT_FRAME, onRun);
		}

		private static function onRun(e:Event):void {
			const len:int = _list.length;
			if( len ) {
				for( var i:int = 0; i < len; i++ ) {
					DataModel.onItemChanged.dispatch( _list[i] );
				}
				_list.length = 0;
			}
		}

		public static function add( item:CDItem ):void {
			if( _list.indexOf( item ) < 0 ) {
				_list.push( item );
			}
		}
	}
}
