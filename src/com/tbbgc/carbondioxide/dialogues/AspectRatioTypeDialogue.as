package com.tbbgc.carbondioxide.dialogues {
	import fl.controls.Button;

	import com.tbbgc.carbondioxide.models.cd.CDAspectRatio;

	import org.osflash.signals.Signal;

	import flash.events.MouseEvent;

	/**
	 * @author simonrodriguez
	 */
	public class AspectRatioTypeDialogue extends BaseDialogue {
		private var _onSelect:Signal;

		private var _both:Button;
		private var _width:Button;
		private var _height:Button;

		public function AspectRatioTypeDialogue() {
			const WIDTH:int = 300;
			const HEIGHT:int = 75;

			_onSelect = new Signal( int );

			super("Aspect Ratio Type", false, true, false, true);

			_both = new Button();
			_both.label = "BOTH";
			_both.addEventListener(MouseEvent.CLICK, onButtonBoth);
			container.addChild(_both);

			_width = new Button();
			_width.label = "WIDTH";
			_width.addEventListener(MouseEvent.CLICK, onButtonWidth);
			container.addChild(_width);

			_height = new Button();
			_height.label = "HEIGHT";
			_height.addEventListener(MouseEvent.CLICK, onButtonHeight);
			container.addChild(_height);

			init(WIDTH, HEIGHT);
		}

		override protected function onResize( width:int, height:int ):void {
			_both.width = width / 2;
			_width.width = _height.width = width/4;

			_both.y = _width.y = _height.y = height - _both.height;

			_width.x = 0;
			_height.x = width - _height.width;
			_both.x = _width.width;
		}

		override protected function close():void {
			_onSelect.removeAll();

			super.close();
		}

		public function get onSelect():Signal { return _onSelect; }

		private function onButtonBoth(e:MouseEvent):void {
			_onSelect.dispatch( CDAspectRatio.ALIGN_BOTH );
			close();
		}

		private function onButtonWidth(e:MouseEvent):void {
			_onSelect.dispatch( CDAspectRatio.ALIGN_WIDTH );
			close();
		}

		private function onButtonHeight(e:MouseEvent):void {
			_onSelect.dispatch( CDAspectRatio.ALIGN_HEIGHT );
			close();
		}
	}
}
