package com.stardoll.carbondioxide.utils {
	import com.stardoll.carbondioxide.managers.ReportManager;
	import com.stardoll.carbondioxide.models.DataModel;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getQualifiedClassName;
	/**
	 * @author simonrodriguez
	 */
	public class Drawer {
		private static const QUALITY:String = StageQuality.BEST;

		private static var _matrix:Matrix;
		private static var _point:Point;

		private static var _textField:TextField;

		private static var _packs:Vector.<PackModel>;

		private static var _effects:EffectModel;

		public function Drawer() {
			_matrix = new Matrix();
			_point = new Point();

			_textField = new TextField();
			_textField.embedFonts = true;
			_textField.antiAliasType = AntiAliasType.ADVANCED;
			_textField.autoSize = TextFieldAutoSize.LEFT;

			_packs = new Vector.<PackModel>();

			_effects = new EffectModel();
		}

		public static function get names():Vector.<Object> {
			var ret:Vector.<Object> = new Vector.<Object>();

			var len:int;
			var model:FrameModel;

			for( var y:int = 0; y < _packs.length; y++ ) {
				len = _packs[y].frames.length;
				for( var i:int = 0; i < len; i++ ) {
					model = _packs[y].frames[i];
					if( model != null ) {
						ret[ret.length] = {
							name: model.name + ((model.scale9) ? ((model.scale9inside==null) ? " [9scale]" : " [9scale][OLD SETUP]") : ""),
							frame: model.name,
							pack: _packs[y].name
						};
					}
				}
			}

			return ret;
		}

		public static function get analyze():String {
			var r:String = "";

			var pack:PackModel;
			var model:FrameModel;
			var frames:int;
			var count:int;

			var countChildren:Function = function ( ooo:DisplayObject ):int {
				if( ooo is DisplayObjectContainer ) {
					var ccc:int = 0;

					ccc = (ooo as DisplayObjectContainer).numChildren;

					for( var iii:int = 0; iii < (ooo as DisplayObjectContainer).numChildren; iii++ ) {
						ccc += countChildren( (ooo as DisplayObjectContainer).getChildAt(iii) );
					}

					return ccc;
				}

				return 0;
			};

			var finds:Vector.<Object> = new Vector.<Object>();

			const len:int = _packs.length;
			for( var x:int = 0; x < len; x++ ) {
				pack = _packs[x];

				frames = pack.frames.length;
				for( var i:int = 0; i < frames; i++ ) {
					model = pack.frames[i];
					if( model != null && model.data != null ) {
						count = countChildren( model.data );
						if( count > 20 ) {
							finds.push( {c:count, n:model.name + " : " + count.toString() + " (" + pack.name + ")"} );
						}
					}
				}
			}

			finds = finds.sort( function(a:Object, b:Object):int {
				if( int(a["c"]) == int(b["c"]) ) return 0;
				return (int(a["c"]) < int(b["c"])) ? 1 : -1;
			});

			for each( var obj:Object in finds ) {
				r += obj["n"] + "\n";
			}

			return r;
		}

		public static function addPack( name:String, mc:MovieClip ):void {
			var pack:PackModel = getPack( name );

			exportFramesInit( mc, pack );
		}

		private static function getPack( name:String ):PackModel {
			for( var i:int = 0; i < _packs.length; i++ ) {
				if( _packs[i].name == name ) {
					return _packs[i];
				}
			}

			var model:PackModel = new PackModel();
			model.name = name;
			_packs.push( model );

			optimizePacks();

			return model;
		}

		private static function optimizePacks():void {
			for( var i:int = 1; i < _packs.length; i++ ) {
				if( _packs[i].name.indexOf("_") < 0 ) {
					var model:PackModel = _packs[i];
					_packs.splice( i, 1 );
					_packs.splice( 0, 0, model );
					return;
				}
			}
		}

		public static function getPackNameFromAsset( asset:String ):String {
			if( asset == null ) return null;

			for( var i:int = 0; i < _packs.length; i++ ) {
				if( _packs[i].hash[ asset as String ] != null ) {
					return _packs[i].name;
				}
			}

			return null;
		}

		private static function exportFramesInit( mc:MovieClip, pack:PackModel ):void {
			const len:int = mc.numChildren;

			mc.gotoAndStop(1);

			pack.frames = new Vector.<FrameModel>( len, true );
			pack.hash = {};

			exportFrames( mc, pack );
			exportOptionsMultiple( pack );
			exportTextMultiple( pack );
			exportEffects( pack );
		}

		private static function exportEffects( pack:PackModel ):void {
			var model:FrameModel;
			var con:Sprite;

			const len:int = pack.frames.length;
			for( var i:int = 0; i < len; i++ ) {
				if( pack.frames[i] == null ) continue;

				model = pack.frames[i];
				con = model.data as Sprite;

				var bm:BitmapData = exportEffectsRecursive(con, null, model);
				if( bm != null ) {
					bm.dispose();
				}

				if( model.effects != null && (_effects.buffer == null || _effects.buffer.length < model.effects.length * 2) ) {
					_effects.buffer = new Vector.<Number>( model.effects.length * 2, true );
				}
			}
		}

		private static function exportEffectsRecursive( o:DisplayObject, bm:BitmapData, model:FrameModel ):BitmapData {
			var r:Boolean;

			if( o.filters != null && o.filters.length > 0 ) {
				for each( var x:Object in o.filters ) {
					r = false;

					if( x is GlowFilter ) {
//						if( bm == null ) {
//							bm = new BitmapData(model.bounds.width, model.bounds.height, true, 0x0);
//						}
//						r = bm.generateFilterRect(bm.rect, (x as GlowFilter));
						r = true;
					} else if( x is DropShadowFilter ) {
//						if( bm == null ) {
//							bm = new BitmapData(model.bounds.width, model.bounds.height, true, 0x0);
//						}
//						r = bm.generateFilterRect(bm.rect, (x as DropShadowFilter));
						r = true;
					} else if( x is BlurFilter ) {
//						if( bm == null ) {
//							bm = new BitmapData(model.bounds.width, model.bounds.height, true, 0x0);
//						}
//						r = bm.generateFilterRect(bm.rect, (x as BlurFilter));
						r = true;
					} else if( x is ColorMatrixFilter ) {
						//Nothing
					} else {
						ReportManager.add(Drawer, "MISSING EFFECT:", x);
					}

					if( r == true ) {
						//model.bounds = model.bounds.union(r);

						if( model.effects == null ) model.effects = new Vector.<DisplayObject>();

						if( model.effects.indexOf(o) < 0 ) model.effects.push( o );
					}
				}
			}

			if( o is DisplayObjectContainer ) {
				var c:DisplayObjectContainer = o as DisplayObjectContainer;

				for( var i:int = 0; i < c.numChildren; i++ ) {
					bm = exportEffectsRecursive(c.getChildAt(i), bm, model);
				}
			}

			return bm;
		}

		private static function exportFrames( mc:MovieClip, pack:PackModel ):void {
			var model:FrameModel;
			var d:DisplayObject;

			var frame:int = 0;

			const len:int = pack.frames.length;

			while( frame != len ) {
				d = mc.getChildAt(frame);

				if( (d as Sprite) == null ) {
					ReportManager.add(Drawer, "Dead object! Pack:", pack.name, "Frame:", frame, "Name:", d.name, "Type:", getQualifiedClassName(d), "Position:", d.x, d.y );
				} else {
					model = new FrameModel();

					model.data = d as Sprite;
					model.name = d.name;

					if( model.name.substr(0, "instance".length) == "instance" ) {
						ReportManager.add(Drawer, "Bad asset Pack:", pack.name, "Name:", model.name, "Type:", getQualifiedClassName(d), "Position:", d.x, d.y);
					}

					pack.frames[frame] = model;
					if( d.name != null ) {
						pack.hash[ d.name ] = model;
					}
				}

				frame++;
			}
		}

		private static function exportOptionsMultiple( pack:PackModel ):void {
			var model:FrameModel;
			var con:Sprite;
			var masker:DisplayObject;
			var mc:MovieClip;

			const len:int = pack.frames.length;
			for( var i:int = 0; i < len; i++ ) {
				if( pack.frames[i] == null ) continue;

				masker = null;
				con = null;
				mc = null;

				model = pack.frames[i];
				con = model.data as Sprite;

				model.bounds = model.data.getBounds(model.data);
				model.scale9 = false;
				model.scale9inside = null;

				masker = con.getChildByName("masker");
				if( masker != null ) {
					model.bounds.x = masker.x;
					model.bounds.y = masker.y;
					model.bounds.width = masker.width;
					model.bounds.height = masker.height;
					con.removeChild(masker);
				}

				mc = con as MovieClip;
				if( mc != null && mc.scale9Grid != null ) {
					model.scale9 = true;

					model.scale9outer = new Sprite();
					model.scale9outer.addChild( mc );

					if( masker == null ) {
						model.bounds = model.data.getBounds(model.scale9outer);
					}

					if( mc.getChildAt(0) is MovieClip ) {
						mc = mc.getChildAt(0) as MovieClip;
						if( mc.scale9Grid != null ) {
							model.scale9inside = mc;
						}
					}
				}
			}
		}

		private static function exportTextMultiple( pack:PackModel ):void {
			var con:Sprite;
			var tf:TextField;
			var filters:Array;
			var mc:MovieClip;
			var fmt:TextFormat;
			var html:String;

			const len:int = pack.frames.length;
			for( var i:int = 0; i < len; i++ ) {
				if( pack.frames[i] == null ) continue;

				tf = null;

				con = pack.frames[i].data as Sprite;

				if( con.getChildAt(0) is MovieClip ) {
					mc = con.getChildAt(0) as MovieClip;
					if( mc.numChildren > 0 ) {
						tf = (mc.getChildAt(0) as TextField);
						if( tf != null ) {
							ReportManager.add(Drawer, "Wrong text setting: Should be a TextField only. Name:", pack.frames[i].name);

							tf = null;
						}
					}
				}

				if( con.getChildAt(0) is TextField ) {
					tf = (con.getChildAt(0) as TextField);

					filters = tf.filters;
				}

				if( tf != null ) {
					fmt = tf.defaultTextFormat;

					html = tf.htmlText;
					if( html != null && html.length > 0 ) {
						html = html.toLowerCase();

						fmt.bold = (html.indexOf("<b>") >= 0);
						fmt.italic = (html.indexOf("<i>") >= 0);
						fmt.kerning = (html.indexOf('kerning="1"') >= 0);
					}

					if( fmt.italic != true && (fmt.font.toLowerCase().indexOf(" italic") >= 0) ) {
						fmt.italic = true;
					}

					tf.defaultTextFormat = fmt;
					tf.filters = filters;

					pack.frames[i].text = tf;
				}
			}
		}

		private static function getFrame( frame:Object ):FrameModel {
			var model:FrameModel;

			for( var i:int = 0; i < _packs.length; i++ ) {
				if( frame is String ) {
					model = _packs[i].hash[ frame as String ];
				} else {
					model = _packs[i].frames[ frame as int ];
				}

				if( model != null ) {
					return model;
				}
			}

			return null;
		}

		public static function getMovieclip(frame:String):* {
			var model:FrameModel = getFrame(frame);

			if( model != null ) {
				return model.data;
			}

			return null;
		}

		public static function getBounds(frame:String):Rectangle {
			var model:FrameModel = getFrame(frame);

			if( model != null ) {
				return model.bounds;
			}

			return null;
		}

		public static function haveFrame( frame:Object ):Boolean {
			return (getFrame( frame )!=null);
		}

		private static function get scaleResolution():Number {
			return (1536 / DataModel.SCREEN_HEIGHT);
		}
		private static function get scaleResolutionInv():Number {
			return (DataModel.SCREEN_HEIGHT / 1536);
		}

		//////////////////////////////////////////

		public static function draw( frame:Object, width:Number, height:Number, transparent:Boolean=true, background:uint=0x00000000 ):BitmapData {
			var bmp:BitmapData = new BitmapData(Math.ceil(width), Math.ceil(height), transparent, background);
				drawOnEx( bmp, frame, 0, 0, width, height );
			return bmp;
		}

		public static function drawCenter( frame:Object, width:Number, height:Number, transparent:Boolean=true, background:uint=0x00000000 ):BitmapData {
			var bmp:BitmapData = new BitmapData(Math.ceil(width), Math.ceil(height), transparent, background);

			drawOnExCenter( bmp, frame, 0, 0, width, height );

			return bmp;
		}

		public static function drawOnEx( target:BitmapData, frame:Object, x:Number, y:Number, width:Number, height:Number ):void {
			var model:FrameModel = getFrame(frame);

			if( model != null ) {
				const b:Rectangle = model.bounds;

				_matrix.identity();

				if( !model.scale9 ) {
					const sx:Number = width / b.width;
					const sy:Number = height / b.height;

					if( model.effects ) changeEffects( model, sx, sx );

					_matrix.scale(sx, sy);
					_matrix.translate((-b.x*sx)+x, (-b.y*sy)+y);

					target.drawWithQuality(model.data, _matrix, null, null, null, true, QUALITY);

					if( model.effects ) restoreEffects( model );
				} else {
					if( model.scale9inside != null ) {
						model.scale9inside.width = width * scaleResolution;
						model.scale9inside.height = height * scaleResolution;

						model.data.width = width;
						model.data.height = height;

						_matrix.translate((-b.x)+x, (-b.y)+y);
					} else {
						model.data.width = width * scaleResolution;
						model.data.height = height * scaleResolution;

						_matrix.scale(scaleResolutionInv, scaleResolutionInv);
						_matrix.translate((-b.x*scaleResolutionInv)+x, (-b.y*scaleResolutionInv)+y);
					}

					target.drawWithQuality(model.scale9outer, _matrix, null, null, null, true, QUALITY);
				}
			}
		}

		public static function drawOnExCenter( target:BitmapData, frame:Object, x:Number, y:Number, width:Number, height:Number ):void {
			var model:FrameModel = getFrame(frame);

			if( model != null ) {
				const b:Rectangle = model.bounds;

				var sx:Number = Math.min( width/b.width, height/b.height);

				if( model.effects ) changeEffects( model, sx, sx );

				x += (width - b.width*sx) / 2;
				y += (height - b.height*sx) / 2;

				_matrix.identity();
				_matrix.scale(sx, sx);
				_matrix.translate((-b.x*sx)+x, (-b.y*sx)+y);

				target.drawWithQuality(model.data, _matrix, null, null, null, true, QUALITY);

				if( model.effects ) restoreEffects( model );
			}
		}

//		public function drawOnExRotation( target:BitmapData, frame:Object, x:Number, y:Number, width:Number, height:Number, rotation:Number ):void {
//			var model:FrameModel = getFrame(frame);
//
//			if( model != null ) {
//				var b:Rectangle = model.bounds;
//
//				//A really really bad fix.
//				if( rotation == 90 || rotation == 270 ) {
//					var t:Number = b.width;
//					b.width = b.height;
//					b.height = t;
//				}
//
//				_matrix.identity();
//
//				_matrix.rotate(deg2rad(rotation));
//
//				if( !model.scale9 ) {
//					const sx:Number = width / b.width;
//					const sy:Number = height / b.height;
//
//					_matrix.scale(sx, sy);
//					_matrix.translate((-b.x*sx)+x, (-b.y*sy)+y);
//
//					target.drawWithQuality(model.data, _matrix, null, null, null, true, QUALITY);
//				} else {
//					if( model.scale9inside != null ) {
//						model.scale9inside.width = width * _scaleResolution;
//						model.scale9inside.height = height * _scaleResolution;
//					}
//
//					model.data.width = width;
//					model.data.height = height;
//
//					_matrix.translate((-b.x)+x, (-b.y)+y);
//
//					target.drawWithQuality(model.scale9outer, _matrix, null, null, null, true, QUALITY);
//				}
//			}
//		}

		///////

		private static function changeEffects( model:FrameModel, sx:Number, sy:Number ):void {
			_effects.sx = sx;
			_effects.sy = sy;
			_effects.index = 0;

			var a:Array;

			const len:int = model.effects.length;
			for( var i:int = 0; i < len; i++ ) {
				a = model.effects[ i ].filters;

				for each( var o:Object in a ) {
					if( o is GlowFilter ) {
						_effects.buffer[ _effects.index++ ] = (o as GlowFilter).blurX;
						_effects.buffer[ _effects.index++ ] = (o as GlowFilter).blurY;

						(o as GlowFilter).blurX *= _effects.sx;
						(o as GlowFilter).blurY *= _effects.sy;
//						trace( "set", o, (o as GlowFilter).blurX, (o as GlowFilter).blurY );
					} else if ( o is DropShadowFilter ) {
						_effects.buffer[ _effects.index++ ] = (o as DropShadowFilter).blurX;
						_effects.buffer[ _effects.index++ ] = (o as DropShadowFilter).blurY;

						(o as DropShadowFilter).blurX *= _effects.sx;
						(o as DropShadowFilter).blurY *= _effects.sy;
//						trace( "set", o, (o as DropShadowFilter).blurX, (o as DropShadowFilter).blurY );
					} else if( o is BlurFilter ) {
						_effects.buffer[ _effects.index++ ] = (o as BlurFilter).blurX;
						_effects.buffer[ _effects.index++ ] = (o as BlurFilter).blurY;

						(o as BlurFilter).blurX *= _effects.sx;
						(o as BlurFilter).blurY *= _effects.sy;
//						trace( "set", o, (o as BlurFilter).blurX, (o as BlurFilter).blurY );
					}
				}

				model.effects[ i ].filters = a;
			}
		}

		private static function restoreEffects( model:FrameModel ):void {
			_effects.index = 0;

			var a:Array;

			const len:int = model.effects.length;
			for( var i:int = 0; i < len; i++ ) {
				a = model.effects[ i ].filters;

				for each( var o:Object in a ) {
					if( o is GlowFilter ) {
						(o as GlowFilter).blurX = _effects.buffer[ _effects.index++ ];
						(o as GlowFilter).blurY = _effects.buffer[ _effects.index++ ];
//						trace( "restore", o, (o as GlowFilter).blurX, (o as GlowFilter).blurY );
					} else if( o is DropShadowFilter ) {
						(o as DropShadowFilter).blurX = _effects.buffer[ _effects.index++ ];
						(o as DropShadowFilter).blurY = _effects.buffer[ _effects.index++ ];
//						trace( "restore", o, (o as DropShadowFilter).blurX, (o as DropShadowFilter).blurY );
					} else if( o is BlurFilter ) {
						(o as BlurFilter).blurX = _effects.buffer[ _effects.index++ ];
						(o as BlurFilter).blurY = _effects.buffer[ _effects.index++ ];
//						trace( "restore", o, (o as BlurFilter).blurX, (o as BlurFilter).blurY );
					}
				}

				model.effects[ i ].filters = a;
			}
		}

		///////

		public static function applyFont( t:TextField, frame:Object, fmtoptions:TextFormat=null ):void {
			var model:FrameModel = getFrame( frame );
			if( model != null ) {
				if( model.text != null ) {
					var fmt:TextFormat = model.text.defaultTextFormat;

					if( fmtoptions != null ) {
						if( fmtoptions.font != null ) fmt.font = fmtoptions.font;
						if( fmtoptions.size != null ) fmt.size = fmtoptions.size;
						if( fmtoptions.color != null ) fmt.color = fmtoptions.color;
						if( fmtoptions.align != null ) fmt.align = fmtoptions.align;
					}

					t.defaultTextFormat = fmt;
					t.filters = model.text.filters;
					t.embedFonts = true;
					t.antiAliasType = AntiAliasType.ADVANCED;
					t.autoSize = TextFieldAutoSize.LEFT;
				} else {
//					CB_trace.error(this, "Could not find text properties on frame:", frame);
				}
			}
		}

		public function drawTextFieldOn( target:BitmapData, draw:TextField, x:int, y:int):void {
			_matrix.identity();
			_matrix.translate(x, y);

			target.drawWithQuality(draw, _matrix, null, null, null, true, QUALITY);
		}

		private static function getTextField( frame:Object, fmt:TextFormat ):TextField {
			if( frame == null ) {
				var tf:TextField = new TextField();
				tf.autoSize = TextFieldAutoSize.LEFT;

				if( fmt != null ) {
					tf.defaultTextFormat = fmt;
				}
				return tf;
			} else {
				applyFont(_textField, frame, fmt);
			}

			return _textField;
		}

		public static function drawText( text:String, frame:Object, height:int, width:int=0, fmt:TextFormat=null ):BitmapData {
			const hasAlign:Boolean = (fmt != null && fmt.align != null);

			var tf:TextField = getTextField(frame, fmt);

			fmt = tf.defaultTextFormat;
				fmt.size = height;
				if( !hasAlign) fmt.align = TextFormatAlign.LEFT;
			tf.defaultTextFormat = fmt;

			tf.width = width;
			tf.wordWrap = (width!=0);

			tf.htmlText = text;

			var bm:BitmapData = new BitmapData(Math.max(tf.width, tf.textWidth), Math.max(tf.height, tf.textHeight), true, 0x0);
			bm.drawWithQuality(tf, null, null, null, null, true, QUALITY);

			return bm;
		}

		///////

		public function drawBitmapOn( target:BitmapData, source:BitmapData, x:int, y:int ):void {
			_point.x = x;
			_point.y = y;

			target.copyPixels(source, source.rect, _point, null, null, true);
		}
	}
}



import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.text.TextField;



internal class FrameModel {
	public var name:String;

	public var data:DisplayObjectContainer;
	public var bounds:Rectangle;

	public var text:TextField;

	public var scale9:Boolean;
	public var scale9inside:MovieClip;
	public var scale9outer:Sprite;

	public var effects:Vector.<DisplayObject>;
}



internal final class PackModel {
	public var name:String;

	public var frames:Vector.<FrameModel>;
	public var hash:Object;
}



internal final class EffectModel {
	public var sx:Number;
	public var sy:Number;

	public var buffer:Vector.<Number>;

	public var index:int;

	public function EffectModel() {
		index = 0;
	}
}