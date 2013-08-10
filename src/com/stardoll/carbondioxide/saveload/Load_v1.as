package com.stardoll.carbondioxide.saveload {
	import com.stardoll.carbondioxide.models.cd.CDResolution;
	import com.stardoll.carbondioxide.models.cd.CDText;
	import com.stardoll.carbondioxide.models.cd.CDItem;
	import com.stardoll.carbondioxide.dialogues.PopupDialogue;
	import com.stardoll.carbondioxide.managers.ViewsManager;
	import com.stardoll.carbondioxide.models.cd.CDView;
	import com.stardoll.carbondioxide.utils.ObjectEx;
	/**
	 * @author Simon
	 */
	public class Load_v1 {
		private static function error( msg:String ):void {
			new PopupDialogue("ERROR", msg);
		}
		
		///

		private static var TEXTDB:Array;
		
		private static function text( txt:int, _def:String=null ):String {
			if( txt < 0 || txt >= TEXTDB.length ) {
				return _def || "[UNKNOWN]";
			}
			return TEXTDB[ txt ];
		}
		
		///

		public static function parseViews( data:Object ):void {
			ViewsManager.clearViews();
			
			const views:Array = ObjectEx.select(data, SLKeys.MAIN_VIEWS, null);
			
			if( views == null ) {
				error("No views");
				return;
			}
			
			TEXTDB = ObjectEx.select(data, SLKeys.MAIN_TEXTS, null);
			
			const len:int = views.length;
			for( var i:int = 0; i < len; i++ ) {
				parseView( views[i] );
			}
			
			TEXTDB = null;
		}
		
		private static function parseView( data:Object ):void {
			var view:CDView = new CDView( text( ObjectEx.select(data, SLKeys.ITEM_NAME, -1) ) );
			
			var children:Array = ObjectEx.select(data, SLKeys.ITEM_CHILDREN, null);
			if( children != null ) {
				const len:int = children.length;
				for( var i:int = 0; i < len; i++ ) {
					parseItem( view, children[i] );
				}
			}
			
			ViewsManager.addView( view );
		}
		
		private static function parseItem( parent:CDItem, data:Object ):void {
			var item:CDItem;
			
			const type:int = ObjectEx.select(data, SLKeys.ITEM_TYPE, CDItem.TYPE_UNKNOWN);
			
			if( type == CDItem.TYPE_UNKNOWN ) {
				return;
			}
			
			const name:String = text( ObjectEx.select(data, SLKeys.ITEM_NAME, -1) ); 
			
			switch( type ) {
				case CDItem.TYPE_ITEM:
					item = new CDItem(parent, name);
				break;
				 
				case CDItem.TYPE_TEXT:
					item = new CDText(parent, name);
				break; 
			}
			
			if( type == CDItem.TYPE_TEXT ) {
				(item as CDText).text = text( ObjectEx.select(data, SLKeys.ITEM_TEXT, -1), (item as CDText).text );	
			}
			
			item.asset 			= text( ObjectEx.select(data, SLKeys.ITEM_ASSET, -1), item.asset );
			item.aspectRatio	= ObjectEx.select(data, SLKeys.ITEM_ASPECTRATIO, item.aspectRatio);
			
			var i:int;
			
			var resolutions:Array = ObjectEx.select(data, SLKeys.ITEM_RESOLUTIONS, null);
			if( resolutions != null ) {
				const rlen:int = resolutions.length;
				for( i = 0; i < rlen; i++ ) {
					parseResolution(item, resolutions[i]);
				}
			}

			var children:Array = ObjectEx.select(data, SLKeys.ITEM_CHILDREN, null);
			if( children != null ) {
				const clen:int = children.length;
				for( i = 0; i < clen; i++ ) {
					parseItem( item, children[i] );
				}
			}
			
			parent.addChild( item );
		}
		
		private static function parseResolution( item:CDItem, data:Array ):void {
			const sw:int = data[ SLKeys.RES_SCREENWIDTH ];
			const sh:int = data[ SLKeys.RES_SCREENHEIGHT ];
			
			var res:CDResolution = new CDResolution(sw, sh);
			res.x 		= data[ SLKeys.RES_X ];
			res.y 		= data[ SLKeys.RES_Y ];
			res.width 	= data[ SLKeys.RES_W ];
			res.height 	= data[ SLKeys.RES_H ];
			
			item.addResolution( res );
		}
	}
}
