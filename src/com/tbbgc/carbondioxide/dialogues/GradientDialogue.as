package com.tbbgc.carbondioxide.dialogues {
	import fl.controls.Button;

	import com.tbbgc.carbondioxide.models.cd.CDGradient;

	import flash.events.MouseEvent;

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

		private var _corner:int;

		private var _item:CDGradient;

		public function GradientDialogue( item:CDGradient ) {
			const WIDTH:int = 250;
			const HEIGHT:int = 150;

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

			var dlg:ColorDialogue = new ColorDialogue( _item.getCornerColor(_corner), _item.getCornerAlpha(_corner) );
			dlg.onSelect.add( onColorSelect );
		}

		private function onColorSelect( color:uint, alpha:Number ):void {
			_item.setCornerColor(_corner, color);
			_item.setCornerAlpha(_corner, alpha);
		}
	}
}
