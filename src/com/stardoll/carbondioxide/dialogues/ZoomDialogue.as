package com.stardoll.carbondioxide.dialogues {
	import fl.controls.CheckBox;
	import fl.controls.UIScrollBar;
	import fl.events.ScrollEvent;

	import com.stardoll.carbondioxide.components.TreeDisplay;
	import com.stardoll.carbondioxide.managers.SettingsManager;
	import com.stardoll.carbondioxide.utils.MathEx;

	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author simonrodriguez
	 */
	public class ZoomDialogue extends BaseDialogue {
		public static var doMagnify:Boolean = false;
		public static var doPercent:Number = 1;

		public static function doZoom():void {
			TreeDisplay.doZoom.dispatch( (doMagnify) ? 1 + 5 * (1-doPercent) : doPercent );
		}

		/////

		private var _magnify:CheckBox;
		private var _zoomSlider:UIScrollBar;

		public function ZoomDialogue() {
			const WIDTH:int = 200;
			const HEIGHT:int = 100;

			super("Zoom", true, false, true, true);

			_magnify = new CheckBox();
			_magnify.selected = ZoomDialogue.doMagnify;
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
			_zoomSlider.scrollPosition = MathEx.lerp(0, 100, doPercent);
			_zoomSlider.addEventListener(ScrollEvent.SCROLL, onZoomScreen);
			container.addChild(_zoomSlider);

			init(WIDTH, HEIGHT);
		}

		override protected function get dialogueID():String { return SettingsManager.SETTINGS_ZOOM; }

		override protected function onResize( width:int, height:int ):void {
			_zoomSlider.y = height - _zoomSlider.height;
			_zoomSlider.width = width;
		}

		private function onMagnify(e:Event):void {
			doMagnify = !doMagnify;
			doZoom();
		}

		private function onZoomScreen(e:ScrollEvent):void {
			doPercent = ((100-_zoomSlider.scrollPosition)/_zoomSlider.maxScrollPosition);
			doZoom();
		}
	}
}
