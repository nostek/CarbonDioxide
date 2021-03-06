package com.tbbgc.carbondioxide.saveload {
	import com.tbbgc.carbondioxide.dialogues.PopupDialogue;
	import com.tbbgc.carbondioxide.managers.ViewsManager;
	import com.tbbgc.carbondioxide.models.cd.CDGradient;
	import com.tbbgc.carbondioxide.models.cd.CDItem;
	import com.tbbgc.carbondioxide.models.cd.CDResolution;
	import com.tbbgc.carbondioxide.models.cd.CDText;
	import com.tbbgc.carbondioxide.models.cd.CDView;
	import com.tbbgc.carbondioxide.utils.ObjectEx;
	/**
	 * @author Simon
	 */
	public class Load_v3 {
		private static function error( msg:String ):void {
			new PopupDialogue("ERROR", msg);
		}

		///

		private static var TEXTDB:Vector.<String>;
		private static var RESDB:Vector.<CDResolution>;

		private static function text( txt:int, _def:String=null, _defNull:Boolean=false ):String {
			if( txt < 0 || txt >= TEXTDB.length ) {
				if( _def == null && _defNull ) return null;
				return _def || "[UNKNOWN]";
			}
			return TEXTDB[ txt ];
		}

		private static function loadTexts( indata:Array ):Vector.<String> {
			var a:Vector.<String> = new Vector.<String>();

			const len:int = indata.length;
			for( var i:int = 0; i < len; i++ ) {
				a.push( indata[i] );
			}

			return a;
		}

		private static function loadResolution( indata:Array ):Vector.<CDResolution> {
			var a:Vector.<CDResolution> = new Vector.<CDResolution>();

			const len:int = indata.length;
			for( var i:int = 0; i < len; i+=3 ) {
				a.push( new CDResolution(
					indata[i  ],
					indata[i+1],
					indata[i+2]
				) );
			}

			return a;
		}

		///

		public static function parseViews( data:Object ):void {
			ViewsManager.clearViews();

			const views:Array = ObjectEx.select(data, SLKeys.MAIN_VIEWS, null);

			if( views == null ) {
				error("No views");
				return;
			}

			TEXTDB = loadTexts( ObjectEx.select(data, SLKeys.MAIN_TEXTS, []) );
			RESDB = loadResolution( ObjectEx.select(data, SLKeys.MAIN_RESOLUTIONS, []) );

			const len:int = views.length;
			for( var i:int = 0; i < len; i++ ) {
				parseView( views[i] );
			}

			TEXTDB = null;
			RESDB = null;
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

				case CDItem.TYPE_GRADIENT:
					item = new CDGradient(parent, name);
				break;
			}

			if( type == CDItem.TYPE_TEXT ) {
				(item as CDText).text  = text( ObjectEx.select(data, SLKeys.ITEM_TEXT, -1), (item as CDText).text, true );
				(item as CDText).align = ObjectEx.select(data, SLKeys.ITEM_TEXT_ALIGN, CDText.ALIGN_LEFT);
			}

			if( type == CDItem.TYPE_GRADIENT ) {
				(item as CDGradient).colors = ObjectEx.select(data, SLKeys.ITEM_GRADIENT_COLORS, null);
				(item as CDGradient).alphas = ObjectEx.select(data, SLKeys.ITEM_GRADIENT_ALPHAS, null);
			}

			item.note = text( ObjectEx.select(data, SLKeys.ITEM_NOTE, -1), (item as CDItem).note, true );

			item.asset 				= text( ObjectEx.select(data, SLKeys.ITEM_ASSET, -1), item.asset, true );
			item.aspectRatioAlign	= ObjectEx.select(data, SLKeys.ITEM_ASPECTRATIO, item.aspectRatioAlign);
			item.aspectRatioType	= ObjectEx.select(data, SLKeys.ITEM_ASPECTRATIOTYPE, item.aspectRatioType);

			item.enabled = ObjectEx.select(data, SLKeys.ITEM_ENABLED, true) as Boolean;
			item.visible = ObjectEx.select(data, SLKeys.ITEM_VISIBLE, true) as Boolean;

			item.color = ObjectEx.select(data, SLKeys.ITEM_COLOR, item.color);
			item.alpha = ObjectEx.select(data, SLKeys.ITEM_ALPHA, item.alpha);

			var i:int;

			var resolutions:Array = ObjectEx.select(data, SLKeys.ITEM_RESOLUTIONS, null);
			if( resolutions != null ) {
				const rlen:int = resolutions.length;
				for( i = 0; i < rlen; i += SLKeys.RES_V3_VALUES ) {
					parseResolution(item, resolutions, i );
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

		private static function parseResolution( item:CDItem, data:Array, offset:int ):void {
			var ires:CDResolution = RESDB[ data[ offset+SLKeys.RES_V3_SCREEN_ID ] ];

			var res:CDResolution = new CDResolution(ires.screenWidth, ires.screenHeight, ires.screenDPI);
			res.x 			= data[ offset+SLKeys.RES_V3_X ];
			res.y 			= data[ offset+SLKeys.RES_V3_Y ];
			res.width 		= data[ offset+SLKeys.RES_V3_W ];
			res.height 		= data[ offset+SLKeys.RES_V3_H ];
			res.aspectRatio = data[ offset+SLKeys.RES_V3_ASPECTRATIO ];

			item.addResolution( res );
		}
	}
}
