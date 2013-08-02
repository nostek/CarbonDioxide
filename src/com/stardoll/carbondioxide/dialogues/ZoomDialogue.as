package com.stardoll.carbondioxide.dialogues {
	import fl.controls.CheckBox;
	import fl.controls.UIScrollBar;
	import fl.events.ScrollEvent;

	import com.stardoll.carbondioxide.components.TreeDisplay;

	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author simonrodriguez
	 */
	public class ZoomDialogue extends BaseDialogue {
		private var _magnify:CheckBox;
		private var _zoomSlider:UIScrollBar;

		public function ZoomDialogue() {
			const WIDTH:int = 200;
			const HEIGHT:int = 100;

			super("Zoom", true, false, true, true);

			_magnify = new CheckBox();
			_magnify.selected = false;
			_magnify.label = "Magnify";
			_magnify.textField.autoSize = TextFieldAutoSize.LEFT;
				var fmt:TextFormat = _magnify.textField.defaultTextFormat;
				fmt.color=0xffffffff;
				_magnify.setStyle("textFormat", fmt);
			_magnify.addEventListener(Event.CHANGE, onMagnify);
			container.addChild(_magnify);

			_zoomSlider = new UIScrollBar();
			_zoomSlider.direction = "horizontal";
			_zoomSlider.minScrollPosition = 0;
			_zoomSlider.maxScrollPosition = 100;
			_zoomSlider.addEventListener(ScrollEvent.SCROLL, onZoomScreen);
			container.addChild(_zoomSlider);

			init(WIDTH, HEIGHT);
		}

		override protected function onResize( width:int, height:int ):void {
			_zoomSlider.y = height - _zoomSlider.height;
			_zoomSlider.width = width;
		}

		private function onMagnify(e:Event):void {
			onZoomScreen(null);
		}

		private function onZoomScreen(e:ScrollEvent):void {
			var t:Number = ((100-_zoomSlider.scrollPosition)/_zoomSlider.maxScrollPosition);

			TreeDisplay.doZoom.dispatch( (_magnify.selected) ? 1 + 5 * (1-t) : t );
		}
	}
}
