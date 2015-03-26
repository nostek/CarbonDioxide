package com.tbbgc.carbondioxide.copypaste {
	import com.tbbgc.carbondioxide.managers.SettingsManager;
	import com.tbbgc.carbondioxide.models.DataModel;
	import com.tbbgc.carbondioxide.models.ItemModel;
	import com.tbbgc.carbondioxide.models.cd.CDGradient;
	import com.tbbgc.carbondioxide.models.cd.CDItem;
	import com.tbbgc.carbondioxide.models.cd.CDText;
	import com.tbbgc.carbondioxide.utils.ObjectEx;

	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	/**
	 * @author Simon
	 */
	public class CutCopyPaste {
		public function CutCopyPaste() {
			WACOM_COPYPASTE = ObjectEx.select(SettingsManager.getItem(SettingsManager.SETTINGS_COPYPASTE), "e", false) as Boolean;
		}

		////////////////////////////////////////////////////////////////////////

		public static var WACOM_COPYPASTE:Boolean;

		public static function set wacomCopyPaste( enabled:Boolean ):void {
			WACOM_COPYPASTE = enabled;

			SettingsManager.setItem(SettingsManager.SETTINGS_COPYPASTE, {e:enabled});
		}

		////////////////////////////////////////////////////////////////////////

		public static function cut():void {
			copy();

			for each( var item:ItemModel in DataModel.SELECTED ) {
				item.item.parent.removeChild( item.item );
			}
		}

		public static function copy():void {
			var data:Array = [];

			const items:Vector.<ItemModel> = DataModel.SELECTED;

			var maxx:Number = Number.MIN_VALUE;
			var maxy:Number = Number.MIN_VALUE;
			for each( var model:ItemModel in items ) {
				maxx = Math.max( maxx, model.item.x );
				maxy = Math.max( maxy, model.item.y );
			}

			var parseObject:Function = function( item:CDItem, offset:Boolean = false ):Object {
				var o:Object = {
					type: item.type,
					name: item.name,
					x: item.x - (offset ? maxx : 0),
					y: item.y - (offset ? maxy : 0),
					w: item.width,
					h: item.height,
					asset: item.asset,
					ar: item.aspectRatioAlign,
					at: item.aspectRatioType,
					e: item.enabled,
					v: item.visible,
					c: item.color,
					a: item.alpha,
					note: item.note
				};

				if( item is CDText ) {
					o["text"] = (item as CDText).text;
					o["texta"] = (item as CDText).align;
				}

				if( item is CDGradient ) {
					o["gcolors"] = (item as CDGradient).colors;
					o["galphas"] = (item as CDGradient).alphas;
				}

				var c:Array = [];
					for each( var child:CDItem in item.children ) {
						c.push( parseObject( child ) );
					}
				o["children"] = c;

				return o;
			};

			for each( model in items ) {
				data.push( parseObject( model.item, true ) );
			}

			var json:String = JSON.stringify( { clip:"clop456", items : data } );

			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, json );
		}

		public static function paste():void {
			if( DataModel.currentLayer == null ) {
				return;
			}

			var data:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;

			try {
				var json:Object = JSON.parse( data );
			} catch( e:Error ) {
				return;
			}

			if( !(json["clip"] != null && json["clip"] == "clop456") ) {
				return;
			}

			var validName:Function = function( name:String, layer:CDItem ):String {
				var children:Vector.<CDItem> = layer.children;
				for each( var child:CDItem in children ) {
					if( child.name == name ) {
						return validName( name + "_copy", layer );
					}
				}
				return name;
			};

			var items:Array = json["items"];

			var parseObject:Function = function( obj:Object, parent:CDItem, offset:Boolean = false ):void {
				var item:CDItem;

				switch( obj["type"] ) {
					case CDItem.TYPE_ITEM:
						item = new CDItem( parent, validName(obj["name"], parent) );
					break;

					case CDItem.TYPE_TEXT:
						item = new CDText( parent, validName(obj["name"], parent) );

						(item as CDText).text = obj["text"];
						(item as CDText).align = obj["texta"];
					break;

					case CDItem.TYPE_GRADIENT:
						item = new CDGradient( parent, validName(obj["name"], parent) );

						(item as CDGradient).colors = obj["gcolors"];
						(item as CDGradient).alphas = obj["galphas"];
					break;

					default:
					break;
				}

				item.setXYWH(
					(offset ? DataModel.LAYER_MOUSE.x : 0) + obj["x"],
					(offset ? DataModel.LAYER_MOUSE.y : 0) + obj["y"],
					obj["w"],
					obj["h"]
				);

				item.asset = obj["asset"];
				item.aspectRatioAlign = obj["ar"];
				item.aspectRatioType = obj["at"];
				item.enabled = obj["e"] as Boolean;
				item.visible = obj["v"] as Boolean;
				item.color = obj["c"] as uint;
				item.alpha = obj["a"] as Number;
				item.note = obj["note"] as String;

				for each( var child:Object in obj["children"] ) {
					parseObject( child, item );
				}

				parent.addChild(item);
			};

			for each( var obj:Object in items ) {
				parseObject( obj, DataModel.currentLayer, WACOM_COPYPASTE ? false : true );
			}
		}
	}
}
