package com.stardoll.carbondioxide.components {
	import com.stardoll.carbondioxide.copypaste.CutCopyPaste;
	import com.stardoll.carbondioxide.dialogues.AlignDialogue;
	import com.stardoll.carbondioxide.dialogues.AssetsDialogue;
	import com.stardoll.carbondioxide.dialogues.BaseDialogue;
	import com.stardoll.carbondioxide.dialogues.ColorDialogue;
	import com.stardoll.carbondioxide.dialogues.FindAssetsDialogue;
	import com.stardoll.carbondioxide.dialogues.PropertiesDialogue;
	import com.stardoll.carbondioxide.dialogues.TreeDialogue;
	import com.stardoll.carbondioxide.dialogues.ZoomDialogue;
	import com.stardoll.carbondioxide.managers.UndoManager;
	import com.stardoll.carbondioxide.models.DataModel;
	import com.stardoll.carbondioxide.models.ItemModel;
	import com.stardoll.carbondioxide.models.cd.CDItem;
	import com.stardoll.carbondioxide.saveload.Load;
	import com.stardoll.carbondioxide.saveload.Save;
	import com.stardoll.carbondioxide.utils.Drawer;
	import com.stardoll.carbondioxide.utils.Images;

	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	/**
	 * @author simonrodriguez
	 */
	public class Menu {
		private var _stage:Stage;

		public function Menu( stage:Stage ) {
			_stage = stage;

			setupMenu([
				{
					name: "File",

					children: [
						{
							name: "Open",
							callback: onOpen
						},
						{
							name: "Open Silent",
							callback: onOpenSilent
						},
						{
							name: "Save",
							shortcut: "s",
							callback: onSave
						},
						{
							name: "Save As",
							callback: onSaveNew
						},
						{
							name: "Export",
							callback: onExport
						},
						{
							name: "Close",
							callback: onExit,
							shortcut: "w"
						},
						{
							name: "Exit",
							callback: onExit,
							shortcut: "q"
						},
					]
				},

				{
					name: "Edit",

					children: [
						{
							name: "Undo",
							shortcut: "z",
							callback: onUndo
						},
						{
							name: "Redo",
							shortcut: "y",
							callback: onRedo
						},
						{
							name: "Cut",
							shortcut: "x",
							callback: onCut
						},
						{
							name: "Copy",
							shortcut: "c",
							callback: onCopy
						},
						{
							name: "Paste",
							shortcut: "v",
							callback: onPaste
						},
						{
							name: "Delete selected",
							shortcut: "d",
							callback: onDelete
						}
					]
				},

				{
					name: "Windows",
					children: [
						{
							name: "[RESET WINDOWS]",
							callback: onResetWindows
						},
						{
							name: "Assets",
							callback: onAssets
						},
						{
							name: "Tree",
							callback: onTree
						},
						{
							name: "Properties",
							callback: onProperties
						},
						{
							name: "Find asset",
							callback: onFind
						},
						{
							name: "Zoom",
							callback: onZoomDlg
						},
						{
							name: "Color",
							callback: onColor
						},
						{
							name: "Align",
							callback: onAlign
						},
					]
				},

				{
					name: "Zoom",
					children: [
						{
							name: "Magnify",
							callback: onZoomMagnify,
							shortcut: "m"
						},
						{
							name: "-",
							callback: onZoomMinus,
							shortcut: ","
						},
						{
							name: "+",
							callback: onZoomPlus,
							shortcut: "."
						},
					]
				},

				{
					name: "Options",
					children: [
						{
							name: "Lock child positions on scale",
							callback: onLockChildPosition
						},
						{
							name: "Lock child scale on scale",
							callback: onLockChildScale
						},
						{
							name: "Lock child world position",
							callback: onLockChildWorldPosition
						},
						{
							name: "Original Width/Height",
							callback: onOrigWidthHeight,
							shortcut: "o"
						},
						{
							name: "Wacom friendly copypaste",
							callback: onWacomCopyPaste,
							enabled: CutCopyPaste.WACOM_COPYPASTE
						},
					]
				},

				{
					name: "Window",
					children: [
						{
							name: "Minimize",
							callback: onMinimize
						},
						{
							name: "Zoom",
							callback: onZoom
						}
					]
				}
			]);
		}

		private function setupMenu( struct:Object ):void {
			var menu:NativeMenu = new NativeMenu();

			for each( var obj:Object in struct ) {
				setupMenuRect( obj, menu );
			}

			if( NativeApplication.supportsMenu ) {
				NativeApplication.nativeApplication.menu = menu;
			}

			if( NativeWindow.supportsMenu ) {
				_stage.nativeWindow.menu = menu;
			}
		}

		private function setupMenuRect( struct:Object, parent:NativeMenu ):void {
			var itm:NativeMenuItem = new NativeMenuItem( struct["name"] );

			var children:Object = struct["children"];
			if( children != null ) {
				var sub:NativeMenu = new NativeMenu();

				for each( var obj:Object in children ) {
					setupMenuRect( obj, sub );
				}

				itm.submenu = sub;
			}

			if( struct["callback"] != null ) {
				itm.addEventListener(Event.SELECT, struct["callback"]);
			}

			if( struct["enabled"] != null ) {
				itm.checked = struct["enabled"] as Boolean;
			}

			if( struct["shortcut"] != null ) {
				itm.keyEquivalent = struct["shortcut"];
			}
			if( struct["shortcutMod"] != null ) {
				itm.keyEquivalentModifiers = struct["shortcutMod"];
			}

			parent.addItem(itm);
		}

		////////////////////

		private function onExit( e:Event ):void {
		    var exitingEvent:Event = new Event(Event.EXITING, false, true);
		    NativeApplication.nativeApplication.dispatchEvent(exitingEvent);
		    if (!exitingEvent.isDefaultPrevented()) {
		        NativeApplication.nativeApplication.exit();
		    }
		}

		private function onMinimize( e:Event ):void {
			_stage.nativeWindow.minimize();
		}

		private function onZoom( e:Event ):void {
			_stage.nativeWindow.maximize();
		}

		private function onAssets( e:Event ):void {
			new AssetsDialogue();
		}

		private function onTree( e:Event ):void {
			new TreeDialogue();
		}

		private function onProperties( e:Event ):void {
			new PropertiesDialogue();
		}

		private function onFind( e:Event ):void {
			new FindAssetsDialogue();
		}

		private function onZoomDlg( e:Event ):void {
			new ZoomDialogue();
		}

		private function onAlign( e:Event ):void {
			new AlignDialogue();
		}

		private function onResetWindows( e:Event ):void {
			var d:DisplayObject;

			const len:int = BaseDialogue.DIALOGUES.numChildren;
			for( var i:int = 0; i < len; i++ ) {
				d = BaseDialogue.DIALOGUES.getChildAt(i);
				d.x = 0;
				d.y = 0;
			}
		}

		private function onColor( e:Event ):void {
			var dlg:ColorDialogue = new ColorDialogue();
			dlg.onSelect.addOnce( _onSelectColor );
		}
		private function _onSelectColor( color:uint ):void {
			DataModel.setBGColor( color );
		}

		private function onZoomMagnify( e:Event ):void {
			if( BaseDialogue.BLOCK_MENU ) return;
			ZoomDialogue.doMagnify = !ZoomDialogue.doMagnify;
			ZoomDialogue.doZoom( false );
		}
		private function onZoomMinus( e:Event ):void {
			if( BaseDialogue.BLOCK_MENU ) return;
			if( ZoomDialogue.doMagnify ) {
				ZoomDialogue.doPercent = Math.min( 1, ZoomDialogue.doPercent + 0.1 );
			} else {
				ZoomDialogue.doPercent = Math.max( 0, ZoomDialogue.doPercent - 0.1 );
			}
			ZoomDialogue.doZoom( false );
		}
		private function onZoomPlus( e:Event ):void {
			if( BaseDialogue.BLOCK_MENU ) return;
			if( ZoomDialogue.doMagnify ) {
				ZoomDialogue.doPercent = Math.max( 0, ZoomDialogue.doPercent - 0.1 );
			} else {
				ZoomDialogue.doPercent = Math.min( 1, ZoomDialogue.doPercent + 0.1 );
			}
			ZoomDialogue.doZoom( false );
		}

		private function onOpen( e:Event ):void {
			Load.run(false);
		}

		private function onOpenSilent( e:Event ):void {
			Load.run(true);
		}

		private function onSave( e:Event ):void {
			if( BaseDialogue.BLOCK_MENU ) return;
			Save.run( true );
		}

		private function onSaveNew( e:Event ):void {
			Save.run( false );
		}

		private function onExport( e:Event ):void {
			Save.run( false, true );
		}

		private function onUndo( e:Event ):void {
			if( BaseDialogue.BLOCK_MENU || _stage.focus != null ) {
				return;
			}
			UndoManager.runUndo();
		}

		private function onRedo( e:Event ):void {
			if( BaseDialogue.BLOCK_MENU || _stage.focus != null ) {
				return;
			}
			UndoManager.runRedo();
		}

		private function onCut( e:Event ):void {
			if( BaseDialogue.BLOCK_MENU || _stage.focus != null ) {
				NativeApplication.nativeApplication.cut();
				return;
			}
			CutCopyPaste.cut();
		}

		private function onCopy( e:Event ):void {
			if( BaseDialogue.BLOCK_MENU || _stage.focus != null ) {
				NativeApplication.nativeApplication.copy();
				return;
			}
			CutCopyPaste.copy();
		}

		private function onPaste( e:Event ):void {
			if( BaseDialogue.BLOCK_MENU || _stage.focus != null ) {
				NativeApplication.nativeApplication.paste();
				return;
			}
			CutCopyPaste.paste();
		}

		private function onDelete( e:Event ):void {
			if( BaseDialogue.BLOCK_MENU || _stage.focus != null ) {
				return;
			}
			for each( var item:ItemModel in DataModel.SELECTED ) {
				item.item.parent.removeChild( item.item );
			}
		}

		private function onLockChildPosition( e:Event ):void {
			DataModel.LOCK_CHILD_POSITION = !DataModel.LOCK_CHILD_POSITION;

			(e.target as NativeMenuItem).checked = DataModel.LOCK_CHILD_POSITION;
		}

		private function onLockChildScale( e:Event ):void {
			DataModel.LOCK_CHILD_SCALE = !DataModel.LOCK_CHILD_SCALE;

			(e.target as NativeMenuItem).checked = DataModel.LOCK_CHILD_SCALE;
		}

		private function onLockChildWorldPosition( e:Event ):void {
			DataModel.LOCK_CHILD_WORLD_POSITION = !DataModel.LOCK_CHILD_WORLD_POSITION;

			(e.target as NativeMenuItem).checked = DataModel.LOCK_CHILD_WORLD_POSITION;
		}

		private function onOrigWidthHeight( e:Event ):void {
			for each( var holder:ItemModel in DataModel.SELECTED ) {
				var item:CDItem = holder.item;
				if( item != null ) {
					var bounds:Rectangle = ( Drawer.isLoaded && item.asset != null ) ? (Drawer.haveFrame(item.asset) ? Drawer.getBounds(item.asset) : new Rectangle()) : new Rectangle();
					if( item.asset != null && Images.haveImage(item.asset) ) {
						bounds.width = Images.getImage(item.asset).width;
						bounds.height = Images.getImage(item.asset).height;
					}

					item.width = bounds.width;
					item.height = bounds.height;
				}
			}
		}

		private function onWacomCopyPaste( e:Event ):void {
			CutCopyPaste.wacomCopyPaste = !CutCopyPaste.WACOM_COPYPASTE;
		}
	}
}
