package com.stardoll.carbondioxide.models.cd {
	import com.stardoll.carbondioxide.dialogues.PopupDialogue;
	import com.stardoll.carbondioxide.utils.ObjectEx;
	import com.stardoll.carbondioxide.models.DataModel;
	/**
	 * @author simonrodriguez
	 */
	public class CDItem {
		public static const TYPE_UNKNOWN:int 	= -1;
		public static const TYPE_VIEW:int 		= 0;
		public static const TYPE_ITEM:int 		= 1;
		public static const TYPE_TEXT:int 		= 2;
		
		///
		
		private var _parent:CDItem;

		private var _children:Vector.<CDItem>;
		private var _resolutions:Vector.<CDResolution>;

		private var _x:Number;
		private var _y:Number;
		private var _width:Number;
		private var _height:Number;

		public function CDItem( parent:CDItem, name:String ) {
			_parent = parent;

			this.name = name;

			_children = new Vector.<CDItem>();
			_resolutions = new Vector.<CDResolution>();
		}
		
		public function get type():int {
			return TYPE_ITEM;
		}

		//////////////

		public var name:String;
		
		public var asset:String;

		public var aspectRatio:int = CDAspectRatio.NONE;

		//////////////

		public function get x():int {
			return _parent.width * _x;
		}

		public function get y():int {
			return _parent.height * _y;
		}

		public function get width():int {
			return _parent.width * _width;
		}

		public function get height():int {
			return _parent.height * _height;
		}

		public function get worldX():int {
			return _parent.worldX + x;
		}

		public function get worldY():int {
			return _parent.worldY + y;
		}

		public function set x( value:int ):void {
			currentResolution.x = toPercent( value, _parent.width );

			updateDisplayProperties();
		}

		public function set y( value:int ):void {
			currentResolution.y = toPercent( value, _parent.height );

			updateDisplayProperties();
		}

		public function set width( value:int ):void {
			currentResolution.width = toPercent( value, _parent.width );

			updateDisplayProperties();
		}

		public function set height( value:int ):void {
			currentResolution.height = toPercent( value, _parent.height );

			updateDisplayProperties();
		}

		//////////////

		public function addResolution( res:CDResolution ):CDResolution {
			_resolutions.push( res );
			return res;
		}

		public function removeResolution( res:CDResolution ):CDResolution {
			const index:int = _resolutions.indexOf( res );
			if( _resolutions.length > 1 && index >= 0 ) {
				_resolutions.splice( index, 1 );
			}
			return res;
		}

		public function get currentResolution():CDResolution {
			const len:int = _resolutions.length;
			for( var i:int = 0; i < len; i++ ) {
				if( _resolutions[i].screenWidth == DataModel.SCREEN_WIDTH && _resolutions[i].screenHeight == DataModel.SCREEN_HEIGHT) {
					return _resolutions[i];
				}
			}

			return addResolution( new CDResolution(DataModel.SCREEN_WIDTH, DataModel.SCREEN_HEIGHT) );
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
			return item;
		}

		public function removeChild( item:CDItem ):CDItem {
			const index:int = _children.indexOf( item );
			if( index >= 0 ) {
				_children.splice(index, 1);
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

		public function get children():Vector.<CDItem> {
			return _children;
		}

		//////////////

		public function toString() : String {
			return "CDItem( " + x + " " + y + " " + width + " " + height + " )";
		}

		//////////////

		public static function toPercent( px:int, res:int ):Number {
			return px / res;
		}

		//////////////

		public function updateDisplayProperties():void {
			const screenWidth:int 	= DataModel.SCREEN_WIDTH;
			const screenHeight:int 	= DataModel.SCREEN_HEIGHT;

			var state:CDResolution = getInterpolatedState();

			_x = state.x;
			_y = state.y;

			_width = state.width;
			_height = state.height;

			if( aspectRatio != 0 ) {
				const sx:Number = screenWidth / state.screenWidth;
				const sy:Number = screenHeight / state.screenHeight;
				const sa:Number = (sx < sy) ? sx : sy;

				const tx:Number = state.screenWidth / screenWidth;
				const ty:Number = state.screenHeight / screenHeight;

				const oldwidth:int = width;
				const oldheight:int = height;
					_width *= tx * sa;
					_height *= ty * sa;
				const newwidth:int = width;
				const newheight:int = height;

				switch( aspectRatio ) {
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

		private function getInterpolatedState():CDResolution {
			//Check for first state
			if( _resolutions.length == 1 ) {
				return _resolutions[0];
			}

			const screenWidth:int 	= DataModel.SCREEN_WIDTH;
			const screenHeight:int 	= DataModel.SCREEN_HEIGHT;

			var state:CDResolution;

			//Check for perfect fit
			const len:int = _resolutions.length;
			for( var i:int = 0; i < len; i++ ) {
				state = _resolutions[i];

				if( state.screenWidth == screenWidth && state.screenHeight == screenHeight ) {
					return state;
				}
			}

			var finds:Array = [10000];

			const targetar:Number = screenWidth/screenHeight;

			var ar:Number;

			//Check for best
			for( i = 0; i < len; i++ ) {
				state = _resolutions[i];

				ar = state.screenWidth / state.screenHeight;

				ar = Math.abs(targetar - ar);

				if( ar < finds[0] ) {
					finds = [ ar, state ];
				} else {
					if( ar == finds[0] ) {
						finds.push( state );
					}
				}
			}

			//sort on best
			if( finds.length > 2 ) {
				var bestAr:Number = 10000;
				var bestState:CDResolution = null;

				for( i = 1; i < finds.length; i++ ) {
					ar = 	(screenWidth / (finds[i] as CDResolution).screenWidth) *
							(screenHeight / (finds[i] as CDResolution).screenHeight);

					ar = Math.abs( 1 - ar );

					if( ar < bestAr ) {
						bestState = finds[i];
						bestAr = ar;
					}
				}

				return bestState;
			}

			return finds[1];
		}
		
		///////////////////////////////////
		// Save & Load
		
		private static const KEY_TYPE:String 		= "type";
		private static const KEY_NAME:String 		= "name";
		private static const KEY_ASSET:String 		= "asset";
		private static const KEY_ASPECTRATIO:String = "ar";
		private static const KEY_RESOLUTIONS:String = "resolutions";
		private static const KEY_CHILDREN:String 	= "children";
		
		public function save():Object {
			var i:int;
			
			var data:Object = {};
			
			data[ KEY_TYPE ] = this.type;
			data[ KEY_NAME ] = this.name;
			
			if( this.asset != null ) {
				data[ KEY_ASSET ] = this.asset;
			}
			
			if( this.aspectRatio != CDAspectRatio.NONE ) {
				data[ KEY_ASPECTRATIO ] = this.aspectRatio;
			}
			
			if( _resolutions.length > 0 ) {
				var resolutions:Array = [];
				
				const rlen:int = _resolutions.length;
				for( i = 0; i < rlen; i++ ) {
					resolutions.push( _resolutions[i].save() );
				}
				
				data[ KEY_RESOLUTIONS ] = resolutions;
			}
			
			if( _children.length > 0 ) {
				var children:Array = [];
				
				const clen:int = _children.length;
				for( i = 0; i < clen; i++ ) {
					children.push( _children[i].save() );
				}
				
				data[ KEY_CHILDREN ] = children;
			}
			
			return data;
		}
		
		public function load( version:int, data:Object ):void {
			var i:int;
			
			if( version >= 1 ) {
				 this.name = ObjectEx.select(data, KEY_NAME, null);
				 
				 this.asset = ObjectEx.select(data, KEY_ASSET, null);
				 
				 this.aspectRatio = ObjectEx.select(data, KEY_ASPECTRATIO, CDAspectRatio.NONE);
				 
				 if( data[ KEY_RESOLUTIONS ] != null ) {
					const resolutions:Array = data[ KEY_RESOLUTIONS ];
					const rlen:int = resolutions.length;
					var res:CDResolution;
					for( i = 0; i < rlen; i++ ) {
						res = new CDResolution(0, 0);
						res.load(version, resolutions[i]);
						addResolution( res );
					}
				 }
				 
				 if( data[ KEY_CHILDREN ] != null ) {
					const children:Array = data[ KEY_CHILDREN ];
					const clen:int = children.length;
					var type:int;
					var item:CDItem;
					for( i = 0; i < clen; i++ ) {
						type = ObjectEx.select( children[i], KEY_TYPE, TYPE_UNKNOWN );
						
						item = null;
						
						switch( type ) {
							case TYPE_ITEM:
								item = new CDItem(this, null);
							break;
							
							case TYPE_TEXT:
								item = new CDText(this, null);
							break;
							
							default:
								new PopupDialogue("ERROR", "Unknown type: " + type.toString());
							break;
						}
						
						if( item != null ) {
							item.load(version, children[i]);
							addChild(item);
						}
					}
				 }
			}
		}
	}
}
