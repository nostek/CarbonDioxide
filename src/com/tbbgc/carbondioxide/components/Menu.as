package com.tbbgc.carbondioxide.components {
	import com.tbbgc.carbondioxide.copypaste.CutCopyPaste;
	import com.tbbgc.carbondioxide.dialogues.AlignDialogue;
	import com.tbbgc.carbondioxide.dialogues.AspectRatioDialogue;
	import com.tbbgc.carbondioxide.dialogues.AssetsDialogue;
	import com.tbbgc.carbondioxide.dialogues.BaseDialogue;
	import com.tbbgc.carbondioxide.dialogues.ColorDialogue;
	import com.tbbgc.carbondioxide.dialogues.DPIDialogue;
	import com.tbbgc.carbondioxide.dialogues.FindAssetsDialogue;
	import com.tbbgc.carbondioxide.dialogues.InputDialogue;
	import com.tbbgc.carbondioxide.dialogues.MissingDialogue;
	import com.tbbgc.carbondioxide.dialogues.PopupDialogue;
	import com.tbbgc.carbondioxide.dialogues.PropertiesDialogue;
	import com.tbbgc.carbondioxide.dialogues.SelectResolutionDialogue;
	import com.tbbgc.carbondioxide.dialogues.TreeDialogue;
	import com.tbbgc.carbondioxide.dialogues.ZoomDialogue;
	import com.tbbgc.carbondioxide.managers.AssetsManager;
	import com.tbbgc.carbondioxide.managers.ReportManager;
	import com.tbbgc.carbondioxide.managers.UndoManager;
	import com.tbbgc.carbondioxide.models.DataModel;
	import com.tbbgc.carbondioxide.models.ItemModel;
	import com.tbbgc.carbondioxide.models.cd.CDAspectRatio;
	import com.tbbgc.carbondioxide.models.cd.CDItem;
	import com.tbbgc.carbondioxide.saveload.Load;
	import com.tbbgc.carbondioxide.saveload.Save;
	import com.tbbgc.carbondioxide.utils.SWFDrawer;
	import com.tbbgc.carbondioxide.utils.Legacy;

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
							name: "Reload",
							callback: onReload,
							shortcut: "§"
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
							name: "Import",
							children: [
								{
									name: "Fonts",
									callback: onImportFonts
								},
								{
									name: "Images",
									callback: onImportImages
								},
								{
									name: "SWFs",
									callback: onImportSWFs
								},
								{
									name: "TexturePacker (JSON Hash)",
									callback: onImportTexturePacker
								}
							]
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
						{
							name: "DPI",
							callback: onDPI
						},
						{
							name: "Missing assets",
							callback: onMissing
						},
						{
							name: "Report",
							callback: onReport
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
							name: "Wacom friendly copypaste",
							callback: onWacomCopyPaste,
							enabled: CutCopyPaste.WACOM_COPYPASTE
						},
						{
							name: "Set asset resolution",
							callback: onAssetResolution
						},
					]
				},

				{
					name: "Tools",
					children: [
						{
							name: "Original Width/Height",
							callback: onOrigWidthHeight,
							shortcut: "o"
						},
						{
							name: "Real size",
							callback: onRealSize,
							shortcut: "r"
						},
						{
							name: "Align",
							callback: onAlignItems,
							shortcut: "a"
						},
						{
							name: "Aspect scale width",
							callback: onAspectScaleWidth,
							shortcut: "9"
						},
						{
							name: "Aspect scale height",
							callback: onAspectScaleHeight,
							shortcut: "0"
						}
					]
				},

				{
					name: "Extra",
					children: [
						{
							name: "Load legacy Carbon",
							callback: onLoadLegacy
						}
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

		private function onDPI( e:Event ):void {
			new DPIDialogue();
		}

		private function onMissing( e:Event ):void {
			new MissingDialogue();
		}

		private function onReport( e:Event ):void {
			ReportManager.compile();
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
			var dlg:ColorDialogue = new ColorDialogue( DataModel.BG_COLOR );
			dlg.onSelect.add( _onSelectColor );
		}
		private function _onSelectColor( color:uint, alpha:Number ):void {
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

		private function onReload( e:Event ):void {
			if( BaseDialogue.BLOCK_MENU ) return;
			Load.reopen();
		}

		private function onSave( e:Event ):void {
			if( BaseDialogue.BLOCK_MENU ) return;
			if( !Save.run( true ) ) {
				new PopupDialogue("ERROR", "Nothing to save to, use Save As.");
			}
		}

		private function onSaveNew( e:Event ):void {
			Save.run( false );
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
			if( BaseDialogue.BLOCK_MENU || _stage.focus != null ) {
				return;
			}

			var item:CDItem;
			var bounds:Rectangle;

			for each( var holder:ItemModel in DataModel.SELECTED ) {
				item = holder.item;

				if( item != null ) {
					bounds = AssetsManager.getBounds( item.asset );
					if( bounds != null ) {
						item.setXYWH(item.x, item.y, Math.round(bounds.width), Math.round(bounds.height));
					}
				}
			}
		}

		private function onRealSize( e:Event ):void {
			if( BaseDialogue.BLOCK_MENU || _stage.focus != null ) {
				return;
			}

			if( DataModel.COMPUTER_SCREEN_SIZE == -1 ) {
				var dlg:InputDialogue = new InputDialogue("Screen Size", "Enter your monitors inch size", "27");
				dlg.onOK.addOnce( onScreenSize );
				return;
			}

			DataModel.onSetRealSize.dispatch();
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

		private function onAlignItems( e:Event ):void {
			if( BaseDialogue.BLOCK_MENU || _stage.focus != null ) {
				NativeApplication.nativeApplication.selectAll();
				return;
			}

			var alignDlg:AspectRatioDialogue = new AspectRatioDialogue();
			alignDlg.onSelect.addOnce( onAlignSelected );
		}

		private function onAlignSelected( ar:int ):void {
			var item:ItemModel;

			for each( item in DataModel.SELECTED ) {
				switch( ar ) {
					case CDAspectRatio.NONE:
					break;
					case CDAspectRatio.TOP_LEFT:
						item.item.x = 0;
						item.item.y = 0;
					break;
					case CDAspectRatio.TOP:
						item.item.x = (item.item.parent.width - item.item.width) * 0.5;
						item.item.y = 0;
					break;
					case CDAspectRatio.TOP_RIGHT:
						item.item.x = (item.item.parent.width - item.item.width);
						item.item.y = 0;
					break;
					case CDAspectRatio.LEFT:
						item.item.x = 0;
						item.item.y = (item.item.parent.height - item.item.height) * 0.5;
					break;
					case CDAspectRatio.CENTER:
						item.item.x = (item.item.parent.width - item.item.width) * 0.5;
						item.item.y = (item.item.parent.height - item.item.height) * 0.5;
					break;
					case CDAspectRatio.RIGHT:
						item.item.x = (item.item.parent.width - item.item.width);
						item.item.y = (item.item.parent.height - item.item.height) * 0.5;
					break;
					case CDAspectRatio.BOTTOM_LEFT:
						item.item.x = 0;
						item.item.y = (item.item.parent.height - item.item.height);
					break;
					case CDAspectRatio.BOTTOM:
						item.item.x = (item.item.parent.width - item.item.width) * 0.5;
						item.item.y = (item.item.parent.height - item.item.height);
					break;
					case CDAspectRatio.BOTTOM_RIGHT:
						item.item.x = (item.item.parent.width - item.item.width);
						item.item.y = (item.item.parent.height - item.item.height);
					break;
				}
			}
		}

		private function onWacomCopyPaste( e:Event ):void {
			CutCopyPaste.wacomCopyPaste = !CutCopyPaste.WACOM_COPYPASTE;
		}

		private function onAssetResolution( e:Event ):void {
			var dlg:SelectResolutionDialogue = new SelectResolutionDialogue();
			dlg.onSelect.addOnce( onAssetResolutionSelected );
		}
		private function onAssetResolutionSelected( data:Object ):void {
			SWFDrawer.NATIVE_RESOLUTION_WIDTH = int(data["width"]);
			SWFDrawer.NATIVE_RESOLUTION_HEIGHT = int(data["height"]);

			DataModel.redrawAll();
		}

		private function onAspectScaleWidth( e:Event ):void {
			var item:ItemModel;

			for each( item in DataModel.SELECTED ) {
				if( !item.isSaved ) {
					item.save();
				}

				item.item.setXYWH(item.save_x, item.save_y, item.save_width, Math.round(item.save_width * item.item.primaryAspectRatio));
			}
		}

		private function onAspectScaleHeight( e:Event ):void {
			var item:ItemModel;

			for each( item in DataModel.SELECTED ) {
				if( !item.isSaved ) {
					item.save();
				}

				item.item.setXYWH(item.save_x, item.save_y, Math.round(item.save_height * item.item.primaryAspectRatio), item.save_height);
			}
		}

		private function onLoadLegacy( e:Event ):void {
			Legacy.load();
		}

		private function onImportFonts( e:Event ):void {
			AssetsManager.importFonts();
		}

		private function onImportImages( e:Event ):void {
			AssetsManager.importImages();
		}

		private function onImportSWFs( e:Event ):void {
			AssetsManager.importSWFs();
		}

		private function onImportTexturePacker( e:Event ):void {
			AssetsManager.importTexturePacker();
		}
	}
}
