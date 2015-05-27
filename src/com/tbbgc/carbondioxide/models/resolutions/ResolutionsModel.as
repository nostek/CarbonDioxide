package com.tbbgc.carbondioxide.models.resolutions {
	import com.tbbgc.carbondioxide.models.cd.CDResolution;
	/**
	 * @author simonrodriguez
	 */
	public class ResolutionsModel {
		private static const RESOLUTIONS:Array = 	[
			//Apple
			{name:"iPhone3Gs", 		width:320, 	height:480,  dpi:163},
			{name:"iPhone4/4s", 	width:640, 	height:960,  dpi:326},
			{name:"iPhone5/5s/5c",	width:640, 	height:1136, dpi:326},
			{name:"iPhone6",		width:750, 	height:1334, dpi:326},
			{name:"iPhone6 Plus",	width:1080,	height:1980, dpi:401},
			{name:"iPad1/2", 		width:768, 	height:1024, dpi:132},
			{name:"iPad3/4/Air", 	width:1536, height:2048, dpi:264},
			{name:"iPad Mini", 		width:768,  height:1024, dpi:163},
			{name:"iPad Mini Air", 	width:1536, height:2048, dpi:326},

			//Android
			{name:"SE Xperia Arc", 			width:480,  height:854,  dpi:233},
			{name:"SE X10 Mini", 			width:240,  height:320,  dpi:157},
			{name:"Samsung Galaxy S", 		width:480,  height:800,  dpi:233},
			{name:"Samsung Galaxy S3", 		width:720,  height:1280, dpi:306},
			{name:"Samsung Galaxy S4", 		width:1080, height:1920, dpi:441},
			{name:"Samsung Galaxy Nexus", 	width:720,  height:1280, dpi:316},
			{name:"Google Nexus 6",			width:1440, height:2560, dpi:493},
			{name:"Samsung Galaxy Tab 10", 	width:800,  height:1280, dpi:149},
			{name:"Google Nexus 7",			width:1200, height:1920, dpi:323},
			{name:"Google Nexus 10",		width:1600, height:2560, dpi:300},

			//Amazon
			{name:"Kindle Fire", 		width:600,  height:1024, dpi:169},
			{name:"Kindle Fire HD", 	width:800,  height:1280, dpi:216},
			{name:"Kindle Fire HDX", 	width:1200, height:1920, dpi:323},

			//Desktop
			{name:"Desktop", width:600,  height:800,  dpi:72, desktop:true},
			{name:"Desktop", width:768,  height:1024, dpi:72, desktop:true},
			{name:"Desktop", width:1080, height:1920, dpi:72, desktop:true},
			{name:"Desktop", width:1440, height:2560, dpi:72, desktop:true},
		];

		public static function getScreenSize( width:int, height:int, dpi:int ):Number {
			var iw:Number = width/dpi;
			var ih:Number = height/dpi;

			var size:Number = Math.sqrt( (iw*iw) + (ih*ih) );

			size *= 10;
			size = size >> 0;
			size /= 10;

			return size;
		};

		public static function get resolutions():Array {
			var o:Object;

			var ret:Array = [];

			var getName:Function = function( o:Object, portrait:Boolean, desktop:Boolean=false ):String {
				var h:int = o["width"];
				var w:int = o["height"];
				var dpi:int = o["dpi"];

				var size:Number = getScreenSize(w,h,dpi);

				var ret:String = o["name"];
				if( !desktop ) {
					ret += (portrait ? " portrait" : " landscape");
				}
				if( portrait) {
					ret += " (" + h + "x" + w;
				} else {
					ret += " (" + w + "x" + h;
				}
				if( !desktop ) {
					ret += " DPI:" + o["dpi"];
					ret += " SIZE:" + size.toPrecision(2)+'"';
				}
				ret += ")";
				return ret;
			};

			for each( o in RESOLUTIONS ) {
				if( o["desktop"] == true ) {
					ret.push({
						label: getName(o, false, true),
						width: o["height"],
						height: o["width"],
						dpi: o["dpi"],
						size: getScreenSize(o["width"], o["height"], o["dpi"]),
						desktop:true
					});
				} else {
					ret.push({
						label: getName(o, true),
						width: o["width"],
						height: o["height"],
						dpi: o["dpi"],
						size: getScreenSize(o["width"], o["height"], o["dpi"]),
						desktop:false
					},
					{
						label: getName(o, false),
						width: o["height"],
						height: o["width"],
						dpi: o["dpi"],
						size: getScreenSize(o["width"], o["height"], o["dpi"]),
						desktop:false
					});
				}
			}

			return ret;
		}

		public static function getResolutionNameFromModel( model:CDResolution ):String {
			var res:Array = resolutions;

			for each( var o:Object in res ) {
				if( o["width"] == model.screenWidth && o["height"] == model.screenHeight && o["dpi"] == model.screenDPI ) {
					return o["label"];
				}
			}

			return "unidentified";
		}

		public static function getBestGuessFromWidthHeight( width:int, height:int ):Object {
			var res:Array = resolutions;

			for each( var o:Object in res ) {
				if( o["width"] == width && o["height"] == height ) {
					return o;
				}
			}

			return null;
		}
	}
}
