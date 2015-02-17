package com.tbbgc.carbondioxide.models.cd {
	import com.tbbgc.carbondioxide.models.resolutions.ResolutionsModel;
	import com.tbbgc.carbondioxide.managers.EventManager;
	import com.tbbgc.carbondioxide.managers.UndoManager;
	import com.tbbgc.carbondioxide.models.DataModel;
	/**
	 * @author simonrodriguez
	 */
	public class CDItem {
		public static const TYPE_UNKNOWN:int 	= -1;
		public static const TYPE_VIEW:int 		= 0;
		public static const TYPE_ITEM:int 		= 1;
		public static const TYPE_TEXT:int 		= 2;
		public static const TYPE_GRADIENT:int 	= 3;

		public static const DEFAULT_COLOR:uint 	 = 0x000000;
		public static const DEFAULT_ALPHA:Number = 0.5;

		///

		private var _parent:CDItem;

		private var _children:Vector.<CDItem>;
		private var _resolutions:Vector.<CDResolution>;

		private var _x:Number;
		private var _y:Number;
		private var _width:Number;
		private var _height:Number;
		private var _ar:Number;

		private var _name:String;
		private var _asset:String;
		private var _aspectRatioAlign:int;
		private var _aspectRatioType:int;

		private var _note:String;

		private var _needsRedraw:Boolean;
		private var _enabled:Boolean;
		private var _visible:Boolean;

		private var _color:uint;
		private var _alpha:Number;

		public function CDItem( parent:CDItem, name:String ) {
			_parent = parent;

			_name = name;

			_note = null;

			_color = DEFAULT_COLOR;
			_alpha = DEFAULT_ALPHA;

			_aspectRatioAlign = CDAspectRatio.NONE;
			_aspectRatioType = CDAspectRatio.ALIGN_BOTH;

			_needsRedraw = false;
			_enabled = _visible = true;

			_children = new Vector.<CDItem>();
			_resolutions = new Vector.<CDResolution>();
		}

		public function get type():int {
			return TYPE_ITEM;
		}

		public function get needsRedraw():Boolean {
			return _needsRedraw;
		}

		protected function itemChanged( needsRedraw:Boolean ):void {
			_needsRedraw = needsRedraw;
			EventManager.add( this );
		}

		protected function saveUndo():void {
			UndoManager.add( this, currentResolution );
		}

		//////////////

		public function get name():String {
			return _name;
		}

		public function set name( name:String ):void {
			_name = name;

			itemChanged( false );
		}

		public function get asset():String {
			return _asset;
		}

		public function set asset( asset:String ):void {
			_asset = asset;

			itemChanged( true );
		}

		public function get aspectRatioAlign():int {
			return _aspectRatioAlign;
		}

		public function set aspectRatioAlign( ar:int ):void {
			_aspectRatioAlign = ar;

			updateDisplayProperties();

			itemChanged( true );
		}

		public function get aspectRatioType():int {
			return _aspectRatioType;
		}

		public function set aspectRatioType( t:int ):void {
			_aspectRatioType = t;

			updateDisplayProperties();

			itemChanged( true );
		}

		public function get note():String {
			return _note;
		}

		public function set note( note:String ):void {
			_note = note;

			itemChanged( false );
		}

		//////////////

		public function get enabled():Boolean {
			return _enabled;
		}

		public function set enabled( value:Boolean ):void {
			_enabled = value;

			itemChanged( false );
		}

		public function get visible():Boolean {
			return _visible;
		}

		public function set visible( value:Boolean ):void {
			_visible = value;

			itemChanged( false );
		}

		public function set color( value:uint ):void {
			_color = value;

			itemChanged( true );
		}

		public function get color():uint {
			return _color;
		}

		public function set alpha( value:Number ):void {
			_alpha = value;

			itemChanged( true );
		}

		public function get alpha():Number {
			return _alpha;
		}

		//////////////

		public function get x():Number {
			return _parent.width * _x;
		}

		public function get y():Number {
			return _parent.height * _y;
		}

		public function get width():Number {
			return _parent.width * _width;
		}

		public function get height():Number {
			return _parent.height * _height;
		}

		public function get worldX():int {
			return _parent.worldX + xAsInt;
		}

		public function get worldY():int  {
			return _parent.worldY + yAsInt;
		}

		public function get xAsInt():int {
			return Math.round(_parent.width * _x);
		}

		public function get yAsInt():int {
			return Math.round(_parent.height * _y);
		}

		public function get widthAsInt():int {
			return Math.round(_parent.width * _width);
		}

		public function get heightAsInt():int {
			return Math.round(_parent.height * _height);
		}

		public function get aspectRatio():Number {
			return widthAsInt / heightAsInt;
		}

		public function setXYWH( x:int, y:int, width:int, height:int ):void {
			saveUndo();

			var needsRedraw:Boolean = (width != widthAsInt || height != heightAsInt);

			var res:CDResolution 	= currentResolution;
			res.x 					= toPercent( x, _parent.width );
			res.y 					= toPercent( y, _parent.height );
			res.width 				= toPercent( width, _parent.width );
			res.height 				= toPercent( height, _parent.height );
			res.aspectRatio 		= width / height;

			updateDisplayProperties();

			itemChanged( needsRedraw );
		}

		public function set x( value:Number ):void {
			setXYWH( int(value), this.y, this.width, this.height );
		}

		public function set y( value:Number ):void {
			setXYWH( this.x, int(value), this.width, this.height );
		}

		public function set width( value:Number ):void {
			setXYWH( this.x, this.y, int(value), this.height );
		}

		public function set height( value:Number ):void {
			setXYWH( this.x, this.y, this.width, int(value) );
		}

		//////////////

		public function addResolution( res:CDResolution ):CDResolution {
			_resolutions.push( res );

			itemChanged( true );

			return res;
		}

		public function removeResolution( res:CDResolution ):CDResolution {
			const index:int = _resolutions.indexOf( res );
			if( _resolutions.length > 1 && index >= 0 ) {
				_resolutions.splice( index, 1 );

				itemChanged( true );
			}
			return res;
		}

		public function get currentResolution():CDResolution {
			const len:int = _resolutions.length;
			for( var i:int = 0; i < len; i++ ) {
				if( _resolutions[i].screenWidth == DataModel.SCREEN_WIDTH &&
					_resolutions[i].screenHeight == DataModel.SCREEN_HEIGHT &&
					_resolutions[i].screenDPI == DataModel.SCREEN_DPI ) {
						return _resolutions[i];
				}
			}

			var res:CDResolution = new CDResolution(DataModel.SCREEN_WIDTH, DataModel.SCREEN_HEIGHT, DataModel.SCREEN_DPI);
			res.x = _x;
			res.y = _y;
			res.width = _width;
			res.height = _height;
			res.aspectRatio = _ar;

			return addResolution( res );
		}

		public function get resolutions():Vector.<CDResolution> {
			return _resolutions;
		}

		//////////////

		public function get parent():CDItem {
			return _parent;
		}

		public function addChild( item:CDItem ):CDItem {
			_children.push( item );

			itemChanged( true );

			return item;
		}

		public function removeChild( item:CDItem ):CDItem {
			const index:int = _children.indexOf( item );
			if( index >= 0 ) {
				_children.splice(index, 1);

				itemChanged( true );
			}
			return item;
		}

		public function getChildByName( name:String ):CDItem {
			const len:int = _children.length;
			for( var i:int = 0; i < len; i++ ) {
				if( _children[i].name == name ) {
					return _children[i];
				}
			}
			return null;
		}

		public function setChildIndex( item:CDItem, index:int ):void {
			if( index < 0 ) return;
			if( index > _children.length ) return;

			var current:int = _children.indexOf( item );

			if( current == index ) return;

			_children.splice(current, 1);
			_children.splice(index, 0, item);

			itemChanged( true );
		}

		public function getChildIndex( item:CDItem ):int {
			return _children.indexOf( item );
		}

		public function get children():Vector.<CDItem> {
			return _children;
		}

		//////////////

		public function toString() : String {
			return "CDItem( " + x + " " + y + " " + width + " " + height + " )";
		}

		public function get path() : String {
			var ret:String = "";

			var item:CDItem = this;

			while( !(item is CDView) ) {
				if( (item.parent is CDView) ) {
					ret = item.name + ret;
				} else {
					ret = "/" + item.name + ret;
				}

				item = item.parent;
			}

			return ret;
		}

		//////////////

		public static function toPercent( px:Number, res:Number ):Number {
			return px / res;
		}

		//////////////

		public function updateDisplayProperties():void {
			if( _resolutions.length == 0 ) return; //For loading only

			var state:CDResolution = getInterpolatedState();

			_x = state.x;
			_y = state.y;

			_width = state.width;
			_height = state.height;

			_ar = state.aspectRatio;

			if( _aspectRatioAlign != 0 ) {
				const oldwidth:Number 	= width;
				const oldheight:Number 	= height;

				var newwidth:Number 	= oldheight * state.aspectRatio;
				var newheight:Number 	= oldheight;

				var sa:Number;
				if( _aspectRatioType == CDAspectRatio.ALIGN_BOTH ) {
					sa = Math.min( oldwidth/newwidth, oldheight/newheight );
				} else {
					sa = (_aspectRatioType == CDAspectRatio.ALIGN_WIDTH) ? oldwidth/newwidth : oldheight/newheight;
				}
				newwidth  *= sa;
				newheight *= sa;

				if( newwidth > oldwidth ) newwidth = oldwidth;
				if( newheight > oldheight ) newheight = oldheight;

				_width 	= toPercent( newwidth, _parent.width );
				_height = toPercent( newheight, _parent.height );

				switch( _aspectRatioAlign ) {
					case CDAspectRatio.TOP_LEFT:
						//Nothing
					break;

					case CDAspectRatio.TOP:
						_x = toPercent(x+((oldwidth-newwidth) >> 1), _parent.width);
					break;

					case CDAspectRatio.TOP_RIGHT:
						_x = toPercent(x+(oldwidth-newwidth), _parent.width);
					break;

					case CDAspectRatio.LEFT:
						_y = toPercent(y+((oldheight-newheight) >> 1), _parent.height);
					break;

					case CDAspectRatio.CENTER:
						_x = toPercent(x+((oldwidth-newwidth) >> 1), _parent.width);
						_y = toPercent(y+((oldheight-newheight) >> 1), _parent.height);
					break;

					case CDAspectRatio.RIGHT:
						_x = toPercent(x+(oldwidth-newwidth), _parent.width);
						_y = toPercent(y+((oldheight-newheight) >> 1), _parent.height);
					break;

					case CDAspectRatio.BOTTOM_LEFT:
						_y = toPercent(y+(oldheight-newheight), _parent.height);
					break;

					case CDAspectRatio.BOTTOM:
						_x = toPercent(x+((oldwidth-newwidth) >> 1), _parent.width);
						_y = toPercent(y+(oldheight-newheight), _parent.height);
					break;

					case CDAspectRatio.BOTTOM_RIGHT:
						_x = toPercent(x+(oldwidth-newwidth), _parent.width);
						_y = toPercent(y+(oldheight-newheight), _parent.height);
					break;

					default:break;
				}
			}

			trace( "CDItem", name, x, y, width, height );

			const len:int = _children.length;
			for( var i:int = 0; i < len; i++ ) {
				_children[i].updateDisplayProperties();
			}
		}

		private static const TABLET_SIZE:Number = 6.9; //7" but 6.9 for rounding errors.

		private function getInterpolatedState():CDResolution {
			//Check for single state
			if( _resolutions.length == 1 ) {
				return _resolutions[0];
			}

			const screenWidth:int 	= DataModel.SCREEN_WIDTH;
			const screenHeight:int 	= DataModel.SCREEN_HEIGHT;
			const screenDPI:int		= DataModel.SCREEN_DPI;

			var state:CDResolution;

			//Check for perfect fit
			const len:int = _resolutions.length;
			for( var i:int = 0; i < len; i++ ) {
				state = _resolutions[i];

				if( state.screenWidth == screenWidth && state.screenHeight == screenHeight && state.screenDPI == screenDPI ) {
					return state;
				}
			}

			//Sort.
			const screenSize:Number = ResolutionsModel.getScreenSize(screenWidth, screenHeight, screenDPI);
			const screenLandscape:Boolean = screenWidth > screenHeight;

			var s:Vector.<SortResolutionModel> = new Vector.<SortResolutionModel>();
			var m:SortResolutionModel;

			for( i = 0; i < len; i++ ) {
				state = _resolutions[i];

				m = new SortResolutionModel();
				m.model = state;

				m.screenWidth 	= state.screenWidth;
				m.screenHeight 	= state.screenHeight;
				m.screenSize	= ResolutionsModel.getScreenSize(m.screenWidth, m.screenHeight, state.screenDPI);

				m.screenSizeDiff = Math.abs( m.screenSize - screenSize );

				s[ s.length ] = m;
			}

			s = s.sort(sortScreenSize);

			if( s.length == 1 ) {
				return s[0].model;
			}

			s = filterOrientation( screenLandscape, s );

			if( s.length == 1 ) {
				return s[0].model;
			}

			s = filterDevice( screenSize >= TABLET_SIZE, s );

			return s[0].model;
		}

		private static function filterDevice( isTablet:Boolean, s:Vector.<SortResolutionModel> ):Vector.<SortResolutionModel> {
			var ret:Vector.<SortResolutionModel> = new Vector.<SortResolutionModel>();

			const len:int = s.length;
			for( var i:int = 0; i < len; i++ ) {
				if( Boolean(s[i].screenSize >= TABLET_SIZE) == isTablet ) {
					ret[ ret.length ] = s[i];
				}
			}

			return (ret.length > 0) ? ret : s;
		}

		private static function filterOrientation( isLandscape:Boolean, s:Vector.<SortResolutionModel> ):Vector.<SortResolutionModel> {
			var ret:Vector.<SortResolutionModel> = new Vector.<SortResolutionModel>();

			const len:int = s.length;
			for( var i:int = 0; i < len; i++ ) {
				if( Boolean(s[i].screenWidth > s[i].screenHeight) == isLandscape ) {
					ret[ ret.length ] = s[i];
				}
			}

			return (ret.length > 0) ? ret : s;
		}

		private static function sortScreenSize( a:SortResolutionModel, b:SortResolutionModel ):int {
			if( a.screenSizeDiff == b.screenSizeDiff ) return 0;
			return ( a.screenSizeDiff > b.screenSizeDiff ) ? 1 : -1;
		}
	}
}



import com.tbbgc.carbondioxide.models.cd.CDResolution;



internal final class SortResolutionModel {
	public var screenWidth:int;
	public var screenHeight:int;
	public var screenSize:Number;

	public var screenSizeDiff:Number;

	public var model:CDResolution;
}
