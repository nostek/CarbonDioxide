package com.stardoll.carbondioxide.models.resolutions {
	/**
	 * @author simonrodriguez
	 */
	public class ResolutionsModel {
		private static const RESOLUTIONS:Array = 	[
			{name:"iPhone3GS", 				width:320, height:480, status:20},
			{name:"iPhone4", 				width:640, height:960, status:40},
			{name:"iPhone5", 				width:640, height:1136, status:40},
			{name:"iPad1/2", 				width:768, height:1024, status:20},
			{name:"iPad3", 					width:1536, height:2048, status:40},

			{name:"Samsung Galaxy S", 		width:480, height:800},
			{name:"Samsung Galaxy Nexus", 	width:720, height:1280},
			{name:"Samsung Galaxy Tab", 	width:800, height:1280},
			{name:"SE Xperia Arc", 			width:480, height:854},
			{name:"SE X10 Mini", 			width:240, height:320},
		];

		public static function get resolutions():Array {
			var o:Object;

			var ret:Array = [];

			for each( o in RESOLUTIONS ) {
				ret.push({
					label: o["name"] + " portrait",
					width: o["width"],
					height: o["height"]
				},
				{
					label: o["name"] + " landscape",
					width: o["height"],
					height: o["width"]
				});

				if( o["status"] != null ) {
					ret.push({
						label: o["name"] + " portrait (w. status)",
						width: o["width"],
						height: o["height"] - o["status"]
					},
					{
						label: o["name"] + " landscape (w. status)",
						width: o["height"],
						height: o["width"] - o["status"]
					});
				}
			}

			return ret;
		}
	}
}
