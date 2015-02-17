package com.tbbgc.carbondioxide.saveload {
	import com.tbbgc.carbondioxide.managers.ViewsManager;
	import com.tbbgc.carbondioxide.models.DataModel;
	import com.tbbgc.carbondioxide.models.cd.CDAspectRatio;
	import com.tbbgc.carbondioxide.models.cd.CDGradient;
	import com.tbbgc.carbondioxide.models.cd.CDItem;
	import com.tbbgc.carbondioxide.models.cd.CDResolution;
	import com.tbbgc.carbondioxide.models.cd.CDText;
	import com.tbbgc.carbondioxide.models.cd.CDView;

	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	/**
	 * @author simonrodriguez
	 */
	public class Save {
		public static const CURRENT_VERSION:int = 3;

		private static var TEXTDB:Vector.<String>;
		private static var RESDB:Vector.<CDResolution>;

		private static function text( txt:String ):int {
			var index:int = TEXTDB.indexOf( txt );

			if( index >= 0 ) {
				return index;
			} else {
				index = TEXTDB.length;
				TEXTDB.push( txt );
			}

			return index;
		}

		private static function resolution( model:CDResolution ):int {
			const len:int = RESDB.length;

			var m:CDResolution;

			for( var i:int = 0; i < len; i++ ) {
				m = RESDB[i];

				if( m.screenWidth == model.screenWidth &&
					m.screenHeight == model.screenHeight &&
					m.screenDPI == model.screenDPI ) {
						return i;
				}
			}

			RESDB.push( model );
			return len;
		}

		///

		public static function run( reuse:Boolean ):Boolean {
			if( reuse ) {
				if( DataModel.LAST_FILE != null ) {
					onSaveFile(null);
					return true;
				}
				return false;
			}

			var f:File = new File();

			f.browseForSave("Save Design");
			f.addEventListener(Event.SELECT, onSaveFile);
			return true;
		}

		private static function onSaveFile( e:Event ):void {
			var f:File = (e != null) ? e.target as File : DataModel.LAST_FILE;

			DataModel.LAST_FILE = f;

			var stream:FileStream = new FileStream();
			stream.open( f, FileMode.WRITE);
			stream.writeUTFBytes( saveData() );
			stream.close();
		}

		private static function saveData():String {
			TEXTDB = new Vector.<String>();
			RESDB = new Vector.<CDResolution>();

			var data:Object = {};

			data[ SLKeys.MAIN_KEY ] = "cbdd";
			data[ SLKeys.MAIN_VERSION ] = CURRENT_VERSION;
			data[ SLKeys.MAIN_RANDOM ] = getRandomCharacters();

			var v:Array = [];

			const views:Vector.<CDView> = ViewsManager.views;

			const len:int = views.length;
			for( var i:int = 0; i < len; i++ ) {
				v.push( saveView( views[i]) );
			}

			data[ SLKeys.MAIN_VIEWS ] = v;

			data[ SLKeys.MAIN_TEXTS ] = TEXTDB;

			data[ SLKeys.MAIN_RESOLUTIONS ] = saveResDB();

			TEXTDB = null;
			RESDB = null;

			return JSON.stringify(data);
		}

		private static function saveView( view:CDView ):Object {
			var data:Object = {};

			data[ SLKeys.ITEM_TYPE ] = CDItem.TYPE_VIEW;
			data[ SLKeys.ITEM_NAME ] = text( view.name );

			const children:Vector.<CDItem> = view.children;
			const clen:int = children.length;
			if( clen > 0 ) {
				var c:Array = [];

				for( var i:int = 0; i < clen; i++ ) {
					c.push( saveItem( children[i] ) );
				}

				data[ SLKeys.ITEM_CHILDREN ] = c;
			}

			return data;
		}

		private static function saveItem( item:CDItem ):Object {
			var data:Object = {};

			data[ SLKeys.ITEM_TYPE ] = item.type;
			data[ SLKeys.ITEM_NAME ] = text( item.name );

			if( item is CDText ) {
				data[ SLKeys.ITEM_TEXT ] = text( (item as CDText).text );
				if( (item as CDText).align != CDText.ALIGN_LEFT) data[ SLKeys.ITEM_TEXT_ALIGN ] = (item as CDText).align;
			}

			if( item is CDGradient ) {
				data[ SLKeys.ITEM_GRADIENT_COLORS ] = (item as CDGradient).colors;
				data[ SLKeys.ITEM_GRADIENT_ALPHAS ] = (item as CDGradient).alphas;
			}

			if( item.note != null ) {
				data[ SLKeys.ITEM_NOTE ] = text( item.note );
			}

			if( item.asset != null ) {
				data[ SLKeys.ITEM_ASSET ] = text( item.asset );
			}

			if( item.aspectRatioAlign != CDAspectRatio.NONE ) {
				data[ SLKeys.ITEM_ASPECTRATIO ] = item.aspectRatioAlign;
			}

			if( item.aspectRatioType != CDAspectRatio.ALIGN_BOTH ) {
				data[ SLKeys.ITEM_ASPECTRATIOTYPE ] = item.aspectRatioType;
			}

			if( item.enabled == false ) {
				data[ SLKeys.ITEM_ENABLED ] = false;
			}

			if( item.visible == false ) {
				data[ SLKeys.ITEM_VISIBLE ] = false;
			}

			if( item.color != CDItem.DEFAULT_COLOR ) {
				data[ SLKeys.ITEM_COLOR ] = item.color;
			}

			if( item.alpha != CDItem.DEFAULT_ALPHA ) {
				data[ SLKeys.ITEM_ALPHA ] = item.alpha;
			}

			var i:int;

			const resolutions:Vector.<CDResolution> = item.resolutions;
			const rlen:int = resolutions.length;
			if( rlen > 0 ) {
				var r:Array = [];

				for( i = 0; i < rlen; i++ ) {
					saveResolutions( resolutions[i], r );
				}

				data[ SLKeys.ITEM_RESOLUTIONS ] = r;
			}

			const children:Vector.<CDItem> = item.children;
			const clen:int = children.length;
			if( clen > 0 ) {
				var c:Array = [];

				for( i = 0; i < clen; i++ ) {
					c.push( saveItem( children[i] ) );
				}

				data[ SLKeys.ITEM_CHILDREN ] = c;
			}

			return data;
		}

		private static function saveResolutions( res:CDResolution, r:Array ):void {
			r.push(
				resolution( res ),
				res.x,
				res.y,
				res.width,
				res.height,
				res.aspectRatio
			);
		}

		private static function getRandomCharacters():String {
			var r:String ="";
			for( var i:int = 0; i < 32; i++ ) {
				r += String.fromCharCode( int(65 + ((90-65)*Math.random())) );
			}
			return r;
		}

		private static function saveResDB():Array {
			var a:Array = [];

			var m:CDResolution;

			const len:int = RESDB.length;
			for( var i:int = 0; i < len; i++ ) {
				m = RESDB[i];

				a.push( m.screenWidth, m.screenHeight, m.screenDPI );
			}

			return a;
		}
	}
}
