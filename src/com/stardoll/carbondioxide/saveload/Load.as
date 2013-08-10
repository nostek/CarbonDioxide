package com.stardoll.carbondioxide.saveload {
	import com.stardoll.carbondioxide.managers.ViewsManager;
	import com.stardoll.carbondioxide.models.DataModel;
	import com.stardoll.carbondioxide.dialogues.PopupDialogue;
	/**
	 * @author simonrodriguez
	 */
	public class Load {
		public static function run():void {
			var data:Object = loadData();
			
			if( data != null ) {
				parseData( data );
			}
		}
		
		private static function error( msg:String ):void {
			new PopupDialogue("ERROR", msg);
		}
		
		private static function loadData():Object {
			const d:String = '{"k":"cbdd","v":1,"c":[{"c":[{"n":1,"a":2,"t":1,"c":[{"n":3,"a":4,"t":1,"ar":1,"r":[[1000,700,0.011111111111111112,0.016666666666666666,0.05555555555555555,0.08333333333333333]]},{"n":5,"a":4,"t":1,"ar":3,"r":[[1000,700,0.9333333333333333,0.016666666666666666,0.05555555555555555,0.08333333333333333]]}],"ar":5,"r":[[1000,700,0.05,0.07142857142857142,0.9,0.8571428571428571]]}],"n":0,"t":0},{"c":[{"n":7,"t":1,"r":[[1000,700,0.05,0.07142857142857142,0.3,0.5714285714285714]]}],"n":6,"t":0}],"t":["main","test","overlay_big_suiteshop_bg","child1","avatar_180x180","child2","main2","test2"]}';
			
			try {
				const data:Object = JSON.parse( d );	  
			} catch( e:* ) {
				error( "Unable to parse JSON");
				return null;
			}
			
			if( data[ SLKeys.MAIN_KEY ] == null || data[ SLKeys.MAIN_KEY ] != "cbdd" ) {
				error("Wrong key in file");
				return null;
			}

			if( data[ SLKeys.MAIN_VERSION ] == null ) {
				error("No version in file");
				return null;
			}
			
			return data;
		}
		
		private static function parseData( data:Object ):void {
			const version:int = data[ SLKeys.MAIN_VERSION ];

			switch( version ) {
				case 1:
					Load_v1.parseViews( data );
				break;

				default:
					error("Unknown version: " + version.toString());
					return;
				break;
			}
			
			DataModel.setView( ViewsManager.views[0] );
		}
	}
}
