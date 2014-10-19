package com.tbbgc.carbondioxide.dialogues {
	import fl.controls.CheckBox;
	import fl.controls.List;
	import fl.controls.Slider;
	import fl.events.SliderEvent;

	import com.tbbgc.carbondioxide.models.DataModel;
	import com.tbbgc.carbondioxide.models.resolutions.ResolutionsModel;

	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author simonrodriguez
	 */
	public class DPIDialogue extends BaseDialogue {
		private var _list:List;

		private var _portrait:CheckBox;
		private var _landscape:CheckBox;

		private var _displays:Slider;

		private var _name:TextField;

		private var _curr:String;

		public function DPIDialogue() {
			const WIDTH:int = 420;
			const HEIGHT:int = 420;

			super("DPI", true, false, false, true);

			_curr = "";

			_portrait = new CheckBox();
			_portrait.addEventListener(Event.CHANGE, onCheckbox);
			_portrait.label = "Portrait";
			_portrait.selected = true;
			_portrait.textField.autoSize = TextFieldAutoSize.LEFT;
				var fmt:TextFormat = _portrait.textField.defaultTextFormat;
				fmt.color=0xffffffff;
				_portrait.setStyle("textFormat", fmt);
			container.addChild(_portrait);

			_landscape = new CheckBox();
			_landscape.addEventListener(Event.CHANGE, onCheckbox);
			_landscape.label = "Landscape";
			_landscape.x = WIDTH - _landscape.width;
			_landscape.selected = true;
			_landscape.textField.autoSize = TextFieldAutoSize.LEFT;
				_landscape.setStyle("textFormat", fmt);
			container.addChild(_landscape);

			_list = new List();
			_list.allowMultipleSelection = true;
			_list.y = _portrait.height;
			_list.width = 400;
			_list.height = 300;
			_list.addEventListener(Event.CHANGE, onSelectedChanged);
			container.addChild(_list);

			_displays = new Slider();
			_displays.width = _list.width-20;
			_displays.x = 10;
			_displays.y = _list.y+_list.height + 20;
			_displays.visible = false;
			_displays.addEventListener(SliderEvent.THUMB_DRAG, onChange);
			container.addChild(_displays);

			_name = new TextField();
			_name.y = _displays.y + _displays.height + 15;
			_name.x = _displays.x + (_displays.width - _name.width) / 2;
			_name.autoSize = TextFieldAutoSize.LEFT;
			_name.wordWrap = _name.multiline = _name.selectable = false;
			_name.defaultTextFormat = fmt;
			_name.text = "";
			container.addChild(_name);

			init( WIDTH, HEIGHT );

			populate();

			if( DataModel.COMPUTER_SCREEN_SIZE == -1 ) {
				var dlg:InputDialogue = new InputDialogue("Screen Size", "Enter your monitors inch size", "27");
				dlg.onOK.addOnce( onScreenSize );
			}
		}

		override protected function onResize( width:int, height:int ):void {
		}

		private function onScreenSize( dlg:InputDialogue ):void {
			var t:String = dlg.text;

			if( t != null && t != "" ) {
				var n:Number = Number(t);
				if( !isNaN(n) ) {
					DataModel.COMPUTER_SCREEN_SIZE = int(n);
				}
			}
		}

		private function onCheckbox( e:Event ):void {
			populate();

			onSelectedChanged(null);
		}

		private function populate():void {
			_list.removeAll();

			var reses:Array = ResolutionsModel.resolutions;

			reses = reses.sort( sort );

			var w:int;
			var h:int;

			for each( var o:Object in reses ) {
				w = o["width"];
				h = o["height"];

				if( _portrait.selected ) {
					if( w < h ) {
						_list.addItem({label:String(o["label"])});
					}
				}
				if( _landscape.selected ) {
					if( w > h ) {
						_list.addItem({label:String(o["label"])});
					}
				}
			}
		}

		private static function sort( a:Object, b:Object ):int {
			if( Number(a["size"]) == Number(b["size"]) ) {
				var ai:int = a["width"] * a["height"];
				var bi:int = b["width"] * b["height"];
				if( ai == bi ) return 0;
				return (ai < bi) ? -1 : 1;
			}
			return (Number(a["size"]) < Number(b["size"])) ? -1 : 1;
		}

		private static function sortNum( a:int, b:int ):int {
			if( a == b ) return 0;
			return (a < b) ? -1 : 1;
		}

		private function onSelectedChanged( e:Event ):void {
			const len:int = _list.selectedItems.length;
			if( len == 0 ) {
				_displays.visible = false;
			} else {
				_displays.visible = true;

				_displays.maximum = len-1;
			}
		}

		private function onChange( e:Event ):void {
			var sel:Array = _list.selectedIndices;
			sel = sel.sort( sortNum );

			var curr:String = _list.getItemAt(sel[ _displays.value ])["label"];

			if( curr != _curr ) {
				_curr = curr;
				_name.text = curr;
				_name.x = _displays.x + (_displays.width - _name.width) / 2;
				DataModel.onChangeResolution.dispatch( _curr );
				DataModel.onSetRealSize.dispatch();
			}
		}
	}
}
