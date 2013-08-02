package com.stardoll.carbondioxide {
	import com.stardoll.carbondioxide.dialogues.PropertiesDialogue;
	import com.stardoll.carbondioxide.components.Menu;
	import com.stardoll.carbondioxide.components.StatusBar;
	import com.stardoll.carbondioxide.components.TreeDisplay;
	import com.stardoll.carbondioxide.dialogues.AssetsDialogue;
	import com.stardoll.carbondioxide.dialogues.BaseDialogue;
	import com.stardoll.carbondioxide.dialogues.ItemsDialogue;
	import com.stardoll.carbondioxide.managers.ViewsManager;
	import com.stardoll.carbondioxide.models.DataModel;
	import com.stardoll.carbondioxide.models.cd.CDAspectRatio;
	import com.stardoll.carbondioxide.models.cd.CDItem;
	import com.stardoll.carbondioxide.models.cd.CDResolution;
	import com.stardoll.carbondioxide.models.cd.CDView;

	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	public class CarbonDioxide extends Sprite {
		private var _tree:TreeDisplay;
		private var _status:StatusBar;

		public function CarbonDioxide() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;
			stage.frameRate = 31;
			stage.color = 0x646464;

			stage.doubleClickEnabled = true;

			new DataModel();

			var bg:Bitmap = new Bitmap( DataModel.BG.bitmapData );
			addChild(bg);

			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

			new Menu( stage );

			new ViewsManager();
			new DataModel();

			_tree = new TreeDisplay();
			addChild(_tree);

			_status = new StatusBar( stage );
			addChild(_status);

			BaseDialogue.DIALOGUES = new Sprite();
			addChild(BaseDialogue.DIALOGUES);

			new AssetsDialogue( false );
			new ItemsDialogue( false );
			new PropertiesDialogue( false );

			test();

//			DataModel.setResolution(1000, 700);
			DataModel.setView( ViewsManager.getViewByName("main") );

//			DataModel.setLayer( ViewsManager.getViewByName("main").getChildByName("test") );
		}

		private function onKeyDown(e:KeyboardEvent):void {
			if( e.shiftKey ) {
				DataModel.SHIFT_KEY = true;
			}
			if( e.keyCode == Keyboard.ALTERNATE ) {
				DataModel.ALT_KEY = true;
			}
//			DataModel.setResolution(1400, 700);
		}

		private function onKeyUp(e:KeyboardEvent):void {
//			DataModel.setResolution(1400, 700);
			if( DataModel.SHIFT_KEY && !e.shiftKey ) {
				DataModel.SHIFT_KEY = false;
			}
			if( DataModel.ALT_KEY && e.keyCode == Keyboard.ALTERNATE ) {
				DataModel.ALT_KEY = false;
			}
		}

		private function test():void {
			var view:CDView = ViewsManager.addView( new CDView("main") );

			var item:CDItem = view.addChild( new CDItem(view, "test") );

			var res:CDResolution = new CDResolution(1000, 700);
			res.x 		= CDItem.toPercent(50, 1000);
			res.y 		= CDItem.toPercent(50, 700);
			res.width 	= CDItem.toPercent(900, 1000);
			res.height 	= CDItem.toPercent(600, 700);
			item.addResolution(res);

			var ch1:CDItem = item.addChild( new CDItem(item, "child1") );
			res 		= new CDResolution(1000, 700);
			res.x 		= CDItem.toPercent(10, 900);
			res.y 		= CDItem.toPercent(10, 600);
			res.width 	= CDItem.toPercent(50, 900);
			res.height 	= CDItem.toPercent(50, 600);
			ch1.addResolution(res);

			var ch2:CDItem = item.addChild( new CDItem(item, "child2") );
			res 		= new CDResolution(1000, 700);
			res.x 		= CDItem.toPercent(840, 900);
			res.y 		= CDItem.toPercent(10, 600);
			res.width 	= CDItem.toPercent(50, 900);
			res.height 	= CDItem.toPercent(50, 600);
			ch2.addResolution(res);

			item.aspectRatio = CDAspectRatio.BOTTOM_RIGHT;

			item.asset = "overlay_big_suiteshop_bg";
			ch1.asset = "avatar_180x180";
			ch2.asset = "avatar_180x180";

			////

			view = ViewsManager.addView( new CDView("main2") );

			item = view.addChild( new CDItem(view, "test2") );

			res = new CDResolution(1000, 700);
			res.x 		= CDItem.toPercent(50, 1000);
			res.y 		= CDItem.toPercent(50, 700);
			res.width 	= CDItem.toPercent(300, 1000);
			res.height 	= CDItem.toPercent(400, 700);
			item.addResolution(res);
		}
	}
}
