package com.stardoll.carbondioxide.dialogues {
	import com.stardoll.carbondioxide.models.DataModel;

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

		public function ColorDialogue() {
			const WIDTH:int = 199+EDGE+EDGE;
			const HEIGHT:int = 232+HEADER+EDGE;

			super("Select Color", false, true, false, false);

			var s:Sprite = new Sprite();
			s.addEventListener(MouseEvent.CLICK, onClick);
			container.addChild(s);

			_colors = new COLORS();
			s.addChild(_colors);

			init( WIDTH, HEIGHT );
		}

		override protected function onResize( width:int, height:int ):void {
		}

		private function onClick(e:MouseEvent):void {
			DataModel.setBGColor( _colors.bitmapData.getPixel( e.localX, e.localY ) );

			close();
		}
	}
}
