package com.stardoll.carbondioxide.components {
	import com.stardoll.carbondioxide.dialogues.ColorDialogue;
	import com.stardoll.carbondioxide.managers.UndoManager;
	import com.stardoll.carbondioxide.dialogues.AssetsDialogue;
	import com.stardoll.carbondioxide.dialogues.FindAssetsDialogue;
	import com.stardoll.carbondioxide.dialogues.ItemsDialogue;
	import com.stardoll.carbondioxide.dialogues.PropertiesDialogue;
	import com.stardoll.carbondioxide.dialogues.ZoomDialogue;
	import com.stardoll.carbondioxide.saveload.Load;
	import com.stardoll.carbondioxide.saveload.Save;

	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.Stage;
	import flash.events.Event;
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
							name: "Save",
							shortcut: "s",
							callback: onSave
						},
						{
							name: "Save As",
							callback: onSaveNew
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
					]
				},

				{
					name: "Windows",
					children: [
						{
							name: "Assets",
							callback: onAssets
						},
						{
							name: "Items",
							callback: onItems
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
			NativeApplication.nativeApplication.exit();
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

		private function onItems( e:Event ):void {
			new ItemsDialogue();
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

		private function onZoomMagnify( e:Event ):void {
			ZoomDialogue.doMagnify = !ZoomDialogue.doMagnify;
			ZoomDialogue.doZoom();
		}
		private function onZoomMinus( e:Event ):void {
			ZoomDialogue.doPercent = Math.min( 1, ZoomDialogue.doPercent + 0.1 );
			ZoomDialogue.doZoom();
		}
		private function onZoomPlus( e:Event ):void {
			ZoomDialogue.doPercent = Math.max( 0, ZoomDialogue.doPercent - 0.1 );
			ZoomDialogue.doZoom();
		}

		private function onOpen( e:Event ):void {
			Load.run();
		}

		private function onSave( e:Event ):void {
			Save.run( true );
		}

		private function onSaveNew( e:Event ):void {
			Save.run( false );
		}

		private function onUndo( e:Event ):void {
			UndoManager.runUndo();
		}

		private function onRedo( e:Event ):void {
			UndoManager.runRedo();
		}

		private function onColor( e:Event ):void {
			new ColorDialogue();
		}
	}
}
