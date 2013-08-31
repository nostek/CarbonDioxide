package com.stardoll.carbondioxide.dialogues {
	import com.stardoll.carbondioxide.models.DataModel;
	import com.stardoll.carbondioxide.models.cd.CDItem;
	import flash.display.Sprite;

	/**
	 * @author simonrodriguez
	 */
	public class TreeDialogue extends BaseDialogue {
		private var _tree:Sprite;

		private var _height:int;

		public function TreeDialogue() {
			super("Tree", true, false, true, true);

			_tree = new Sprite();
			container.addChild( _tree );

			init( 300, 400 );

			DataModel.onItemChanged.add( onItemUpdated );
			DataModel.onLayerChanged.add( update );
			DataModel.onViewChanged.add( update );
		}

		override protected function onResize( width:int, height:int ):void {
			_tree.graphics.clear();

			with( _tree.graphics ) {
				beginFill(0xffffff,1);
				drawRect(0, 0, width, height);
				endFill();
			}

			update();
		}

		private function onItemUpdated( item:CDItem ):void {
			update();
		}

		private function update():void {
			_tree.removeChildren();

			_height = 2;

			buildNode( DataModel.currentView, 2 );
		}

		private function buildNode( node:CDItem, offset:int ):void {
			var i:TreeItem = new TreeItem( node );
			i.x = offset;
			i.y = _height;
			_tree.addChild( i );

			_height += i.height + 1;

			for each( var child:CDItem in node.children ) {
				buildNode( child, offset + 20 );
			}
		}
	}
}



import com.stardoll.carbondioxide.models.DataModel;
import com.stardoll.carbondioxide.models.cd.CDItem;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;



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

		_minmax = buildDot( 0x000000, "-");
		addChild(_minmax);

		_enabled = buildDot( model.enabled ? 0x00ff00 : 0xff0000, "E ");
		_enabled.x = HEIGHT + 6;
		_enabled.addEventListener(MouseEvent.CLICK, onEnabled);
		addChild(_enabled);

		_visible = buildDot( model.visible ? 0x00ff00 : 0xff0000, "V ");
		_visible.x = HEIGHT + HEIGHT + 6 + 2;
		_visible.addEventListener(MouseEvent.CLICK, onVisible);
		addChild(_visible);

		if( model.parent != DataModel.currentLayer ) {
			_enabled.visible = _visible.visible = false;
		}

		_name = buildName( model == DataModel.currentLayer ? 0xcccccc : 0xffffff, model.name );
		_name.x = HEIGHT + HEIGHT + 6 + 6 + 2;
		_name.addEventListener(MouseEvent.CLICK, onName);
		addChild(_name);
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

	private function buildName( color:uint, text:String ):Sprite {
		var dot:Sprite = new Sprite();
		dot.buttonMode = true;
		dot.mouseChildren = false;
		with( dot.graphics ) {
			lineStyle(1, 0x000000, 1);

			beginFill(color, 1);
			drawRoundRect(16, 0, 220, HEIGHT, 16, 16);
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

	private function onEnabled( e:MouseEvent ):void {
		_model.enabled = !_model.enabled;
	}

	private function onVisible( e:MouseEvent ):void {
		_model.visible = !_model.visible;
	}

	private function onName( e:MouseEvent ):void {
		if( _model.parent == DataModel.currentLayer ) {

		} else {
			DataModel.setLayer( _model );
		}
	}
}