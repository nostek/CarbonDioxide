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
			const d:String = '{"key":"cbdd","views":[{"type":0,"children":[{"children":[{"type":1,"resolutions":[{"y":0.016666666666666666,"w":0.05555555555555555,"h":0.08333333333333333,"screenwidth":1000,"screenheight":700,"x":0.011111111111111112}],"asset":"avatar_180x180","name":"child1","ar":1},{"type":1,"resolutions":[{"y":0.016666666666666666,"w":0.05555555555555555,"h":0.08333333333333333,"screenwidth":1000,"screenheight":700,"x":0.9333333333333333}],"asset":"avatar_180x180","name":"child2","ar":3}],"ar":5,"type":1,"resolutions":[{"y":0.07142857142857142,"w":0.9,"h":0.8571428571428571,"screenwidth":1000,"screenheight":700,"x":0.05}],"asset":"overlay_big_suiteshop_bg","name":"test"}],"name":"main"},{"type":0,"children":[{"type":1,"resolutions":[{"y":0.07142857142857142,"w":0.3,"h":0.5714285714285714,"screenwidth":1000,"screenheight":700,"x":0.05}],"name":"test2"}],"name":"main2"}],"version":1}';
			
			try {
				const data:Object = JSON.parse( d );	  
			} catch( e:* ) {
				error( "Unable to parse JSON");
				return null;
			}
			
			if( data["key"] == null || data["key"] != "cbdd" ) {
				error("Wrong key in file");
				return null;
			}

			if( data["version"] == null ) {
				error("No version in file");
				return null;
			}
			
			return data;
		}
		
		private static function parseData( data:Object ):void {
			const version:int = data["version"];

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
