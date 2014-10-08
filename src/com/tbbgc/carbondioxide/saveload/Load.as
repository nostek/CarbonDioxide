package com.tbbgc.carbondioxide.saveload {
	import com.tbbgc.carbondioxide.dialogues.PopupDialogue;
	import com.tbbgc.carbondioxide.dialogues.YesNoDialogue;
	import com.tbbgc.carbondioxide.managers.SettingsManager;
	import com.tbbgc.carbondioxide.managers.ViewsManager;
	import com.tbbgc.carbondioxide.models.DataModel;
	import com.tbbgc.carbondioxide.models.cd.CDView;

	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	/**
	 * @author simonrodriguez
	 */
	public class Load {
		private static function error( msg:String ):void {
			new PopupDialogue("ERROR", msg);
		}

		public static function removeLock():void {
			if( DataModel.DID_LOCK && DataModel.LAST_FILE != null ) {
				var f:File = new File( DataModel.LAST_FILE.url + "LOCK" );
				if( f.exists ) {
					f.deleteFile();
				}
			}

			DataModel.LAST_FILE = null;
			DataModel.DID_LOCK = false;
		}

		private static var SILENT:Boolean;

		public static function runLast():void {
			if( SettingsManager.haveItem(SettingsManager.SETTINGS_LAST_LAYOUT) ) {
				var dlg3:YesNoDialogue = new YesNoDialogue("Load layout ? ", "Load file? " + SettingsManager.getItem( SettingsManager.SETTINGS_LAST_LAYOUT )[0]);
				dlg3.onYes.addOnce( onRestore );
				dlg3.onNo.addOnce( onNoRestore );
			}
		}

		private static function onNoRestore():void {
			SettingsManager.setItem(SettingsManager.SETTINGS_LAST_LAYOUT, null);
		}

		private static function onRestore():void {
			var data:Object = SettingsManager.getItem( SettingsManager.SETTINGS_LAST_LAYOUT );

			SILENT = data[1] as Boolean;
			var url:String = data[0];

			doLoadFile( new File(url) );
		}

		public static function reopen():void {
			if( DataModel.LAST_FILE != null ) {
				doLoadFile( DataModel.LAST_FILE );
			}
		}

		public static function run(doSilent:Boolean):void {
			SILENT = doSilent;

			var f:File = new File();
			var filter:FileFilter = new FileFilter("Design", "*.json");

			f.browseForOpen("Load Design", [filter]);
			f.addEventListener(Event.SELECT, onSelectedFile);
		}

		private static function onSelectedFile( e:Event ):void {
			var f:File = e.target as File;

			doLoadFile(f);
		}

		private static function doLoadFile( f:File ):void {
			removeLock();

			checkLock( f );

			var file:FileStream = new FileStream();
			file.open(f, FileMode.READ);
				var json:String = file.readUTFBytes(file.bytesAvailable);
			file.close();

			var data:Object = loadData( json );

			if( data != null ) {
				DataModel.LAST_FILE = f;

				SettingsManager.setItem(SettingsManager.SETTINGS_LAST_LAYOUT, [f.url, SILENT]);

				parseData( data );
			} else {
				SettingsManager.setItem(SettingsManager.SETTINGS_LAST_LAYOUT, null);
			}
		}

		private static function checkLock( f:File ):void {
			var lock:File = new File( f.url + "LOCK" );

			var fs:FileStream = new FileStream();

			if( lock.exists ) {
				fs.open(lock, FileMode.READ);
				fs.position = 0;
				var msg:String = fs.readUTFBytes(fs.bytesAvailable);
				fs.close();

				new PopupDialogue("WARNING", msg + "\nMake sure you can use the file!");
			} else {
				if( !SILENT ) {
					fs.open(lock, FileMode.WRITE);
					fs.writeUTFBytes("Locked by: " + File.userDirectory.name + "\nDate: " + (new Date()).toString());
					fs.close();

					DataModel.DID_LOCK = true;
				}
			}
		}

		private static function loadData( d:String ):Object {
			try {
				const data:Object = JSON.parse( d );
			} catch( e:* ) {
				error( "Unable to parse JSON");
				return null;
			}

			if( data[ SLKeys.MAIN_KEY ] == null || data[ SLKeys.MAIN_KEY ] != "cbdd" ) {
				error("Wrong key in file");
				return null;
			}

			if( data[ SLKeys.MAIN_VERSION ] == null ) {
				error("No version in file");
				return null;
			}

			return data;
		}

		private static function parseData( data:Object ):void {
			const version:int = data[ SLKeys.MAIN_VERSION ];
			
			trace( "Load version:", version );

			switch( version ) {
				case 1:
					Load_v1.parseViews( data );
				break;

				case 2:
					Load_v2.parseViews( data );
				break;

				case 3:
					Load_v3.parseViews( data );
				break;

				default:
					error("Unknown version: " + version.toString());
				return;
			}

			if( SettingsManager.haveItem(SettingsManager.SETTINGS_LAST_VIEW) ) {
				var name:String = SettingsManager.getItem(SettingsManager.SETTINGS_LAST_VIEW) as String;
				var view:CDView = ViewsManager.getViewByName(name);
				if( view != null ) {
					DataModel.setView(view);
					return;
				}
			}

			DataModel.setView( ViewsManager.views[0] );
		}
	}
}
