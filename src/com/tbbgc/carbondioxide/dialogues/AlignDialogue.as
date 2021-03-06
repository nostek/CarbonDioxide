package com.tbbgc.carbondioxide.dialogues {
	import com.tbbgc.carbondioxide.managers.SettingsManager;
	import com.tbbgc.carbondioxide.models.DataModel;
	import com.tbbgc.carbondioxide.models.ItemModel;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * @author simonrodriguez
	 */
	public class AlignDialogue extends BaseDialogue {
		[Embed(source="../../../../../assets/align.png")]
		private var ALIGN:Class;

		[Embed(source="../../../../../assets/dist.png")]
		private var DIST:Class;

		private var _align:Bitmap;
		private var _dist:Bitmap;

		public function AlignDialogue() {
			const WIDTH:int = 211;
			const HEIGHT:int = 85;

			super("Align", true, false, false, true);

			var s:Sprite = new Sprite();
			_align = new ALIGN();
			s.addChild(_align);
			s.addEventListener(MouseEvent.CLICK, onClickAlign);
			s.buttonMode = true;
			container.addChild(s);

			var d:Sprite = new Sprite();
			_dist = new DIST();
			d.addChild(_dist);
			d.addEventListener(MouseEvent.CLICK, onClickDist);
			d.buttonMode = true;
			d.y = s.height + 5;
			container.addChild(d);

			init( WIDTH, HEIGHT );
		}

		override protected function get dialogueID():String { return SettingsManager.SETTINGS_ALIGN; }

		//////////////////////////////////////////

		private function onClickDist(e:MouseEvent):void {
			if( DataModel.SELECTED.length == 0 )
				return;

			var btn:int = _dist.mouseX/(_dist.width/6);

			switch( btn ) {
				case 0:
				break;
				case 1:
					distHor();
				break;
				case 2:
				break;
				case 3:
				break;
				case 4:
					distVer();
				break;
				case 5:
				break;
			}
		}

		private function distHor():void {
			const selected:Vector.<ItemModel> = DataModel.SELECTED;

			if( selected.length == 1 ) return;

			var min:int = int.MAX_VALUE;
			var max:int = int.MIN_VALUE;

			var obj:ItemModel;

			for each( obj in selected ) {
				min = Math.min( obj.item.x+(obj.item.width/2), min );
				max = Math.max( obj.item.x+(obj.item.width/2), max );
			}

			const div:int = (max-min);
			const m:int = selected.length-1;

			var index:int = 0;

			for each( obj in selected ) {
				obj.item.x = (min+div*(index/m))-(obj.item.width/2);

				index++;
			}
		}

		private function distVer():void {
			const selected:Vector.<ItemModel> = DataModel.SELECTED;

			if( selected.length == 1 ) return;

			var min:int = int.MAX_VALUE;
			var max:int = int.MIN_VALUE;

			var obj:ItemModel;

			for each( obj in selected ) {
				min = Math.min( obj.item.y+(obj.item.height/2), min );
				max = Math.max( obj.item.y+(obj.item.height/2), max );
			}

			const div:int = (max-min);
			const m:int = selected.length-1;

			var index:int = 0;

			for each( obj in selected ) {
				obj.item.y = (min+div*(index/m))-(obj.item.height/2);

				index++;
			}
		}

		//////////////////////////////////////////

		private function onClickAlign(e:MouseEvent):void {
			if( DataModel.SELECTED.length == 0 )
				return;

			var btn:int = _align.mouseX/(_align.width/6);

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
		}

		private function alignLeft():void {
			var min:int = int.MAX_VALUE;

			const selected:Vector.<ItemModel> = DataModel.SELECTED;
			var obj:ItemModel;

			for each( obj in selected ) {
				min = Math.min( obj.item.x, min );
			}

			for each( obj in selected ) {
				obj.item.x = min;
			}
		}

		private function alignXCenter():void {
			var min:int = int.MAX_VALUE;
			var max:int = int.MIN_VALUE;

			const selected:Vector.<ItemModel> = DataModel.SELECTED;
			var obj:ItemModel;

			for each( obj in selected ) {
				min = Math.min( obj.item.x, min );
				max = Math.max( obj.item.x+obj.item.width, max );
			}

			const middle:int = min + (max-min)/2;

			for each( obj in selected ) {
				obj.item.x = middle-(obj.item.width/2);
			}
		}

		private function alignRight():void {
			var max:int = int.MIN_VALUE;

			const selected:Vector.<ItemModel> = DataModel.SELECTED;
			var obj:ItemModel;

			for each( obj in selected ) {
				max = Math.max( obj.item.x+obj.item.width, max );
			}

			for each( obj in selected ) {
				obj.item.x = max-obj.item.width;
			}
		}

		private function alignTop():void {
			var min:int = int.MAX_VALUE;

			const selected:Vector.<ItemModel> = DataModel.SELECTED;
			var obj:ItemModel;

			for each( obj in selected ) {
				min = Math.min( obj.item.y, min );
			}

			for each( obj in selected ) {
				obj.item.y = min;
			}
		}

		private function alignYCenter():void {
			var min:int = int.MAX_VALUE;
			var max:int = int.MIN_VALUE;

			const selected:Vector.<ItemModel> = DataModel.SELECTED;
			var obj:ItemModel;

			for each( obj in selected ) {
				min = Math.min( obj.item.y, min );
				max = Math.max( obj.item.y+obj.item.height, max );
			}

			const middle:int = min + (max-min)/2;

			for each( obj in selected ) {
				obj.item.y = middle-(obj.item.height/2);
			}
		}

		private function alignBottom():void {
			var max:int = int.MIN_VALUE;

			const selected:Vector.<ItemModel> = DataModel.SELECTED;
			var obj:ItemModel;

			for each( obj in selected ) {
				max = Math.max( obj.item.y+obj.item.height, max );
			}

			for each( obj in selected ) {
				obj.item.y = max-obj.item.height;
			}
		}
	}
}
