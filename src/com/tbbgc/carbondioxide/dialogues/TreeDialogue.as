package com.tbbgc.carbondioxide.dialogues {
	import fl.controls.ScrollBar;
	import fl.controls.ScrollBarDirection;
	import fl.events.ScrollEvent;

	import com.tbbgc.carbondioxide.managers.EventManager;
	import com.tbbgc.carbondioxide.managers.SettingsManager;
	import com.tbbgc.carbondioxide.models.DataModel;
	import com.tbbgc.carbondioxide.models.cd.CDItem;
	import com.tbbgc.carbondioxide.models.cd.CDResolution;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * @author simonrodriguez
	 */
	public class TreeDialogue extends BaseDialogue {
		private var _bg:Sprite;
		private var _tree:Sprite;

		private var _height:int;

		private var _scrollV:ScrollBar;
		private var _scrollH:ScrollBar;

		public function TreeDialogue( fullSize:Boolean=true ) {
			const WIDTH:int = 300;
			const HEIGHT:int = 450;

			super("Tree", true, false, true, true);

			this.addEventListener(MouseEvent.MOUSE_WHEEL, onScroll, false, 0, true);

			GraphicsData.build();

			_bg = new Sprite();
			container.addChild( _bg );

			_tree = new Sprite();
			_bg.addChild( _tree );

			_scrollV = new ScrollBar();
			_scrollV.addEventListener(ScrollEvent.SCROLL, onScrollV);
			container.addChild( _scrollV );

			_scrollH = new ScrollBar();
			_scrollH.direction = ScrollBarDirection.HORIZONTAL;
			_scrollH.addEventListener(ScrollEvent.SCROLL, onScrollH);
			container.addChild( _scrollH );

			init( WIDTH, HEIGHT, 220, 10, !fullSize );

			DataModel.onItemChanged.add( onItemUpdated );
			DataModel.onLayerChanged.add( update );
			DataModel.onViewChanged.add( update );
			DataModel.onSelectedChanged.add( update );

			ExpandModel.onChanged.add( update );
		}

		override protected function get dialogueID():String { return SettingsManager.SETTINGS_TREE; }

		override protected function onResize( width:int, height:int ):void {
			_bg.graphics.clear();

			with( _bg.graphics ) {
				beginFill(0x929292,1);
				drawRect(0, 0, width - _scrollV.width - 5, height - _scrollH.height - 5);
				endFill();
			}

			_bg.scrollRect = new Rectangle(0, 0, width - _scrollV.width - 5, height - _scrollH.height - 5);

			_scrollV.x = width - _scrollV.width;
			_scrollV.height = height;

			_scrollH.y = height - _scrollH.height;
			_scrollH.width = width - _scrollV.width;

			updateScrollbars();
		}

		private function onScroll(e:MouseEvent):void {
			_scrollV.scrollPosition -= e.delta;
		}

		private function onScrollV( e:ScrollEvent ):void {
			_tree.y = -_scrollV.scrollPosition;
		}

		private function onScrollH( e:ScrollEvent ):void {
			_tree.x = -_scrollH.scrollPosition;
		}

		private function onItemUpdated( item:CDItem ):void {
			update();
		}

		private function update():void {
			EventManager.treeChanged( updateCB );
		}

		private function updateCB():void {
			_tree.removeChildren();

			_height = 2;

			if( DataModel.currentView == null ) return;

			var resbuffer:Vector.<CDResolution> = new Vector.<CDResolution>();

			buildNode( DataModel.currentView, 2, resbuffer );

			updateScrollbars();
		}

		private function updateScrollbars():void {
			const diffV:int = Math.max( 0, _tree.height - _bg.scrollRect.height );
			const diffH:int = Math.max( 0, _tree.width - _bg.scrollRect.width );

			if( diffV == 0 ) {
				_tree.y = 0;
			}
			if( diffH == 0 ) {
				_tree.x = 0;
			}

			_scrollV.minScrollPosition = 0;
			_scrollV.maxScrollPosition = diffV;
			_scrollV.visible = (diffV>0);

			_scrollH.minScrollPosition = 0;
			_scrollH.maxScrollPosition = diffH;
			_scrollH.visible = (diffH>0);
		}

		private function buildNode( node:CDItem, offset:int, resbuffer:Vector.<CDResolution> ):void {
			var i:TreeItem = new TreeItem( node );
			i.x = offset;
			i.y = _height;
			_tree.addChild( i );

			_height += i.height + 1;

			if( ExpandModel.isMaximized( node ) ) {
				if( ExpandModel.isShowingResolutions ) {
					for each( var res:CDResolution in node.resolutions ) {
						buildResolution( resbuffer, res, node, offset + 13 );
					}
				}

				var reverse:Vector.<CDItem> = node.children.concat().reverse();

				for each( var child:CDItem in reverse ) {
					buildNode( child, offset + 13, resbuffer );
				}
			}
		}

		private function buildResolution( buffer:Vector.<CDResolution>, res:CDResolution, node:CDItem, offset:int ):void {
			var cindex:int = -1;

			var m:CDResolution;

			const len:int = buffer.length;
			for( var x:int = 0; x < len; x++ ) {
				m = buffer[x];
				if( m.screenWidth == res.screenWidth && m.screenHeight == res.screenHeight && m.screenDPI == res.screenDPI ) {
					cindex = x;
					break;
				}
			}

			if( cindex == -1 ) {
				buffer.push( res );
				cindex = buffer.length-1;
			}

			var color:uint = 0;
			switch( cindex ) {
				case 0: color = 0x0000ff; break;
				case 1: color = 0xff0000; break;
				case 2: color = 0x00ff00; break;
				case 3: color = 0xffffff; break;
				case 4: color = 0xff00ff; break;
				case 5: color = 0x00ffff; break;
				case 6: color = 0xffff00; break;
				case 7: color = 0xa0a0a0; break;
				case 8: color = 0xaaffff; break;
				case 9: color = 0xffaaff; break;
			}

			var i:ResolutionItem = new ResolutionItem( res, node, color );
			i.x = offset;
			i.y = _height;
			_tree.addChild( i );

			_height += i.height + 1;
		}
	}
}



import com.tbbgc.carbondioxide.components.TreeDisplay;
import com.tbbgc.carbondioxide.dialogues.InputDialogue;
import com.tbbgc.carbondioxide.dialogues.PopupDialogue;
import com.tbbgc.carbondioxide.managers.EventManager;
import com.tbbgc.carbondioxide.models.DataModel;
import com.tbbgc.carbondioxide.models.ItemModel;
import com.tbbgc.carbondioxide.models.cd.CDGradient;
import com.tbbgc.carbondioxide.models.cd.CDItem;
import com.tbbgc.carbondioxide.models.cd.CDResolution;
import com.tbbgc.carbondioxide.models.cd.CDText;
import com.tbbgc.carbondioxide.models.cd.CDView;
import com.tbbgc.carbondioxide.models.resolutions.ResolutionsModel;
import org.osflash.signals.Signal;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.NativeMenuItem;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.ui.ContextMenu;
import flash.utils.Dictionary;



internal class ExpandModel {
	public static var onChanged:Signal = new Signal();

	////////////////////

	private static var expands:Dictionary = new Dictionary( true );

	public static function minimize( model:CDItem, update:Boolean=true ):void {
		if( !showResolutions && model.children.length == 0 ) return;

		expands[ model ] = true;

		if( update ) onChanged.dispatch();
	}

	public static function maximize( model:CDItem, update:Boolean=true ):void {
		expands[ model ] = null;

		if( update ) onChanged.dispatch();
	}

	public static function isMaximized( model:CDItem ):Boolean {
		return (expands[ model ] == null);
	}

	////////////////////

	private static var showResolutions:Boolean = true;

	public static function toggleResolutions():void {
		showResolutions = !showResolutions;

		onChanged.dispatch();
	}

	public static function get isShowingResolutions():Boolean {
		return showResolutions;
	}
}



internal class GraphicsData {
	public static const ROW_HEIGHT:int = 16;

	public static const COLOR_RESOLUTION:uint 	= 0x77bb77;
	public static const COLOR_FOLDER:uint 		= 0xdde20a;
	public static const COLOR_NORMAL:uint 		= 0xffffff;
	public static const COLOR_PARENT:uint 		= 0xbb7777;
	public static const COLOR_SELECTED:uint 	= 0x7777bb;

	private static var _rows:Dictionary;
	private static var _colors:Dictionary;
	private static var _dots:Dictionary;

	public static function build():void {
		_rows 	= new Dictionary();
		_colors = new Dictionary();
		_dots 	= new Dictionary();
	}

	public static function getRowByColor( color:uint ):BitmapData {
		if( _rows[color] != null) {
			return _rows[color];
		}

		var s:Shape = new Shape();
		with(s.graphics) {
			beginFill(color, 1);
			drawRoundRect(16, 0, 600, ROW_HEIGHT, 8, 8);
			endFill();
		}

		var bm:BitmapData = new BitmapData(600+16, ROW_HEIGHT, true, 0x0);
		bm.drawWithQuality(s, null, null, null, null, true, StageQuality.BEST);

		_rows[ color ] = bm;

		return bm;
	}

	public static function getColor( color:uint ):BitmapData {
		if( _colors[color] != null ) {
			return _colors[color];
		}

		var dot:Shape = new Shape();
		with( dot.graphics ) {
			beginFill(color, 0.7);
			drawCircle(16+8, 8, 6);
			endFill();
		}

		var bm:BitmapData = new BitmapData(32, 16, true, 0x0);
		bm.drawWithQuality(dot, null, null, null, null, true, StageQuality.BEST);

		_colors[ color ] = bm;

		return bm;
	}

	public static function getDot( color:uint ):BitmapData {
		if( _dots[color] != null ) {
			return _dots[color];
		}

		var dot:Shape = new Shape();
		with( dot.graphics ) {
			beginFill(color, 1);
			drawRoundRect(0, 0, ROW_HEIGHT, ROW_HEIGHT, 8);
			endFill();
		}

		var bm:BitmapData = new BitmapData(ROW_HEIGHT, ROW_HEIGHT, true, 0x0);
		bm.drawWithQuality(dot, null, null, null, null, true, StageQuality.BEST);

		_dots[ color ] = bm;

		return bm;
	}
}



internal class ResolutionItem extends Sprite {
	private var _name:Sprite;

	private var _parent:CDItem;
	private var _model:CDResolution;

	public function ResolutionItem( model:CDResolution, parent:CDItem, color:uint ) {
		super();

		_parent = parent;
		_model = model;

		_name = buildName( ResolutionsModel.getResolutionNameFromModel(model) + " (" + model.screenWidth + "x" + model.screenHeight + ")", color );
		_name.x = GraphicsData.ROW_HEIGHT + GraphicsData.ROW_HEIGHT + 6 + 6 + 2;
		_name.addEventListener(MouseEvent.RIGHT_CLICK, onSubMenu);
		addChild(_name);
	}

	private function buildName( text:String, color:uint ):Sprite {
		var con:Sprite = new Sprite();
		con.buttonMode = true;
		con.mouseChildren = false;

		con.addChild( new Bitmap(GraphicsData.getRowByColor(GraphicsData.COLOR_RESOLUTION)) );

		con.addChild( new Bitmap(GraphicsData.getColor(color)) );

		var fmt:TextFormat = new TextFormat("Verdana", 9, 0xff000000);

		var t:TextField = new TextField();
		t.mouseEnabled = false;
		t.autoSize = TextFieldAutoSize.LEFT;
		t.selectable = false;
		t.defaultTextFormat = fmt;
		t.text = text;
		t.x = 40;
		t.y = (GraphicsData.ROW_HEIGHT - t.height) / 2;
		con.addChild(t);

		return con;
	}

	private function onSubMenu( e:MouseEvent ):void {
		var s:ContextMenu = new ContextMenu();

		var additem:Function = function( name:String, callback:Function ):void {
			var item:NativeMenuItem;
			if( name == null ) {
				item = new NativeMenuItem( null, true );
			} else {
				item = new NativeMenuItem( name );
				item.addEventListener(Event.SELECT, callback);
			}
			s.addItem( item );
		};

		additem( "Delete", onDelete );
		additem( null, null );
		additem( ExpandModel.isShowingResolutions ? "Hide resolutions" : "Show resolutions", onToggleResolutions );

		var global:Point = this.localToGlobal( new Point( this.mouseX, this.mouseY) );
		s.display( this.stage, global.x, global.y );
	}

	private function onDelete( e:Event ):void {
		_parent.removeResolution( _model );
	}

	private function onToggleResolutions( e:Event ):void {
		ExpandModel.toggleResolutions();
	}
}



internal class TreeItem extends Sprite {
	private static const HEIGHT:int = 16;

	private var _minmax:Sprite;

	private var _enabled:Sprite;
	private var _visible:Sprite;

	private var _name:Sprite;

	private var _model:CDItem;

	public function TreeItem( model:CDItem ) {
		super();

		_model = model;

		_name = buildName();
		_name.x = HEIGHT + HEIGHT + 6 + 6 + 2;
		_name.addEventListener(MouseEvent.CLICK, onName);
		_name.addEventListener(MouseEvent.DOUBLE_CLICK, onDblClick);
		_name.addEventListener(MouseEvent.RIGHT_CLICK, onSubMenu);
		addChild(_name);

		_minmax = buildDot( 0x262626, ExpandModel.isMaximized( _model) ? "-" : "+" );
		_minmax.addEventListener(MouseEvent.CLICK, onMinMax);
		addChild(_minmax);

		if( !(model is CDView) ) {
			_enabled = buildDot( model.enabled ? 0x44ee44 : 0x008800, "E ");
			_enabled.x = HEIGHT + 6;
			_enabled.addEventListener(MouseEvent.CLICK, onEnabled);
			addChild(_enabled);

			_visible = buildDot( model.visible ? 0x44ee44 : 0x008800, "V ");
			_visible.x = HEIGHT + HEIGHT + 6 + 2;
			_visible.addEventListener(MouseEvent.CLICK, onVisible);
			addChild(_visible);
		}

		if( (model is CDView) ) {
			_name.x = 6;
		}
	}

	private static function isSelected( model:CDItem ):Boolean {
		for each( var holder:ItemModel in DataModel.SELECTED ) {
			if( holder.item == model ) {
				return true;
			}
		}
		return false;
	}

	private function buildDot( color:uint, text:String ):Sprite {
		var dot:Sprite = new Sprite();
		dot.buttonMode = true;
		dot.mouseChildren = false;

		dot.addChild( new Bitmap( GraphicsData.getDot(color)) );

		var fmt:TextFormat = new TextFormat("Verdana", 9, (text == "+" || text == "-" ) ? 0xffffffff : 0xff000000, true);

		var t:TextField = new TextField();
		t.mouseEnabled = false;
		t.autoSize = TextFieldAutoSize.LEFT;
		t.selectable = false;
		t.defaultTextFormat = fmt;
		t.text = text;
		t.x = (HEIGHT - t.getBounds(t).width) / 2;
		t.y = (HEIGHT - t.getBounds(t).height) / 2;
		dot.addChild(t);

		return dot;
	}

	private function buildName():Sprite {
		var color:uint = GraphicsData.COLOR_NORMAL;

		var text:String = _model.name;

		if( _model.note != null && _model.note != "" ) {
			text += " (!)";
		}

		if( _model.alpha == 0 ) color = GraphicsData.COLOR_FOLDER;
		if( _model == DataModel.currentLayer ) color = GraphicsData.COLOR_PARENT;
		if( isSelected(_model) ) color = GraphicsData.COLOR_SELECTED;

		var con:Sprite = new Sprite();
		con.buttonMode = true;
		con.mouseChildren = false;
		con.doubleClickEnabled = true;

		con.addChild( new Bitmap(GraphicsData.getRowByColor(color)) );

		var fmt:TextFormat = new TextFormat("Verdana", 9, 0xff000000);

		var t:TextField = new TextField();
		t.mouseEnabled = false;
		t.autoSize = TextFieldAutoSize.LEFT;
		t.selectable = false;
		t.defaultTextFormat = fmt;
		t.text = text;
		t.x = 20;
		t.y = (GraphicsData.ROW_HEIGHT - t.height) / 2;
		con.addChild(t);

		return con;
	}

	private function onMinMax( e:MouseEvent ):void {
		if( ExpandModel.isMaximized( _model ) ) {
			ExpandModel.minimize( _model );
		} else {
			ExpandModel.maximize( _model );
		}
	}

	private function onEnabled( e:MouseEvent ):void {
		_model.enabled = !_model.enabled;
	}

	private function onVisible( e:MouseEvent ):void {
		_model.visible = !_model.visible;
	}

	private function onName( e:MouseEvent ):void {
		if( _model == DataModel.currentView ) {
			TreeDisplay.doSelectItems.dispatch( [] );

			if( _model != DataModel.currentLayer ) {
				DataModel.setLayer( _model );
			}

			return;
		}

		if( DataModel.SELECTED.length == 1 && DataModel.SELECTED[0].item == _model ) {
			return;
		}

		if( _model.parent != DataModel.currentLayer ) {
			DataModel.setLayer( _model.parent );
		}

		if( e.commandKey || e.ctrlKey ) {
			var wasin:Boolean = false;

			var a:Array = [];
			for each( var item:ItemModel in DataModel.SELECTED ) {
				if( item.item == _model ) {
					 wasin = true;
				} else {
					a.push( item.item );
				}
			}

			if( !wasin ) {
				a.push( _model );
			}

			TreeDisplay.doSelectItems.dispatch( a );
		} else {
			EventManager.selectItems( [_model] );
		}

		stage.focus = null;
	}

	private function onDblClick(e:MouseEvent):void {
		DataModel.setLayer( _model );

		TreeDisplay.doSelectItems.dispatch( [] );
	}

	private function onSubMenu( e:MouseEvent ):void {
		var s:ContextMenu = new ContextMenu();

		var additem:Function = function( name:String, callback:Function ):void {
			var item:NativeMenuItem;
			if( name == null ) {
				item = new NativeMenuItem( null, true );
			} else {
				item = new NativeMenuItem( name );
				item.addEventListener(Event.SELECT, callback);
			}
			s.addItem( item );
		};

		additem( "Add Item", onAddItemItem );
		additem( "Add Text", onAddItemText );
		additem( "Add Gradient", onAddItemGradient );
		additem( "Delete", onDelete );
		additem( null, null );
		additem( "Move Top", onMoveTop );
		additem( "Move Up", onMoveUp );
		additem( "Move Down", onMoveDown );
		additem( "Move Bottom", onMoveBottom );
		additem( null, null );
		additem( "Expand All", onExpandAll );
		additem( "Collapse All", onCollapseAll );
		additem( null, null );
		additem( ExpandModel.isShowingResolutions ? "Hide resolutions" : "Show resolutions", onToggleResolutions );

		var global:Point = this.localToGlobal( new Point( this.mouseX, this.mouseY) );
		s.display( this.stage, global.x, global.y );
	}

	private static const ADD_ITEM:int 		= 0;
	private static const ADD_TEXT:int 		= 1;
	private static const ADD_GRADIENT:int 	= 2;
	private var _addType:int;

	private function onAddItemItem(e:Event):void {
		_addType = ADD_ITEM;
		onAddItem();
	}

	private function onAddItemText(e:Event):void {
		_addType = ADD_TEXT;
		onAddItem();
	}

	private function onAddItemGradient(e:Event):void {
		_addType = ADD_GRADIENT;
		onAddItem();
	}

	private function onAddItem():void {
		if( DataModel.currentView == null ) {
			new PopupDialogue("ERROR", "Add a view first.");
		}

		var input:InputDialogue = new InputDialogue("Add Item", "Enter name:");
		input.onOK.addOnce( onAddItemNamed );
	}

	private function onAddItemNamed(input:InputDialogue):void {
		if( input.text == null || input.text == "" )
			return;

		if( checkName(input.text) ) {
			var item:CDItem;

			switch( _addType ) {
				case ADD_ITEM:
			 		item = _model.addChild( new CDItem(_model, input.text) );
				break;

				case ADD_TEXT:
					item = _model.addChild( new CDText(_model, input.text) );
				break;

				case ADD_GRADIENT:
					item = _model.addChild( new CDGradient(_model, input.text) );
				break;
			}

			item.setXYWH(0, 0, Math.max( 25, Math.min( 100, _model.width * 0.2) ), Math.max( 25, Math.min( 100, _model.height * 0.2) ));

			if( input.isCmd ) {
				DataModel.onFilterAssets.dispatch( input.text );
			}

			if( item.parent != DataModel.currentLayer ) {
				DataModel.setLayer( item.parent );
			}

			EventManager.selectItems([item]);
		} else {
			new PopupDialogue("ERROR", "ERROR: Name is already in use.");
		}
	}

	private function checkName( name:String ):Boolean {
		const children:Vector.<CDItem> = _model.children;

		const len:int = children.length;

		for( var i:int = 0; i < len; i++ ) {
			if( children[i].name == name ) {
				return false;
			}
		}

		return true;
	}

	private function onDelete(e:Event):void {
		var sel:Vector.<ItemModel> = DataModel.SELECTED.concat();
		for each( var item:ItemModel in sel ) {
			item.item.parent.removeChild( item.item );
		}
	}

	private function onMoveTop( e:Event ):void {
		_model.parent.setChildIndex(_model, _model.parent.children.length-1);
	}

	private function onMoveBottom( e:Event ):void {
		_model.parent.setChildIndex(_model, 0);
	}

	private function onMoveUp( e:Event ):void {
		_model.parent.setChildIndex(_model, _model.parent.getChildIndex(_model)+1);
	}

	private function onMoveDown( e:Event ):void {
		_model.parent.setChildIndex(_model, _model.parent.getChildIndex(_model)-1);
	}

	private function onToggleResolutions( e:Event ):void {
		ExpandModel.toggleResolutions();
	}

	private function onExpandAll( e:Event ):void {
		onExpColRecursive(_model, true);

		ExpandModel.onChanged.dispatch();
	}
	private function onCollapseAll( e:Event ):void {
		onExpColRecursive(_model, false);

		ExpandModel.onChanged.dispatch();
	}
	private function onExpColRecursive( item:CDItem, exp:Boolean ):void {
		if( exp ) {
			ExpandModel.maximize( item, false );
		} else {
			ExpandModel.minimize( item, false );
		}

		for each( var m:CDItem in item.children ) {
			onExpColRecursive(m, exp);
		}
	}
}
