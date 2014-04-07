package com.stardoll.carbondioxide.models {
	import com.stardoll.carbondioxide.managers.SettingsManager;
	import com.stardoll.carbondioxide.models.cd.CDItem;
	import com.stardoll.carbondioxide.models.cd.CDView;
	import com.stardoll.carbondioxide.utils.ObjectEx;

	import org.osflash.signals.Signal;

	import flash.display.Bitmap;
	import flash.filesystem.File;
	import flash.geom.Point;
	/**
	 * @author simonrodriguez
	 */
	public class DataModel {
		[Embed(source="../../../../../assets/bg.jpg")]
		private static var _BG:Class;
		public static var BG:Bitmap;

		public function DataModel() {
			BG = new _BG();

			BG_COLOR = ObjectEx.select(SettingsManager.getItem(SettingsManager.SETTINGS_BGCOLOR), "c", BG_COLOR);
		}

		//Keys
		public static var SHIFT_KEY:Boolean = false;
		public static var ALT_KEY:Boolean = false;
		public static var COMMAND_KEY:Boolean = false;

		//File
		public static var LAST_FILE:File;
		public static var DID_LOCK:Boolean = false;

		//Position
		public static var LAYER_MOUSE:Point = new Point();

		//BG Color
		public static var BG_COLOR:uint = 0xffffff;

		//Locks
		public static var LOCK_CHILD_POSITION:Boolean 		= false;
		public static var LOCK_CHILD_SCALE:Boolean 			= false;
		public static var LOCK_CHILD_WORLD_POSITION:Boolean = false;

		public static var onBGColorChanged:Signal = new Signal();

		public static function setBGColor( color:uint ):void {
			BG_COLOR = color;

			SettingsManager.setItem(SettingsManager.SETTINGS_BGCOLOR, {c:color});

			onBGColorChanged.dispatch();
		}

		//Resolution
		private static var _SCREEN_WIDTH:int = 1024;
		private static var _SCREEN_HEIGHT:int = 768;
		private static var _SCREEN_DPI:int = 300;

		public static var onResolutionChanged:Signal = new Signal();
		public static var onChangeResolution:Signal = new Signal( String ); //Label
		public static var onSetRealSize:Signal = new Signal();

		public static function get SCREEN_WIDTH():int {
			return _SCREEN_WIDTH;
		}

		public static function get SCREEN_HEIGHT():int {
			return _SCREEN_HEIGHT;
		}

		public static function get SCREEN_DPI():int {
			return _SCREEN_DPI;
		}

		public static function setResolution( width:int, height:int, dpi:int ):void {
			_SCREEN_WIDTH = width;
			_SCREEN_HEIGHT = height;
			_SCREEN_DPI = dpi;

			if( currentView != null ) {
				currentView.updateDisplayProperties();
			}

			onResolutionChanged.dispatch();
		}

		//View
		public static var _currentView:CDView;

		public static function get currentView():CDView {
			return _currentView;
		}

		public static var onViewChanged:Signal = new Signal();

		public static function setView( view:CDView ):void {
			_currentView = view;
			_currentLayer = view;

			view.updateDisplayProperties();

			onViewChanged.dispatch();
			onLayerChanged.dispatch();
		}

		//Layer
		public static var _currentLayer:CDItem;

		public static function get currentLayer():CDItem {
			return _currentLayer;
		}

		public static var onLayerChanged:Signal = new Signal();

		public static function setLayer( item:CDItem ):void {
			_currentLayer = item;

			onLayerChanged.dispatch();
		}

		//Item
		public static var onItemChanged:Signal = new Signal( CDItem );

		//Selected
		public static var SELECTED:Vector.<ItemModel> = new Vector.<ItemModel>();

		public static var onSelectedChanged:Signal = new Signal();

		//Asset filter
		public static var onFilterAssets:Signal = new Signal( String );
	}
}
