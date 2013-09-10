package com.stardoll.UIDesigner.dialogues {
	import com.stardoll.UIDesigner.components.DisplayItem;
	import com.stardoll.UIDesigner.models.DataModel;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * @author simonrodriguez
	 */
	public class AlignDialogue extends BaseDialogue {
		[Embed(source="../../../../../assets/align.png")]
		private var ALIGN:Class;

		private var _align:Bitmap;

		public function AlignDialogue() {
			const WIDTH:int = 211;
			const HEIGHT:int = 50;

			var s:Sprite = new Sprite();
			_align = new ALIGN();
			s.addChild(_align);
			s.x = s.y = 10;
			s.addEventListener(MouseEvent.CLICK, onClickAlign);
			addChild(s);

			super(WIDTH, HEIGHT, "Align", true, false, false);

			this.x = 970;
			this.y = 10;

			minimize();
		}

		private function onClickAlign(e:MouseEvent):void {
			if( DataModel.transform.selectedItems.length == 0 )
				return;

			var btn:int = _align.mouseX/(_align.width/6);

			DataModel.onItemSaveUndo.dispatch();

			switch( btn ) {
				case 0:
					alignLeft();
				break;
				case 1:
					alignXCenter();
				break;
				case 2:
					alignRight();
				break;
				case 3:
					alignTop();
				break;
				case 4:
					alignYCenter();
				break;
				case 5:
					alignBottom();
				break;
			}

			DataModel.onItemSave.dispatch();
		}

		private function alignLeft():void {
			var min:int = 50000;

			var selected:Array = DataModel.transform.selectedTargetObjects;
			var obj:DisplayItem;

			for each( obj in selected ) {
				min = Math.min( obj.x, min );
			}

			for each( obj in selected ) {
				obj.x = min;
			}
		}
		private function alignXCenter():void {
			var min:int = 50000;
			var max:int = -50000;

			var selected:Array = DataModel.transform.selectedTargetObjects;
			var obj:DisplayItem;

			for each( obj in selected ) {
				min = Math.min( obj.x, min );
				max = Math.max( obj.x+obj.width, max );
			}

			var middle:int = min + (max-min)/2;

			for each( obj in selected ) {
				obj.x = middle-obj.width/2;
			}
		}
		private function alignRight():void {
			var max:int = -50000;

			var selected:Array = DataModel.transform.selectedTargetObjects;
			var obj:DisplayItem;

			for each( obj in selected ) {
				max = Math.max( obj.x+obj.width, max );
			}

			for each( obj in selected ) {
				obj.x = max-obj.width;
			}
		}
		private function alignTop():void {
			var min:int = 50000;

			var selected:Array = DataModel.transform.selectedTargetObjects;
			var obj:DisplayItem;

			for each( obj in selected ) {
				min = Math.min( obj.y, min );
			}

			for each( obj in selected ) {
				obj.y = min;
			}
		}
		private function alignYCenter():void {
			var min:int = 50000;
			var max:int = -50000;

			var selected:Array = DataModel.transform.selectedTargetObjects;
			var obj:DisplayItem;

			for each( obj in selected ) {
				min = Math.min( obj.y, min );
				max = Math.max( obj.y+obj.height, max );
			}

			var middle:int = min + (max-min)/2;

			for each( obj in selected ) {
				obj.y = middle-obj.height/2;
			}
		}
		private function alignBottom():void {
			var max:int = -50000;

			var selected:Array = DataModel.transform.selectedTargetObjects;
			var obj:DisplayItem;

			for each( obj in selected ) {
				max = Math.max( obj.y+obj.height, max );
			}

			for each( obj in selected ) {
				obj.y = max-obj.height;
			}
		}
	}
}
