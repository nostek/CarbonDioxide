package com.stardoll.carbondioxide.saveload {
	import com.stardoll.carbondioxide.managers.ViewsManager;
	import com.stardoll.carbondioxide.models.cd.CDAspectRatio;
	import com.stardoll.carbondioxide.models.cd.CDItem;
	import com.stardoll.carbondioxide.models.cd.CDResolution;
	import com.stardoll.carbondioxide.models.cd.CDText;
	import com.stardoll.carbondioxide.models.cd.CDView;
	/**
	 * @author simonrodriguez
	 */
	public class Save {
		public static const CURRENT_VERSION:int = 1;

		private static var TEXTDB:Array;
		
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
		
		///

		public static function run():void {
			TEXTDB = [];
			
			var data:Object = {};
			
			data[ SLKeys.MAIN_KEY ] = "cbdd";
			data[ SLKeys.MAIN_VERSION ] = CURRENT_VERSION;

			var v:Array = [];

			const views:Vector.<CDView> = ViewsManager.views;

			const len:int = views.length;
			for( var i:int = 0; i < len; i++ ) {
				v.push( saveView( views[i]) );
			}

			data[ SLKeys.MAIN_VIEWS ] = v;
			
			data[ SLKeys.MAIN_TEXTS ] = TEXTDB;
			
			TEXTDB = null;

			trace( JSON.stringify(data) );
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
			}

			if( item.asset != null ) {
				data[ SLKeys.ITEM_ASSET ] = text( item.asset );
			}

			if( item.aspectRatio != CDAspectRatio.NONE ) {
				data[ SLKeys.ITEM_ASPECTRATIO ] = item.aspectRatio;
			}
			
			if( item.enabled == false ) {
				data[ SLKeys.ITEM_ENABLED ] = false;
			}
			
			if( item.visible == false ) {
				data[ SLKeys.ITEM_VISIBLE ] = false;
			}

			var i:int;

			const resolutions:Vector.<CDResolution> = item.resolutions;
			const rlen:int = resolutions.length;
			if( rlen > 0 ) {
				var r:Array = [];

				for( i = 0; i < rlen; i++ ) {
					r.push( saveResolutions( resolutions[i] ) );
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

		private static function saveResolutions( res:CDResolution ):Array {
			return [
				res.screenWidth,
				res.screenHeight,
				res.x,
				res.y,
				res.width,
				res.height,
				res.aspectRatio
			];
		}
	}
}