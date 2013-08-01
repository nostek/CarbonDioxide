package com.stardoll.carbondioxide.managers {
	import com.stardoll.carbondioxide.models.cd.CDView;

	import org.osflash.signals.Signal;
	/**
	 * @author simonrodriguez
	 */
	public class ViewsManager {
		private static var _views:Vector.<CDView>;

		private static var _onViewsChanged:Signal;

		public function ViewsManager() {
			_views = new Vector.<CDView>();

			_onViewsChanged = new Signal();
		}

		public static function get onViewsChanged():Signal { return _onViewsChanged; }

		public static function get views():Vector.<CDView> { return _views; }

		public static function addView( view:CDView ):CDView {
			_views.push( view );

			_onViewsChanged.dispatch();

			return view;
		}

		public static function removeView( view:CDView ):CDView {
			const index:int = _views.indexOf( view );
			if( index >= 0 ) {
				_views.splice(index, 1);
			}

			_onViewsChanged.dispatch();

			return view;
		}

		public static function getViewByName( name:String ):CDView {
			const len:int = _views.length;
			for( var i:int = 0; i < len; i++ ) {
				if( _views[i].name == name ) {
					return _views[i];
				}
			}
			return null;
		}
	}
}
