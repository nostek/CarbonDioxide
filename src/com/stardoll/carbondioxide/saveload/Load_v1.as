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

		public static function parseViews( data:Object ):void {
			ViewsManager.clearViews();
			
			const views:Array = ObjectEx.select(data, SLKeys.VIEWS, null);
			
			if( views == null ) {
				error("No views");
				return;
			}
			
			const len:int = views.length;
			for( var i:int = 0; i < len; i++ ) {
				parseView( views[i] );
			}
		}
		
		private static function parseView( data:Object ):void {
			var view:CDView = new CDView( ObjectEx.select(data, SLKeys.NAME, "[UNKNOWN]") );
			
			var children:Array = ObjectEx.select(data, SLKeys.CHILDREN, null);
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
			
			const type:int = ObjectEx.select(data, SLKeys.TYPE, CDItem.TYPE_UNKNOWN);
			
			if( type == CDItem.TYPE_UNKNOWN ) {
				return;
			}
			
			const name:String = ObjectEx.select(data, SLKeys.NAME, "[UNKNOWN]"); 
			
			switch( type ) {
				case CDItem.TYPE_ITEM:
					item = new CDItem(parent, name);
				break;
				 
				case CDItem.TYPE_TEXT:
					item = new CDText(parent, name);
				break; 
			}
			
			if( type == CDItem.TYPE_TEXT ) {
				(item as CDText).text = ObjectEx.select(data, SLKeys.TEXT, (item as CDText).text);
			}
			
			item.asset 			= ObjectEx.select(data, SLKeys.ASSET, item.asset);
			item.aspectRatio	= ObjectEx.select(data, SLKeys.ASPECTRATIO, item.aspectRatio);
			
			var i:int;
			
			var resolutions:Array = ObjectEx.select(data, SLKeys.RESOLUTIONS, null);
			if( resolutions != null ) {
				const rlen:int = resolutions.length;
				for( i = 0; i < rlen; i++ ) {
					parseResolution(item, resolutions[i]);
				}
			}

			var children:Array = ObjectEx.select(data, SLKeys.CHILDREN, null);
			if( children != null ) {
				const clen:int = children.length;
				for( i = 0; i < clen; i++ ) {
					parseItem( item, children[i] );
				}
			}
			
			parent.addChild( item );
		}
		
		private static function parseResolution( item:CDItem, data:Object ):void {
			const sw:int = ObjectEx.select(data, SLKeys.SCREENWIDTH, 0);
			const sh:int = ObjectEx.select(data, SLKeys.SCREENHEIGHT, 0);
			
			var res:CDResolution = new CDResolution(sw, sh);
			res.x 		= ObjectEx.select(data, SLKeys.X, 0);
			res.y 		= ObjectEx.select(data, SLKeys.Y, 0);
			res.width 	= ObjectEx.select(data, SLKeys.W, 0);
			res.height 	= ObjectEx.select(data, SLKeys.H, 0);
			
			item.addResolution( res );
		}
	}
}
