package com.stardoll.carbondioxide.dialogues {
	import fl.controls.ScrollBar;
	import fl.controls.ScrollBarDirection;
	import fl.events.ScrollEvent;

	import com.stardoll.carbondioxide.managers.EventManager;
	import com.stardoll.carbondioxide.managers.SettingsManager;
	import com.stardoll.carbondioxide.models.DataModel;
	import com.stardoll.carbondioxide.models.cd.CDItem;
	import com.stardoll.carbondioxide.models.cd.CDResolution;

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
				beginFill(0xffffff,1);
				drawRect(0, 0, width - _scrollV.width - 5, height - _scrollH.height - 5);
				endFill();
			}

			_bg.scrollRect = new Rectangle(0, 0, width - _scrollV.width - 5, height - _scrollH.height - 5);

			_scrollV.x = width - _scrollV.width;
			_scrollV.height = height;

			_scrollH.y = height - _scrollH.height;
			_scrollH.width = width - _scrollV.width;

			update();
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
			item;

			update();
		}

		private function update():void {
			EventManager.treeChanged( updateCB );
		}

		private function updateCB():void {
			_tree.removeChildren();

			_height = 2;

			if( DataModel.currentView == null ) return;

			buildNode( DataModel.currentView, 2 );

			////

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

		private function buildNode( node:CDItem, offset:int ):void {
			var i:TreeItem = new TreeItem( node );
			i.x = offset;
			i.y = _height;
			_tree.addChild( i );

			_height += i.height + 1;

			if( ExpandModel.isMaximized( node ) ) {
				if( ExpandModel.isShowingResolutions ) {
					for each( var res:CDResolution in node.resolutions ) {
						buildResolution( res, node, offset + 13 );
					}
				}

				var reverse:Vector.<CDItem> = node.children.concat().reverse();

				for each( var child:CDItem in reverse ) {
					buildNode( child, offset + 13 );
				}
			}
		}

		private function buildResolution( res:CDResolution, node:CDItem, offset:int ):void {
			var i:ResolutionItem = new ResolutionItem( res, node );
			i.x = offset;
			i.y = _height;
			_tree.addChild( i );

			_height += i.height + 1;
		}
	}
}



import com.stardoll.carbondioxide.components.TreeDisplay;
import com.stardoll.carbondioxide.dialogues.InputDialogue;
import com.stardoll.carbondioxide.dialogues.PopupDialogue;
import com.stardoll.carbondioxide.models.DataModel;
import com.stardoll.carbondioxide.models.ItemModel;
import com.stardoll.carbondioxide.models.cd.CDItem;
import com.stardoll.carbondioxide.models.cd.CDResolution;
import com.stardoll.carbondioxide.models.cd.CDText;
import com.stardoll.carbondioxide.models.resolutions.ResolutionsModel;

import org.osflash.signals.Signal;

import flash.display.NativeMenuItem;
import flash.display.Sprite;
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

	public static function minimize( model:CDItem ):void {
		expands[ model ] = true;

		onChanged.dispatch();
	}

	public static function maximize( model:CDItem ):void {
		expands[ model ] = null;

		onChanged.dispatch();
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



internal class ResolutionItem extends Sprite {
	private static const HEIGHT:int = 16;

	private var _name:Sprite;

	private var _parent:CDItem;
	private var _model:CDResolution;

	public function ResolutionItem( model:CDResolution, parent:CDItem ) {
		super();

		_parent = parent;
		_model = model;

		var name:String = "unidentified";

		const resolutions:Array = ResolutionsModel.resolutions;

		for each( var o:Object in resolutions ) {
			if( o["width"] == model.screenWidth && o["height"] == model.screenHeight ) {
				name = o["label"];
				break;
			}
		}

		name += " (" + model.screenWidth + "x" + model.screenHeight + ")";

		_name = buildName( name );
		_name.x = HEIGHT + HEIGHT + 6 + 6 + 2;
		_name.addEventListener(MouseEvent.RIGHT_CLICK, onSubMenu);
		addChild(_name);
	}

	private function buildName( text:String ):Sprite {
		var dot:Sprite = new Sprite();
		dot.buttonMode = true;
		dot.mouseChildren = false;
		with( dot.graphics ) {
			lineStyle(1, 0x000000, 1);

			beginFill(0x77bb77, 1);
			drawRoundRect(16, 0, 300, HEIGHT, 16, 16);
			endFill();
		}

		var fmt:TextFormat = new TextFormat("Verdana", 10, 0xff000000, null, true);

		var t:TextField = new TextField();
		t.autoSize = TextFieldAutoSize.LEFT;
		t.selectable = false;
		t.defaultTextFormat = fmt;
		t.text = text;
		t.x = 20;
		t.y = (HEIGHT - t.height) / 2;
		dot.addChild(t);

		return dot;
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

		_minmax = buildDot( 0x000000, ExpandModel.isMaximized( _model) ? "-" : "+" );
		_minmax.addEventListener(MouseEvent.CLICK, onMinMax);
		addChild(_minmax);

		_enabled = buildDot( model.enabled ? 0x00ff00 : 0xff0000, "E ");
		_enabled.x = HEIGHT + 6;
		_enabled.addEventListener(MouseEvent.CLICK, onEnabled);
		addChild(_enabled);

		_visible = buildDot( model.visible ? 0x00ff00 : 0xff0000, "V ");
		_visible.x = HEIGHT + HEIGHT + 6 + 2;
		_visible.addEventListener(MouseEvent.CLICK, onVisible);
		addChild(_visible);

//		if( model.parent != DataModel.currentLayer ) {
//			_enabled.visible = _visible.visible = false;
//		}

		_name = buildName();
		_name.x = HEIGHT + HEIGHT + 6 + 6 + 2;
		_name.addEventListener(MouseEvent.CLICK, onName);
		_name.addEventListener(MouseEvent.DOUBLE_CLICK, onDblClick);
		_name.addEventListener(MouseEvent.RIGHT_CLICK, onSubMenu);
		addChild(_name);
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
		with( dot.graphics ) {
			lineStyle(1, 0x000000, 1);

			beginFill(color, 1);
			drawCircle(HEIGHT/2, HEIGHT/2, HEIGHT/2);
			endFill();
		}

		var fmt:TextFormat = new TextFormat("Verdana", 10, 0xffffffff, null, true);

		var t:TextField = new TextField();
		t.autoSize = TextFieldAutoSize.LEFT;
		t.selectable = false;
		t.defaultTextFormat = fmt;
		t.text = text;
		t.x = (HEIGHT - t.width) / 2;
		t.y = (HEIGHT - t.height) / 2;
		dot.addChild(t);

		return dot;
	}

	private function buildName():Sprite {
		var color:uint = 0xffffff;

		var text:String = _model.name;

		if( _model.note != null && _model.note != "" ) {
			text += " (!)";
		}

		if( _model.isColorDefined && _model.color == CDItem.INVISIBLE_COLOR ) color = 0xdde20a;
		if( _model == DataModel.currentLayer ) color = 0xbb7777;
		if( isSelected(_model) ) color = 0x7777bb;

		var dot:Sprite = new Sprite();
		dot.buttonMode = true;
		dot.mouseChildren = false;
		dot.doubleClickEnabled = true;
		with( dot.graphics ) {
			lineStyle(1, 0x000000, 1);

			beginFill(color, 1);
			drawRoundRect(16, 0, 300, HEIGHT, 16, 16);
			endFill();
		}

		var fmt:TextFormat = new TextFormat("Verdana", 10, 0xff000000, null, true);

		var t:TextField = new TextField();
		t.autoSize = TextFieldAutoSize.LEFT;
		t.selectable = false;
		t.defaultTextFormat = fmt;
		t.text = text;
		t.x = 20;
		t.y = (HEIGHT - t.height) / 2;
		dot.addChild(t);

		return dot;
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

		TreeDisplay.doSelectItems.dispatch( [_model] );
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
		additem( "Delete", onDelete );
		additem( null, null );
		additem( "Move Top", onMoveTop );
		additem( "Move Up", onMoveUp );
		additem( "Move Down", onMoveDown );
		additem( "Move Bottom", onMoveBottom );
		additem( null, null );
		additem( ExpandModel.isShowingResolutions ? "Hide resolutions" : "Show resolutions", onToggleResolutions );

		var global:Point = this.localToGlobal( new Point( this.mouseX, this.mouseY) );
		s.display( this.stage, global.x, global.y );
	}

	private static const ADD_ITEM:int = 0;
	private static const ADD_TEXT:int = 1;
	private var _addType:int;

	private function onAddItemItem(e:Event):void {
		_addType = ADD_ITEM;
		onAddItem();
	}

	private function onAddItemText(e:Event):void {
		_addType = ADD_TEXT;
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
			}

			item.setXYWH(0, 0, Math.max( 25, Math.min( 100, _model.width * 0.2) ), Math.max( 25, Math.min( 100, _model.height * 0.2) ));
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
		_model.parent.removeChild( _model );
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
}
