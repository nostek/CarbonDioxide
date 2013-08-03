package com.stardoll.carbondioxide.components {
	import com.stardoll.carbondioxide.models.cd.CDText;
	import com.stardoll.carbondioxide.models.DataModel;
	import com.stardoll.carbondioxide.models.ItemModel;
	import com.stardoll.carbondioxide.models.cd.CDItem;
	import com.stardoll.carbondioxide.utils.Drawer;

	import org.osflash.signals.Signal;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author simonrodriguez
	 */
	public class TreeDisplay extends Sprite {
		private static var _doSelectItems:Signal;
		private static var _doZoom:Signal;

		private var _selection:SelectionItem;

		private var _allowed:Vector.<ItemModel>;

		private var _dragging:Boolean;

		public function TreeDisplay() {
			DataModel.onResolutionChanged.add( onViewChanged );
			DataModel.onViewChanged.add( onViewChanged );
			DataModel.onLayerChanged.add( onViewChanged );
			DataModel.onItemChanged.add( onItemChanged );

			_doSelectItems = new Signal( Array );
			_doSelectItems.add( onSelectItems );

			_doZoom = new Signal( Number );
			_doZoom.add( doZoom );

			_selection = new SelectionItem();
			_selection.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			_selection.addEventListener(MouseEvent.DOUBLE_CLICK, onDblClick, false, 0, true);

			this.addEventListener(MouseEvent.CLICK, onDeselect, false, 0, true);

			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			_allowed = new Vector.<ItemModel>();

			_local = new Point();
			_global = new Point();
		}

		private function onAddedToStage( e:Event ):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			stage.addEventListener(MouseEvent.MOUSE_DOWN, onContainerStart);
			stage.addEventListener(MouseEvent.MOUSE_UP, onContainerStop);

			stage.addEventListener(Event.RESIZE, onResize);
		}

		public static function get doSelectItems():Signal { return _doSelectItems; }
		public static function get doZoom():Signal { return _doZoom; }

		private function onContainerStart(e:MouseEvent):void {
			if( DataModel.ALT_KEY ) {
				_dragging = true;
				this.startDrag();
				this.mouseEnabled = this.mouseChildren = false;
				return;
			}
		}

		private function onContainerStop(e:MouseEvent):void {
			if( _dragging ) {
				_dragging = false;
				this.stopDrag();
				this.mouseEnabled = this.mouseChildren = true;
			}
		}

		private function onResize(e:Event):void {
			this.x = (stage.stageWidth - DataModel.SCREEN_WIDTH*this.scaleX) >> 1;
			this.y = (stage.stageHeight - DataModel.SCREEN_HEIGHT*this.scaleY) >> 1;
		}

		private function doZoom( z:Number ):void {
			this.scaleX = this.scaleY = z;

			onResize(null);
		}

		private function onItemChanged( holder:ItemModel ):void {
			if( _allowed.indexOf( holder ) >= 0  ) {
				var item:CDItem = holder.item;

				holder.scaleX = holder.scaleY = 1;

				var d:DisplayObject = drawFromData( item );

				holder.removeChildren();

				holder.update( d );

				drawChildren( item, holder );

				drawSelection();
			}
		}

		private function onViewChanged():void {
			removeChildren();

			var bg:Shape = new Shape();
			with( bg.graphics ) {
				beginFill(0xffffff, 1);
				drawRect(0, 0, DataModel.SCREEN_WIDTH, DataModel.SCREEN_HEIGHT);
				endFill();
			}
			addChild(bg);

			_allowed = new Vector.<ItemModel>();

			if( DataModel.currentView != null ) {
				drawChildren( DataModel.currentView, this );
			}

			addToSelection(null);

			addChild( _selection );

			onResize(null);
		}

		private function onDeselect( e:MouseEvent ):void {
			if( e.target == _selection ) return;

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
			if( !Drawer.isLoaded || (item.asset == null || item.asset == "") ) {
				return drawShape( item );
			} else {
				if( item is CDText ) {
					return drawText( item as CDText );
				}
				return drawGraphics( item );
			}
			
			return null;
		}

		private function drawShape( item:CDItem, color:uint=0x000000 ):DisplayObject {
			var s:Shape = new Shape();

			with( s.graphics ) {
				beginFill(color, 0.5);
				drawRect(0, 0, item.width, item.height);
				endFill();
			}

			return s;
		}

		private function drawGraphics( item:CDItem ):DisplayObject {
			if( !Drawer.haveFrame(item.asset) ){
				return drawShape( item, 0xff0000);
			}

			return new Bitmap( Drawer.draw( item.asset, item.width, item.height ) );
		}
		
		private function drawText( item:CDText ):DisplayObject {
			if( !Drawer.haveFrame(item.asset) ){
				return drawShape( item, 0xff0000);
			}

			return new Bitmap( Drawer.drawText( item.text, item.asset, item.height, item.width ) );
		}

		////////////

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
			addToSelection( e.target as ItemModel, e.shiftKey );

			e.stopPropagation();
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

		private function drawSelection():void {
			var item:ItemModel;
			var rect:Rectangle;
			var pt:Point;

			for each( item in DataModel.SELECTED ) {
				if( item != null ) {
					pt = this.globalToLocal(item.localToGlobal(new Point()));
					if( rect == null ) {
						rect = new Rectangle( pt.x, pt.y, item.width, item.height );
					} else {
						rect = rect.union( new Rectangle( pt.x, pt.y, item.width, item.height ) );
					}
				}
			}

			_selection.rect = rect;
		}

		////////////

		private static const SCALE_BORDER:int = 5;

		private static const STATE_MOVE:uint 	= 1 << 1;
		private static const STATE_LEFT:uint 	= 1 << 2;
		private static const STATE_RIGHT:uint 	= 1 << 3;
		private static const STATE_TOP:uint 	= 1 << 4;
		private static const STATE_BOTTOM:uint 	= 1 << 5;
		
		private static const DIR_NONE:int 		= 0;
		private static const DIR_HORIZONTAL:int = 1;
		private static const DIR_VERTICAL:int 	= 2;

		private var _local:Point;
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
			for each( var d:ItemModel in DataModel.SELECTED ) {
				if( d != null ) {
					d.save();
				}
			}

			_selection.save();

			_local.x = e.localX;
			_local.y = e.localY;

			_global.x = e.stageX;
			_global.y = e.stageY;

			_state = 0;

			_ascale = DataModel.SHIFT_KEY;
			
			_mdir = DIR_NONE;

			if( _local.x <= SCALE_BORDER ) {
				_state |= STATE_LEFT;
			}
			if( _local.y <= SCALE_BORDER ) {
				_state |= STATE_TOP;
			}
			if( _local.x >= _selection.width-SCALE_BORDER ) {
				_state |= STATE_RIGHT;
			}
			if( _local.y >= _selection.height-SCALE_BORDER ) {
				_state |= STATE_BOTTOM;
			}

			if( _state == 0 ) _state = STATE_MOVE;

			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
		}

		private function onMouseMove( e:MouseEvent ):void {
			var diffx:int = (e.stageX - _global.x) * (1/this.scaleX);
			var diffy:int = (e.stageY - _global.y) * (1/this.scaleY);

			if( _state == STATE_MOVE ) {
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
			
			if( _state & STATE_LEFT ) {
				_selection.x = _selection.save_x + diffx;
				_selection.width = _selection.save_width - diffx;
			}
			if( _state & STATE_TOP ) {
				_selection.y = _selection.save_y + diffy;
				_selection.height = _selection.save_height - diffy;
			}
			if( _state & STATE_RIGHT ) {
				_selection.width = _selection.save_width + diffx;
			}
			if( _state & STATE_BOTTOM ) {
				_selection.height = _selection.save_height + diffy;
			}
			
			_selection.width = Math.max( 0, _selection.width );
			_selection.height = Math.max( 0, _selection.height );

			updateSelection( false );

			_selection.update();
		}

		private function onMouseUp( e:MouseEvent ):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			_selection.update();

			updateSelection( true );
		}

		private function updateSelection( setValues:Boolean ):void {
			var deltaX:int 		= _selection.x - _selection.save_x;
			var deltaY:int 		= _selection.y - _selection.save_y;
			var deltaWidth:int 	= _selection.width - _selection.save_width;
			var deltaHeight:int = _selection.height - _selection.save_height;

			if( deltaX == 0 && deltaY == 0 && deltaWidth == 0 && deltaHeight == 0 ) return;

			var item:CDItem;

			for each( var d:ItemModel in DataModel.SELECTED ) {
				if( d != null ) {
					item = d.item;

					if( setValues ) {
						const currX:int = item.x;
						const currY:int = item.y;
						const currW:int = item.width;
						const currH:int = item.height;

						item.x 		= currX + deltaX;
						item.y 		= currY + deltaY;
						item.width 	= currW + deltaWidth;
						item.height = currH + deltaHeight;
						
						item.width = Math.max( 0, item.width );
						item.height = Math.max( 0, item.height );

						DataModel.itemChanged( d );
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
import flash.geom.Rectangle;



internal class SelectionItem extends Sprite {
	public function SelectionItem() {
		this.buttonMode = true;
		this.doubleClickEnabled = true;
	}

	public function save():void {
		save_x 		= x;
		save_y 		= y;
		save_width 	= width;
		save_height = height;
	}

	public var save_x:Number;
	public var save_y:Number;
	public var save_width:Number;
	public var save_height:Number;

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

	public function update():void {
		const w:int = this.width;
		const h:int = this.height;

		this.scaleX = this.scaleY = 1;

		draw( w, h );
	}

	private function draw( width:int, height:int ):void {
		this.graphics.clear();

		with( this.graphics ) {
			beginFill(0x000000, 0.1);
			drawRect(0, 0, width, height);
			endFill();

			lineStyle(2, 0x00ff00, 0.8);
			moveTo(0, 0);
			lineTo(width, 0);
			lineTo(width, height);
			lineTo(0, height);
			lineTo(0, 0);
		}

		this.scrollRect = new Rectangle(0,0,width,height);
	}
}