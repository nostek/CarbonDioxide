package com.tbbgc.carbondioxide.dialogues {
	import fl.controls.Button;
	import fl.controls.TextInput;

	import com.tbbgc.carbondioxide.models.cd.CDGradient;

	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	/**R
	 * @author simonrodriguez
	 */
	public class GradientDialogue extends BaseDialogue {
		[Embed(source="../../../../../assets/colors.png")]
		private var COLORS:Class;

		private var _colorTopLeft:Button;
		private var _colorTopRight:Button;
		private var _colorBottomLeft:Button;
		private var _colorBottomRight:Button;

		private var _alphaTopLeft:TextInput;
		private var _alphaTopRight:TextInput;
		private var _alphaBottomLeft:TextInput;
		private var _alphaBottomRight:TextInput;

		private var _corner:int;

		private var _item:CDGradient;

		public function GradientDialogue( item:CDGradient ) {
			const WIDTH:int = 300;
			const HEIGHT:int = 450;

			super("Gradient", false, true, true, true);

			_corner = 0;
			_item = item;

			_colorTopLeft = new Button();
			_colorTopLeft.label = "Color";
			_colorTopLeft.addEventListener(MouseEvent.CLICK, onColor, false, 0, true);
			container.addChild(_colorTopLeft);
			_colorTopRight = new Button();
			_colorTopRight.label = "Color";
			_colorTopRight.addEventListener(MouseEvent.CLICK, onColor, false, 0, true);
			container.addChild(_colorTopRight);
			_colorBottomLeft = new Button();
			_colorBottomLeft.label = "Color";
			_colorBottomLeft.addEventListener(MouseEvent.CLICK, onColor, false, 0, true);
			container.addChild(_colorBottomLeft);
			_colorBottomRight = new Button();
			_colorBottomRight.label = "Color";
			_colorBottomRight.addEventListener(MouseEvent.CLICK, onColor, false, 0, true);
			container.addChild(_colorBottomRight);

			_alphaTopLeft = new TextInput();
			_alphaTopLeft.text = item.getCornerAlpha(0).toString();
			_alphaTopLeft.addEventListener(KeyboardEvent.KEY_UP, onKeyUp1, false, 0, true);
			container.addChild(_alphaTopLeft);

			_alphaTopRight = new TextInput();
			_alphaTopRight.text = item.getCornerAlpha(1).toString();
			_alphaTopRight.addEventListener(KeyboardEvent.KEY_UP, onKeyUp2, false, 0, true);
			container.addChild(_alphaTopRight);

			_alphaBottomLeft = new TextInput();
			_alphaBottomLeft.text = item.getCornerAlpha(2).toString();
			_alphaBottomLeft.addEventListener(KeyboardEvent.KEY_UP, onKeyUp3, false, 0, true);
			container.addChild(_alphaBottomLeft);

			_alphaBottomRight = new TextInput();
			_alphaBottomRight.text = item.getCornerAlpha(3).toString();
			_alphaBottomRight.addEventListener(KeyboardEvent.KEY_UP, onKeyUp4, false, 0, true);
			container.addChild(_alphaBottomRight);

			init(WIDTH, HEIGHT);

			transparentDisable();
		}

		override protected function onResize( width:int, height:int ):void {
			_colorTopLeft.x = 0;
			_colorTopLeft.y = 0;

			_colorTopRight.x = width - _colorTopRight.width;
			_colorTopRight.y = 0;

			_colorBottomLeft.x = 0;
			_colorBottomLeft.y = height - _colorBottomLeft.height;

			_colorBottomRight.x = width - _colorBottomRight.width;
			_colorBottomRight.y = height - _colorBottomRight.height;

			_alphaTopLeft.x = 0;
			_alphaTopLeft.y = _colorTopLeft.y + _colorTopLeft.height;

			_alphaTopRight.x = width - _alphaTopRight.width;
			_alphaTopRight.y = _colorTopRight.y + _colorTopRight.height;

			_alphaBottomLeft.x = 0;
			_alphaBottomLeft.y = _colorBottomLeft.y - _alphaBottomLeft.height;

			_alphaBottomRight.x = width - _alphaBottomRight.width;
			_alphaBottomRight.y = _colorBottomRight.y - _alphaBottomRight.height;
		}

		private function onKeyUp1( e:KeyboardEvent ):void {
			onKeyUp(e, 0, _alphaTopLeft.text);
		}
		private function onKeyUp2( e:KeyboardEvent ):void {
			onKeyUp(e, 1, _alphaTopRight.text);
		}
		private function onKeyUp3( e:KeyboardEvent ):void {
			onKeyUp(e, 2, _alphaBottomLeft.text);
		}
		private function onKeyUp4( e:KeyboardEvent ):void {
			onKeyUp(e, 3, _alphaBottomRight.text);
		}
		private function onKeyUp( e:KeyboardEvent, corner:int, text:String ):void {
			if( e.keyCode == Keyboard.ENTER ) {
				var n:Number = Number( text );
				if( isNaN(n) ) {
					n = 0;
				}
				n = Math.max( 0, Math.min( 1, n) );

				_item.setCornerAlpha(corner, n);
			}
		}

		private function onColor( e:MouseEvent ):void {
			switch( e.target ) {
				case _colorTopLeft:
					_corner = 0;
				break;
				case _colorTopRight:
					_corner = 1;
				break;
				case _colorBottomLeft:
					_corner = 2;
				break;
				case _colorBottomRight:
					_corner = 3;
				break;
			}

			var dlg:ColorDialogue = new ColorDialogue( _item.getCornerColor(_corner) );
			dlg.onSelect.add( onColorSelect );
		}

		private function onColorSelect( color:uint ):void {
			_item.setCornerColor(_corner, color);
		}
	}
}
