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

		public static function run():void {
			var data:Object = {
				key: "cbdd",
				version: CURRENT_VERSION
			};

			var v:Array = [];

			const views:Vector.<CDView> = ViewsManager.views;

			const len:int = views.length;
			for( var i:int = 0; i < len; i++ ) {
				v.push( saveView( views[i]) );
			}

			data[ SLKeys.VIEWS ] = v;

			trace( JSON.stringify(data) );
		}

		private static function saveView( view:CDView ):Object {
			var data:Object = {};

			data[ SLKeys.TYPE ] = CDItem.TYPE_VIEW;
			data[ SLKeys.NAME ] = view.name;

			const children:Vector.<CDItem> = view.children;
			const clen:int = children.length;
			if( clen > 0 ) {
				var c:Array = [];

				for( var i:int = 0; i < clen; i++ ) {
					c.push( saveItem( children[i] ) );
				}

				data[ SLKeys.CHILDREN ] = c;
			}

			return data;
		}

		private static function saveItem( item:CDItem ):Object {
			var data:Object = {};

			data[ SLKeys.TYPE ] = item.type;
			data[ SLKeys.NAME ] = item.name;

			if( item is CDText ) {
				data[ SLKeys.TEXT ] = (item as CDText).text;
			}

			if( item.asset != null ) {
				data[ SLKeys.ASSET ] = item.asset;
			}

			if( item.aspectRatio != CDAspectRatio.NONE ) {
				data[ SLKeys.ASPECTRATIO ] = item.aspectRatio;
			}

			var i:int;

			const resolutions:Vector.<CDResolution> = item.resolutions;
			const rlen:int = resolutions.length;
			if( rlen > 0 ) {
				var r:Array = [];

				for( i = 0; i < rlen; i++ ) {
					r.push( saveResolutions( resolutions[i] ) );
				}

				data[ SLKeys.RESOLUTIONS ] = r;
			}

			const children:Vector.<CDItem> = item.children;
			const clen:int = children.length;
			if( clen > 0 ) {
				var c:Array = [];

				for( i = 0; i < clen; i++ ) {
					c.push( saveItem( children[i] ) );
				}

				data[ SLKeys.CHILDREN ] = c;
			}

			return data;
		}

		private static function saveResolutions( res:CDResolution ):Object {
			var data:Object = {};

			data[ SLKeys.SCREENWIDTH ] 	= res.screenWidth;
			data[ SLKeys.SCREENHEIGHT ] = res.screenHeight;

			data[ SLKeys.X ] = res.x;
			data[ SLKeys.Y ] = res.y;
			data[ SLKeys.W ] = res.width;
			data[ SLKeys.H ] = res.height;

			return data;
		}
	}
}
