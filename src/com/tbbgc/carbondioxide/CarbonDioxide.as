package com.tbbgc.carbondioxide {
	import fl.controls.listClasses.CellRenderer;

	import com.tbbgc.carbondioxide.components.Menu;
	import com.tbbgc.carbondioxide.components.StatusBar;
	import com.tbbgc.carbondioxide.components.TreeDisplay;
	import com.tbbgc.carbondioxide.copypaste.CutCopyPaste;
	import com.tbbgc.carbondioxide.dialogues.AssetsDialogue;
	import com.tbbgc.carbondioxide.dialogues.BaseDialogue;
	import com.tbbgc.carbondioxide.dialogues.PopupDialogue;
	import com.tbbgc.carbondioxide.dialogues.PropertiesDialogue;
	import com.tbbgc.carbondioxide.dialogues.TreeDialogue;
	import com.tbbgc.carbondioxide.dialogues.ZoomDialogue;
	import com.tbbgc.carbondioxide.managers.AssetsManager;
	import com.tbbgc.carbondioxide.managers.EventManager;
	import com.tbbgc.carbondioxide.managers.SettingsManager;
	import com.tbbgc.carbondioxide.managers.UndoManager;
	import com.tbbgc.carbondioxide.managers.ViewsManager;
	import com.tbbgc.carbondioxide.models.DataModel;
	import com.tbbgc.carbondioxide.models.ItemModel;
	import com.tbbgc.carbondioxide.models.cd.CDItem;
	import com.tbbgc.carbondioxide.saveload.Load;

	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;

	public class CarbonDioxide extends Sprite {
		private var _blockSave:Boolean;

		private var _tree:TreeDisplay;
		private var _status:StatusBar;

		public function CarbonDioxide() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.BEST;
			stage.frameRate = 31;
			stage.color = 0x262626;

			stage.nativeWindow.title += " " + getAppDescVersion();

			stage.doubleClickEnabled = true;

			_blockSave = true;

			setTimeout( init, 50 );
		}

		private function init():void {
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtErrorHandler);

			new SettingsManager();
			new DataModel();
			new EventManager( stage );
			new CutCopyPaste();
			new UndoManager();
			new Menu( stage );
			new ViewsManager();
			new AssetsManager();

			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, true, 10000);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, true, 10000);

			stage.addEventListener(MouseEvent.CLICK, onClick);
			stage.addEventListener(MouseEvent.DOUBLE_CLICK, onDblClick);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);

			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
			stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVE, onSaveWindow);
			stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, onSaveWindow);

			_tree = new TreeDisplay();
			addChild(_tree);

			_status = new StatusBar( stage );
			addChild(_status);

			BaseDialogue.DIALOGUES = addChild( new Sprite() ) as Sprite;

			new TreeDialogue( false );
			new PropertiesDialogue( false );
			new AssetsDialogue( false );

			setTimeout( onFirst, 50 );
		}

		private function getAppDescVersion( label:Boolean=false ):String {
			var version:String;

			/*FDT_IGNORE*/
			var xml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = xml.namespace();
			version = xml.ns::versionNumber;

			if( label ) {
				version += " " + xml.ns::versionLabel;
			}
			/*FDT_IGNORE*/

			return version;
		}

		private function onFirst():void {
			if( SettingsManager.haveItem(SettingsManager.SETTINGS_WINDOW) ) {
				var data:Object = SettingsManager.getItem(SettingsManager.SETTINGS_WINDOW);

				stage.nativeWindow.x = data["x"] as Number;
				stage.nativeWindow.y = data["y"] as Number;
				stage.nativeWindow.width = data["w"] as Number;
				stage.nativeWindow.height = data["h"] as Number;
			}

			Load.runLast();
			AssetsManager.load();

			_blockSave = false;
		}

		private function onDblClick(e:MouseEvent):void {
			if( e.target == stage && DataModel.currentView != null ) {
				DataModel.setLayer( DataModel.currentView );
			}
		}

		private function onClick(e:MouseEvent):void {
			if( e.target == stage || e.target == _tree ) {
				stage.focus = null;
			}
		}

		private function onMouseWheel(e:MouseEvent):void {
			var o:DisplayObject = e.target as DisplayObject;
			if( o == null ) return;
			while( o != stage ) {
				if( o == BaseDialogue.DIALOGUES ) return;
				if( o is CellRenderer ) return;
				o = o.parent;
			}

			var d:Number = ZoomDialogue.doMagnify ? -e.delta : e.delta;
			ZoomDialogue.doPercent = Math.min( 1, Math.max( 0, ZoomDialogue.doPercent + d*0.01 ) );
			ZoomDialogue.doZoom( true );
		}

		private function onSaveWindow(e:NativeWindowBoundsEvent):void {
			if( _blockSave  ) {
				return;
			}

			SettingsManager.setItem(SettingsManager.SETTINGS_WINDOW, {
				x: stage.nativeWindow.x,
				y: stage.nativeWindow.y,
				w: stage.nativeWindow.width,
				h: stage.nativeWindow.height
			});
		}

		private function onUncaughtErrorHandler(event:UncaughtErrorEvent):void {
			var msg:String = "";

			if (event.error is Error)
			{
				var error:Error = event.error as Error;
				msg = JSON.stringify({error_name:error.name, error_id:error.errorID, error_message:error.message, error_stack:error.getStackTrace()});
			}
			else if (event.error is ErrorEvent)
			{
				var errorEvent:ErrorEvent = event.error as ErrorEvent;
				msg = JSON.stringify({error2:errorEvent.text});
			}

			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, msg);

			new PopupDialogue("CRASH", msg);
		}

		private function onExiting(e:Event):void {
			Load.removeLock();
		}

		private function onKeyDown(e:KeyboardEvent):void {
			if( e.shiftKey ) {
				DataModel.SHIFT_KEY = true;
			}
			if( e.keyCode == Keyboard.ALTERNATE ) {
				DataModel.ALT_KEY = true;
			}
			if( e.commandKey || e.controlKey ) {
				DataModel.COMMAND_KEY = true;
			}

			if( BaseDialogue.BLOCK_MENU ) {
				return;
			}

			if( DataModel.COMMAND_KEY && DataModel.SHIFT_KEY && !DataModel.ALT_KEY ) {
				var holder:ItemModel;
				var item:CDItem;

				if( e.keyCode == Keyboard.UP ) {
					for each( holder in DataModel.SELECTED ) {
						item = holder.item;
						if( item != null ) {
							item.parent.setChildIndex(item, item.parent.getChildIndex(item)+1);
						}
					}
				}
				if( e.keyCode == Keyboard.DOWN ) {
					for each( holder in DataModel.SELECTED ) {
						item = holder.item;
						if( item != null ) {
							item.parent.setChildIndex(item, item.parent.getChildIndex(item)-1);
						}
					}
				}
			}

			if( !DataModel.COMMAND_KEY && !DataModel.SHIFT_KEY && !DataModel.ALT_KEY && e.keyCode == Keyboard.DELETE ) {
				var sel:Vector.<ItemModel> = DataModel.SELECTED.concat();
				for each( var itemmodel:ItemModel in sel ) {
					itemmodel.item.parent.removeChild( itemmodel.item );
				}
			}

			if( !DataModel.COMMAND_KEY && !DataModel.SHIFT_KEY && !DataModel.ALT_KEY && e.keyCode == Keyboard.ESCAPE ) {
				if( DataModel.currentLayer != DataModel.currentView ) {
					DataModel.setLayer( DataModel.currentLayer.parent );
					TreeDisplay.doSelectItems.dispatch( [] );
				}
			}

//			Need better key. Select all.
//			if( DataModel.COMMAND_KEY && !DataModel.SHIFT_KEY && !DataModel.ALT_KEY && e.keyCode == Keyboard.A ) {
//				var a:Array = [];
//				for each( item in DataModel.currentLayer.children ) {
//					a.push( item );
//				}
//				EventManager.selectItems(a);
//			}
		}

		private function onKeyUp(e:KeyboardEvent):void {
			if( DataModel.SHIFT_KEY && !e.shiftKey ) {
				DataModel.SHIFT_KEY = false;
			}
			if( DataModel.ALT_KEY && e.keyCode == Keyboard.ALTERNATE ) {
				DataModel.ALT_KEY = false;
			}
			if( DataModel.COMMAND_KEY && !e.commandKey && !e.controlKey ) {
				DataModel.COMMAND_KEY = false;
			}
		}
	}
}
