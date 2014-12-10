package com.tbbgc.carbondioxide.dialogues {
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import fl.controls.TextInput;
	import com.tbbgc.carbondioxide.models.cd.CDItem;

	import org.osflash.signals.Signal;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author simonrodriguez
	 */
	public class ColorDialogue extends BaseDialogue {
		[Embed(source="../../../../../assets/colors.png")]
		private var COLORS:Class;

		private var _colors:Bitmap;

		private var _onSelect:Signal;

		private var _closeOnSelect:Boolean;

		private var _r:TextInput;
		private var _g:TextInput;
		private var _b:TextInput;
		private var _hex:TextInput;

		public function ColorDialogue( defaultColor:uint=0xffffff, closeOnSelect:Boolean=false ) {
			const WIDTH:int = 199+EDGE+EDGE;
			const HEIGHT:int = 272+HEADER+EDGE;

			var tr:String = int( (defaultColor >> 16) & 0xFF).toString();
			var tg:String = int( (defaultColor >>  8) & 0xFF).toString();
			var tb:String = int( (defaultColor      ) & 0xFF).toString();

			var sr:String = int(tr).toString(16);
			var sg:String = int(tg).toString(16);
			var sb:String = int(tb).toString(16);

			if( sr.length == 1 ) sr = "0" + sr;
			if( sg.length == 1 ) sg = "0" + sg;
			if( sb.length == 1 ) sb = "0" + sb;

			var tx:String = sr + sg + sb;

			super("Select Color", false, true, false, true);

			var s:Sprite = new Sprite();
			s.addEventListener(MouseEvent.CLICK, onClick);
			container.addChild(s);

			_colors = new COLORS();
			s.addChild(_colors);

			_r = new TextInput();
			_r.y = s.height;
			_r.width = s.width / 4;
			_r.text = tr;
			_r.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			container.addChild(_r);

			_g = new TextInput();
			_g.y = s.height;
			_g.width = s.width / 4;
			_g.x = _g.width;
			_g.text = tg;
			_g.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			container.addChild(_g);

			_b = new TextInput();
			_b.y = s.height;
			_b.width = s.width / 4;
			_b.x = _b.width + _b.width;
			_b.text = tb;
			_b.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			container.addChild(_b);

			_hex = new TextInput();
			_hex.y = s.height;
			_hex.width = s.width / 4;
			_hex.x = _hex.width + _hex.width + _hex.width;
			_hex.text = tx;
			_hex.addEventListener(KeyboardEvent.KEY_UP, onKeyUpHex, false, 0, true);
			container.addChild(_hex);

			_onSelect = new Signal( uint );

			_closeOnSelect = closeOnSelect;

			init( WIDTH, HEIGHT );

			transparentDisable();
		}

		public function get onSelect():Signal { return _onSelect; }

		override protected function onResize( width:int, height:int ):void {
		}

		override protected function close():void {
			_onSelect.removeAll();

			super.close();
		}

		private function onClick(e:MouseEvent):void {
			var color:uint = 0;

			if( e.localX < 10 && e.localY < 10 ) {
				color = CDItem.INVISIBLE_COLOR;
				_onSelect.dispatch( CDItem.INVISIBLE_COLOR );
			} else {
				color = _colors.bitmapData.getPixel( e.localX, e.localY );
				_onSelect.dispatch( color );

				_r.text = int((color >> 16) & 0xFF ).toString();
				_g.text = int((color >>  8) & 0xFF ).toString();
				_b.text = int((color      ) & 0xFF ).toString();

				var r:int = int( _r.text );
				var g:int = int( _g.text );
				var b:int = int( _b.text );

				var sr:String = int(r).toString(16);
				var sg:String = int(g).toString(16);
				var sb:String = int(b).toString(16);

				if( sr.length == 1 ) sr = "0" + sr;
				if( sg.length == 1 ) sg = "0" + sg;
				if( sb.length == 1 ) sb = "0" + sb;

				_hex.text = sr + sg + sb;
			}

			if( _closeOnSelect ) {
				close();
			}
		}

		private function onKeyUp( e:KeyboardEvent ):void {
			if( e.keyCode == Keyboard.ENTER ) {
				var r:int = int( _r.text );
				var g:int = int( _g.text );
				var b:int = int( _b.text );

				r = Math.max( 0, Math.min( 255, r ) );
				g = Math.max( 0, Math.min( 255, g ) );
				b = Math.max( 0, Math.min( 255, b ) );

				_r.text = r.toString();
				_g.text = g.toString();
				_b.text = b.toString();

				var sr:String = int(r).toString(16);
				var sg:String = int(g).toString(16);
				var sb:String = int(b).toString(16);

				if( sr.length == 1 ) sr = "0" + sr;
				if( sg.length == 1 ) sg = "0" + sg;
				if( sb.length == 1 ) sb = "0" + sb;

				_hex.text = sr + sg + sb;

				var color:uint = 255 << 24 | r << 16 | g << 8 | b;

				_onSelect.dispatch( color );

				if( _closeOnSelect ) {
					close();
				}
			}
		}

		private function onKeyUpHex( e:KeyboardEvent ):void {
			if( e.keyCode == Keyboard.ENTER ) {
				if( _hex.text.length != 6 ) {
					_hex.text = "";
					return;
				}

				var color:uint = uint( "0x"+_hex.text );

				_r.text = int( (color >> 16) & 0xFF).toString();
				_g.text = int( (color >>  8) & 0xFF).toString();
				_b.text = int( (color      ) & 0xFF).toString();

				_onSelect.dispatch( color );

				if( _closeOnSelect ) {
					close();
				}
			}
		}
	}
}
