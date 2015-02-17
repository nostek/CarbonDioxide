package com.tbbgc.carbondioxide.components {
	import com.tbbgc.carbondioxide.managers.EventManager;
	import com.tbbgc.carbondioxide.managers.UndoManager;
	import com.tbbgc.carbondioxide.models.DataModel;
	import com.tbbgc.carbondioxide.models.ItemModel;
	import com.tbbgc.carbondioxide.models.cd.CDGradient;
	import com.tbbgc.carbondioxide.models.cd.CDItem;
	import com.tbbgc.carbondioxide.models.cd.CDText;
	import com.tbbgc.carbondioxide.utils.Drawer;
	import com.tbbgc.carbondioxide.utils.Images;

	import org.osflash.signals.Signal;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	/**
	 * @author simonrodriguez
	 */
	public class TreeDisplay extends Sprite {
		private static var _doSelectItems:Signal;
		private static var _doZoom:Signal;

		private var _allowed:Vector.<ItemModel>;

		private var _selection:SelectionItem;

		private var _box:SelectionBox;
		private var _start:Point;

		private var _dragging:Boolean;

        private var _skipDeselect:Boolean;

		public function TreeDisplay() {
			DataModel.onResolutionChanged.add( onViewChanged );
			DataModel.onViewChanged.add( onViewChanged );
			DataModel.onLayerChanged.add( onViewChanged );
			DataModel.onItemChanged.add( onItemChanged );
			DataModel.onBGColorChanged.add( onViewChanged );
			DataModel.onSetRealSize.add( onRealViewSize );

			_doSelectItems = new Signal( Array );
			_doSelectItems.add( onSelectItems );

			_doZoom = new Signal( Number, Boolean );
			_doZoom.add( doZoom );

			_selection = new SelectionItem();
			_selection.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			_selection.addEventListener(MouseEvent.DOUBLE_CLICK, onDblClick, false, 0, true);

			_box = new SelectionBox();

			this.addEventListener(MouseEvent.CLICK, onDeselect, false, 0, true);

			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			_allowed = new Vector.<ItemModel>();

            _skipDeselect = false;

			_global = new Point();
		}

		private function onAddedToStage( e:Event ):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			stage.addEventListener(MouseEvent.MOUSE_DOWN, onContainerStart);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onContainerMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onContainerStop);

			stage.addEventListener(Event.RESIZE, onResize);

			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 9999);
		}

		public static function get doSelectItems():Signal { return _doSelectItems; }
		public static function get doZoom():Signal { return _doZoom; }

		private function onContainerStart(e:MouseEvent):void {
			if( DataModel.ALT_KEY ) {
				_dragging = true;
				this.startDrag();
				this.mouseEnabled = this.mouseChildren = false;
				return;
			} else {
				if( e.target == this ||
					e.target == stage ||
					( (e.target is ItemModel) && (!(e.target as ItemModel).item.visible || !(e.target as ItemModel).item.enabled) ) ||
					( (e.target is ItemModel) && (e.target as ItemModel).mouseChildren )
					) {
						_start = new Point( this.mouseX, this.mouseY );
				}
			}
		}

		private function onContainerMove(e:MouseEvent):void {
			if( _start != null ) {
				updateSelectionBox( false );
			}

			if( DataModel.currentLayer != null ) {
				if( DataModel.currentLayer == DataModel.currentView ) {
					DataModel.LAYER_MOUSE.x = this.mouseX;
					DataModel.LAYER_MOUSE.y = this.mouseY;
				} else {
					var xx:Number = 0;
					var yy:Number = 0;

					var l:CDItem = DataModel.currentLayer;
					while( l != DataModel.currentView ) {
						xx += l.x;
						yy += l.y;
						l = l.parent;
					}

					DataModel.LAYER_MOUSE.x = this.mouseX - xx;
					DataModel.LAYER_MOUSE.y = this.mouseY - yy;
				}
			}
		}

		private function onContainerStop(e:MouseEvent):void {
			if( _dragging ) {
				_dragging = false;
				this.stopDrag();
				this.mouseEnabled = this.mouseChildren = true;
			}

			if( _start != null ) {
				updateSelectionBox( true );
				_start = null;
                _skipDeselect = true;
			}
		}

		private function onResize(e:Event):void {
			this.x = (stage.stageWidth - DataModel.SCREEN_WIDTH*this.scaleX) >> 1;
			this.y = (stage.stageHeight - DataModel.SCREEN_HEIGHT*this.scaleY) >> 1;
		}

		private function onRealViewSize():void {
			//109 @ 2560x1440@27"
			var sdpi:Number = Math.sqrt( ((Capabilities.screenResolutionX/DataModel.COMPUTER_SCREEN_SIZE)*(Capabilities.screenResolutionX/DataModel.COMPUTER_SCREEN_SIZE)) + ((Capabilities.screenResolutionY/DataModel.COMPUTER_SCREEN_SIZE)*(Capabilities.screenResolutionY/DataModel.COMPUTER_SCREEN_SIZE)) );

			var iw:Number = DataModel.SCREEN_WIDTH/DataModel.SCREEN_DPI;
			var ih:Number = DataModel.SCREEN_HEIGHT/DataModel.SCREEN_DPI;

			iw *= sdpi;
			ih *= sdpi;

			iw /= DataModel.SCREEN_WIDTH;
			ih /= DataModel.SCREEN_HEIGHT;

			this.scaleX = iw;
			this.scaleY = ih;

			this.x = (stage.stageWidth - DataModel.SCREEN_WIDTH*this.scaleX) >> 1;
			this.y = (stage.stageHeight - DataModel.SCREEN_HEIGHT*this.scaleY) >> 1;
		}

		private function doZoom( z:Number, fromMouse:Boolean ):void {
			const X:int = stage.mouseX;
			const Y:int = stage.mouseY;

			var W:int = DataModel.SCREEN_WIDTH*this.scaleX;
			var H:int = DataModel.SCREEN_HEIGHT*this.scaleY;

			var ret:Point = new Point( X - this.x, Y - this.y );

			if( W == 0 || H == 0 ) {
				ret.x = ret.y = 0.5;
			} else {
				ret.x = ret.x / W;
				ret.y = ret.y / H;
			}

			this.scaleX = this.scaleY = z;

			onResize(null);

			if( fromMouse ) {
				W = DataModel.SCREEN_WIDTH*this.scaleX;
				H = DataModel.SCREEN_HEIGHT*this.scaleY;

				ret.x = W * ret.x;
				ret.y = H * ret.y;

				this.x = X;
				this.y = Y;

				this.x -= ret.x;
				this.y -= ret.y;
			}

            drawSelection();
		}

		private function onKeyDown(e:KeyboardEvent):void {
			if( e.target == this.stage ) {
				if( e.commandKey || e.controlKey ) return;
				const add:int = e.shiftKey ? 10 : 1;
				switch( e.keyCode ) {
					case Keyboard.UP:
						moveItem( 0, -add );
					break;
					case Keyboard.DOWN:
						moveItem( 0, add );
					break;
					case Keyboard.LEFT:
						moveItem( -add, 0 );
					break;
					case Keyboard.RIGHT:
						moveItem( add, 0 );
					break;
				}
			}
		}

		private function moveItem( xadd:int, yadd:int ):void {
			for each( var item:ItemModel in DataModel.SELECTED ) {
				item.item.setXYWH(item.item.xAsInt+xadd, item.item.yAsInt+yadd, item.item.width, item.item.height);

				if( DataModel.LOCK_CHILD_WORLD_POSITION ) {
					for( var i:int = 0; i < item.item.children.length; i++ ) {
						item.item.children[i].setXYWH(item.item.children[i].x-xadd, item.item.children[i].y-yadd, item.item.children[i].width, item.item.children[i].height);
					}
				}
			}
		}

		private function findHolder( item:CDItem ):ItemModel {
			const len:int = _allowed.length;
			for( var i:int = 0; i < len; i++ ) {
				if( _allowed[i].item == item ) {
					return _allowed[i];
				}
			}

			return null;
		}

		private function onItemChanged( item:CDItem ):void {
			if( item == DataModel.currentLayer ) {
				onViewChanged();

				return;
			}

			var holder:ItemModel = findHolder( item );
			if( holder != null ) {
				holder.visible = item.visible;

				if( !item.enabled || !item.visible ) {
					removeFromSelection(holder);
				}

				holder.x = item.x;
				holder.y = item.y;

				if( item.needsRedraw ) {
					holder.scaleX = holder.scaleY = 1;

					var d:DisplayObject = drawFromData( item );

					holder.removeChildren();

					holder.addChild( d );

					drawChildren( item, holder );
				}

				drawSelection();
			} else {
				onViewChanged();
			}
		}

		private function onViewChanged():void {
			EventManager.viewChanged( onViewChangedCB );
		}
		private function onViewChangedCB():void {
			removeChildren();

			var sel:Array = [];
			for each( var i:ItemModel in DataModel.SELECTED ) {
				sel.push( i.item );
			}

			var bg:Shape = new Shape();
			with( bg.graphics ) {
				beginFill(DataModel.BG_COLOR, 1);
				drawRect(0, 0, DataModel.SCREEN_WIDTH, DataModel.SCREEN_HEIGHT);
				endFill();
			}
			addChild(bg);

			_allowed = new Vector.<ItemModel>();

			if( DataModel.currentView != null ) {
				drawChildren( DataModel.currentView, this );
			}

			addToSelection(null);

			if( sel.length ) {
				onSelectItems( sel );
			}

			addChild( _selection );
			addChild( _box );
		}

		private function onDeselect( e:MouseEvent ):void {
			if( e.target == _selection ) return;

            if( _skipDeselect ) {
                _skipDeselect = false;
                return;
            }

			var obj:ItemModel = e.target as ItemModel;

			if( obj == null ) {
				addToSelection(null);
				return;
			}

			if( _allowed.indexOf(obj) == -1 ) {
				addToSelection(null);
			}
		}

		/////

		private function drawChildren( item:CDItem, parent:DisplayObjectContainer ):void {
			const children:Vector.<CDItem> = item.children;

			const len:int = children.length;
			for( var i:int = 0; i < len; i++ ) {
				draw( children[i], parent );
			}
		}

		private function draw( item:CDItem, parent:DisplayObjectContainer ):void {
			var d:DisplayObject = drawFromData( item );

			var s:ItemModel = new ItemModel( item, d );

			s.x = item.x;
			s.y = item.y;

			s.visible = item.visible;

			if( item.parent == DataModel.currentLayer ) {
				addEventListeners( s );
			}

			parent.addChild( s );

			drawChildren( item, s );
		}

		private function addEventListeners( item:ItemModel ):void {
			item.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);

			item.mouseChildren = false;

			_allowed.push( item );
		}

		private function drawFromData( item:CDItem ):DisplayObject {
			if( item.asset != null && Images.haveImage(item.asset) ) {
				return drawImage( item );
			}

			if( (item.asset == null || item.asset == "") ) {
				if( item is CDGradient ) {
					return drawGradient( item as CDGradient );
				}
				return drawShape( item );
			} else {
				if( item is CDText ) {
					return drawText( item as CDText );
				}
				return drawGraphics( item );
			}

			/*FDT_IGNORE*/
			return null;
			/*FDT_IGNORE*/
		}

		private function drawGradient( item:CDGradient ):DisplayObject {
			var getR:Function = function( c:uint ):int {
				return (c >> 16) & 0xFF;
			};
			var getG:Function = function( c:uint ):int {
				return (c >> 8) & 0xFF;
			};
			var getB:Function = function( c:uint ):int {
				return (c) & 0xFF;
			};
//			var interpolate:Function = function( a:int, b:int, c:int, d:int, t:Number, s:Number ):int {
//				return (a*(1-t)*(1-s) + b*t*(1-s) + c*(1-t)*s + d*t*s);
//			};

			var bm:BitmapData = new BitmapData( Math.max(1,item.width), Math.max(1,item.height), true, 0xffffffff );

			var r1:int = getR(item.getCornerColor(0));
			var r2:int = getR(item.getCornerColor(1));
			var r3:int = getR(item.getCornerColor(2));
			var r4:int = getR(item.getCornerColor(3));

			var g1:int = getG(item.getCornerColor(0));
			var g2:int = getG(item.getCornerColor(1));
			var g3:int = getG(item.getCornerColor(2));
			var g4:int = getG(item.getCornerColor(3));

			var b1:int = getB(item.getCornerColor(0));
			var b2:int = getB(item.getCornerColor(1));
			var b3:int = getB(item.getCornerColor(2));
			var b4:int = getB(item.getCornerColor(3));

			var a1:int = 255 * item.getCornerAlpha(0);
			var a2:int = 255 * item.getCornerAlpha(1);
			var a3:int = 255 * item.getCornerAlpha(2);
			var a4:int = 255 * item.getCornerAlpha(3);

			var t:Number, s:Number;
			var r:int, g:int, b:int, a:int;

			var rect:Rectangle = bm.rect;

			var data:Vector.<uint> = bm.getVector(rect);

			var i:int = 0;
			var x:int = 0;
			var y:int = 0;
			for( var c:int = data.length; c; c-- ) {
				t = x / rect.width;
				s = y / rect.height;

//				r = interpolate( r1, r2, r3, r4, t, s );
//				g = interpolate( g1, g2, g3, g4, t, s );
//				b = interpolate( b1, b2, b3, b4, t, s );
//				a = interpolate( a1, a2, a3, a4, t, s );

				r = (r1*(1-t)*(1-s) + r2*t*(1-s) + r3*(1-t)*s + r4*t*s);
				g = (g1*(1-t)*(1-s) + g2*t*(1-s) + g3*(1-t)*s + g4*t*s);
				b = (b1*(1-t)*(1-s) + b2*t*(1-s) + b3*(1-t)*s + b4*t*s);
				a = (a1*(1-t)*(1-s) + a2*t*(1-s) + a3*(1-t)*s + a4*t*s);

				data[i] = a << 24 | r << 16 | g << 8 | b;

				x++;
				if( x == rect.width ) {
					y++;
					x = 0;
				}

				i++;
			}

			bm.setVector(rect, data);

			return new Bitmap( bm );
		}

		private function drawImage( item:CDItem ):DisplayObject {
			var s:Sprite = new Sprite();

			var bm:Bitmap = new Bitmap( Images.getImage(item.asset) );
			bm.width = item.width;
			bm.height = item.height;
			s.addChild(bm);

			return s;
		}

		private function drawShape( item:CDItem, error:Boolean=false ):DisplayObject {
			var s:Shape = new Shape();

			var alpha:Number = 0.5;
			var color:uint = 0xff0000;

			if( !error ) {
				color = item.color;
				alpha = item.alpha;
			}

			with( s.graphics ) {
				beginFill(color, alpha);
				drawRect(0, 0, item.width, item.height);
				endFill();
			}

			return s;
		}

		private function drawGraphics( item:CDItem ):DisplayObject {
			if( !Drawer.haveFrame(item.asset) ){
				return drawShape( item, true);
			}

			return new Bitmap( Drawer.draw( item.asset, Math.max(1,item.width), Math.max(1,item.height) ) );
		}

		private function drawText( item:CDText ):DisplayObject {
			if( !Drawer.haveFrame(item.asset) ){
				return drawShape( item, true);
			}

			var fmt:TextFormat = new TextFormat( null, null, null, null, null, null, null, null, CDText.getAlignAsFormat(item.align) );

			return new Bitmap( Drawer.drawText( item.text, item.asset, item.height, item.width, fmt ) );
		}

		////////////

		private static const PZERO:Point = new Point();

		private function onSelectItems( items:Array ):void {
			addToSelection(null);

			const alen:int = _allowed.length;
			var i:int;

			var find:Function = function( item:CDItem ):ItemModel {
				for( i = 0; i < alen; i++ ) {
					if( _allowed[i].item == item ) {
						return _allowed[i];
					}
				}
				return null;
			};

			var ret:ItemModel;

			for each( var item:CDItem in items ) {
				ret = find( item );
				if( ret != null ) {
					addToSelection( ret, true );
				}
			}
		}

		private function onClick( e:MouseEvent ):void {
			stage.focus = null;

			const model:ItemModel = e.target as ItemModel;

			if( model == null || !model.item.visible || !model.item.enabled ) {
				return;
			}

			addToSelection( model, e.shiftKey );

			e.stopPropagation();
		}

		private function updateSelectionBox( end:Boolean ):void {
			const cx:int = this.mouseX;
			const cy:int = this.mouseY;

			var box:Rectangle = new Rectangle();
			box.x = Math.min( cx, _start.x );
			box.y = Math.min( cy, _start.y );
			box.width = Math.max( cx, _start.x ) - box.x;
			box.height = Math.max( cy, _start.y ) - box.y;

			_box.rect = end ? null : box;

			addToSelection(null);

			var item:ItemModel;
			var rect:Rectangle;
			var pt:Point;

			for each( item in _allowed ) {
				if( item != null && item.item.enabled && item.item.visible ) {
					pt = this.globalToLocal(item.localToGlobal(PZERO));
					rect = new Rectangle( pt.x, pt.y, item.item.width, item.item.height );

					if( box.intersects( rect ) ) {
						addToSelection(item, true);
					}
				}
			}
		}

		private function addToSelection( item:ItemModel, addToList:Boolean=false ):void {
			if( item != null ) {
				if( addToList ) {
					DataModel.SELECTED.push( item );
				} else {
					DataModel.SELECTED = Vector.<ItemModel>([ item ]);
				}
			} else {
				DataModel.SELECTED = new Vector.<ItemModel>();
			}

			drawSelection();

			DataModel.onSelectedChanged.dispatch();
		}

		private function removeFromSelection( item:ItemModel ):void {
			const index:int = DataModel.SELECTED.indexOf( item );

			if( index >= 0 ) {
				DataModel.SELECTED.splice( index, 1 );

				drawSelection();

				DataModel.onSelectedChanged.dispatch();
			}
		}

		private function drawSelection():void {
			var item:ItemModel;
			var rect:Rectangle;
			var pt:Point;

			for each( item in DataModel.SELECTED ) {
				if( item != null ) {
					pt = this.globalToLocal(item.localToGlobal(PZERO));
					if( rect == null ) {
						rect = new Rectangle( pt.x, pt.y, item.item.width, item.item.height );
					} else {
						rect = rect.union( new Rectangle( pt.x, pt.y, item.item.width, item.item.height ) );
					}
				}
			}

			_selection.rect = rect;
		}

		////////////

		private static const DIR_NONE:int 		= 0;
		private static const DIR_HORIZONTAL:int = 1;
		private static const DIR_VERTICAL:int 	= 2;

		private var _global:Point;
		private var _state:uint;
		private var _ascale:Boolean;
		private var _mdir:int;

		private function onDblClick( e:MouseEvent ):void {
			if( DataModel.SELECTED.length == 1 ) {
				DataModel.setLayer( DataModel.SELECTED[0].item );
			}
		}

		private function onMouseDown( e:MouseEvent ):void {
			if( DataModel.ALT_KEY ) {
				return;
			}

			for each( var d:ItemModel in DataModel.SELECTED ) {
				if( d != null ) {
					d.save();
				}
			}

			_selection.save();

			_global.x = e.stageX;
			_global.y = e.stageY;

			_state = 0;

			_ascale = DataModel.SHIFT_KEY;

			_mdir = DIR_NONE;

			_state = _selection.state;

			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
		}

		private function onMouseMove( e:MouseEvent ):void {
			var diffx:int = (e.stageX - _global.x) * (1/this.scaleX);
			var diffy:int = (e.stageY - _global.y) * (1/this.scaleY);

			if( _state == SelectionItem.STATE_MOVE ) {
				if( DataModel.SHIFT_KEY && _mdir == DIR_NONE ) {
					_mdir = ( Math.abs(diffx) > Math.abs(diffy) ) ? DIR_HORIZONTAL : DIR_VERTICAL;
				}

				if( _mdir == DIR_HORIZONTAL ) {
					diffy = 0;
				}
				if( _mdir == DIR_VERTICAL ) {
					diffx = 0;
				}

				_selection.x = _selection.save_x + diffx;
				_selection.y = _selection.save_y + diffy;
			}

			if( _ascale ) {
				diffx = diffy = Math.min( diffx, diffy );
			}

			if( _state & SelectionItem.STATE_LEFT ) {
				_selection.x = _selection.save_x + diffx;
				_selection.rwidth = _selection.save_width - diffx;
			}
			if( _state & SelectionItem.STATE_TOP ) {
				_selection.y = _selection.save_y + diffy;
				_selection.rheight = _selection.save_height - diffy;
			}
			if( _state & SelectionItem.STATE_RIGHT ) {
				_selection.rwidth = _selection.save_width + diffx;
			}
			if( _state & SelectionItem.STATE_BOTTOM ) {
				_selection.rheight = _selection.save_height + diffy;
			}

			_selection.rwidth = Math.max( 0, _selection.rwidth );
			_selection.rheight = Math.max( 0, _selection.rheight );

			_selection.update();

			updateSelection( false );
		}

		private function onMouseUp( e:MouseEvent ):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			_selection.update();

			updateSelection( true );

			stage.focus = null;
		}

		private function updateSelection( setValues:Boolean ):void {
			var deltaX:int 		= _selection.x - _selection.save_x;
			var deltaY:int 		= _selection.y - _selection.save_y;
			var deltaWidth:int 	= _selection.rwidth - _selection.save_width;
			var deltaHeight:int = _selection.rheight - _selection.save_height;

			if( deltaX == 0 && deltaY == 0 && deltaWidth == 0 && deltaHeight == 0 ) return;

			var item:CDItem;

			var children:Vector.<Rectangle>;

			for each( var d:ItemModel in DataModel.SELECTED ) {
				if( d != null ) {
					item = d.item;

					if( setValues ) {
						const currX:int = item.xAsInt;
						const currY:int = item.yAsInt;
						const currW:int = item.width;
						const currH:int = item.height;

						if( DataModel.LOCK_CHILD_POSITION || DataModel.LOCK_CHILD_SCALE || DataModel.LOCK_CHILD_WORLD_POSITION ) {
							children = new Vector.<Rectangle>(item.children.length, true);

							for( var i:int = 0; i < children.length; i++ ) {
								children[i] 		= new Rectangle();
								children[i].x 		= item.children[i].x;
								children[i].y 		= item.children[i].y;
								children[i].width 	= item.children[i].width;
								children[i].height 	= item.children[i].height;
							}
						}

						item.setXYWH(
							currX + deltaX,
							currY + deltaY,
							Math.max( 0, currW + deltaWidth ),
							Math.max( 0, currH + deltaHeight )
						);

						if( DataModel.LOCK_CHILD_POSITION || DataModel.LOCK_CHILD_SCALE || DataModel.LOCK_CHILD_WORLD_POSITION ) {
							UndoManager.GROUP_LAST_UNDO = true;

							for( i = 0; i < children.length; i++ ) {
								if( !DataModel.LOCK_CHILD_POSITION ) {
									children[i].x 		= item.children[i].x;
									children[i].y 		= item.children[i].y;
								}
								if( !DataModel.LOCK_CHILD_SCALE ) {
									children[i].width 	= item.children[i].width;
									children[i].height 	= item.children[i].height;
								}
								if( DataModel.LOCK_CHILD_WORLD_POSITION ) {
									children[i].x 		-= deltaX;
									children[i].y 		-= deltaY;
								}

								item.children[i].setXYWH(children[i].x, children[i].y, children[i].width, children[i].height);
							}

							UndoManager.GROUP_LAST_UNDO = false;
						}
					} else {
						d.x = item.x + deltaX;
						d.y = item.y + deltaY;
						d.width = d.save_holder_width + deltaWidth;
						d.height = d.save_holder_height + deltaHeight;

						d.width = Math.max( 0, d.width );
						d.height = Math.max( 0, d.height );
					}
				}
			}
		}
	}
}



import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;



internal class SelectionItem extends Sprite {
	public static const SCALE_BORDER:int = 5;

	public static const STATE_MOVE:uint 	= 1 << 1;
	public static const STATE_LEFT:uint 	= 1 << 2;
	public static const STATE_RIGHT:uint 	= 1 << 3;
	public static const STATE_TOP:uint 		= 1 << 4;
	public static const STATE_BOTTOM:uint 	= 1 << 5;

	private var _stageX:int;
	private var _stageY:int;

	private var _bounds:Rectangle;

	public var rwidth:int;
	public var rheight:int;

	public var state:uint;

	public function SelectionItem() {
		this.buttonMode = true;
		this.doubleClickEnabled = true;

		_stageX = _stageY = -1;

		_bounds = new Rectangle();

		this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
	}

	public function save():void {
		save_x 		= x;
		save_y 		= y;
		save_width 	= rwidth;
		save_height = rheight;
	}

	public var save_x:Number;
	public var save_y:Number;
	public var save_width:Number;
	public var save_height:Number;

	public function set rect( rect:Rectangle ):void {
		this.graphics.clear();

        rwidth = rheight = 0;

		if( rect == null ) {
			return;
		}

		this.x = rect.x;
		this.y = rect.y;

		draw( rect.width, rect.height);
	}

	public function update():void {
		draw( rwidth, rheight );
	}

	private function onMouseMove( e:MouseEvent ):void {
		_bounds = this.getBounds(this.stage);

		_stageX = e.stageX - _bounds.x;
		_stageY = e.stageY - _bounds.y;

		draw( rwidth, rheight );
	}

	private function onMouseOut( e:MouseEvent ):void {
		_bounds = this.getBounds(this.stage);

		_stageX = _stageY = -1;

		draw( rwidth, rheight );
	}

	private function draw( width:int, height:int ):void {
		this.graphics.clear();

		rwidth = width;
		rheight = height;

		state = 0;

		with( this.graphics ) {
			beginFill(0x000000, 0.1);
			drawRect(0, 0, width, height);
			endFill();

			lineStyle(1, 0x00ff00, 0.8, false, "none");
			drawRect(0,0,width,height);

			lineStyle(1, 0xff0000, 0.8, false, "none");

			if( !(_stageX == -1 && _stageY == -1) ) {
				if( _stageX <= SelectionItem.SCALE_BORDER ) {
					moveTo(0, 0);
					lineTo(0, height);
					state |= STATE_LEFT;
				}
				if( _stageY <= SelectionItem.SCALE_BORDER ) {
					moveTo(0, 0);
					lineTo(width, 0);
					state |= STATE_TOP;
				}
				if( _stageX >= _bounds.width-SelectionItem.SCALE_BORDER ) {
					moveTo(width, 0);
					lineTo(width, height);
					state |= STATE_RIGHT;
				}
				if( _stageY >= _bounds.height-SelectionItem.SCALE_BORDER ) {
					moveTo(0, height);
					lineTo(width, height);
					state |= STATE_BOTTOM;
				}

				if( state == 0 && _stageX >= 0 && _stageY >= 0 && _stageX <= _bounds.width && _stageY <= _bounds.height ) {
					state |= STATE_MOVE;
				}
			}
		}

        this.scaleX = this.scaleY = 1;
	}
}



internal class SelectionBox extends Sprite {
	private var _width:int;
	private var _height:int;

	public function SelectionBox() {
		this.mouseEnabled = this.mouseChildren = false;
	}

	public function set rect( rect:Rectangle ):void {
		this.graphics.clear();

		this.scaleX = this.scaleY = 1;

		if( rect == null ) {
			return;
		}

		this.x = rect.x;
		this.y = rect.y;

		draw( rect.width, rect.height);
	}

	private function draw( width:int, height:int ):void {
		this.graphics.clear();

		_width = width;
		_height = height;

		with( this.graphics ) {
			beginFill(0x000000, 0.1);
			drawRect(0, 0, width, height);
			endFill();

			lineStyle(1, 0x00ff00, 0.8, false, "none");
			drawRect(0,0,width,height);
		}
	}
}
