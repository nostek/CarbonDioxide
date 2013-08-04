package com.stardoll.carbondioxide.utils {
	import com.stardoll.carbondioxide.dialogues.PopupDialogue;
	import com.stardoll.carbondioxide.managers.ViewsManager;
	import com.stardoll.carbondioxide.models.DataModel;
	import com.stardoll.carbondioxide.models.cd.CDView;
	/**
	 * @author Simon
	 */
	public class SaveLoad {
		public static const CURRENT_VERSION:int = 1;
		
		private static function error( msg:String ):void {
			new PopupDialogue("ERROR", msg);
		}
		
		public static function save():void {
			var data:Object = {
				key: "cbdd",
				version: CURRENT_VERSION
			};
			
			var v:Array = [];
			
			const views:Vector.<CDView> = ViewsManager.views;
			
			const len:int = views.length;
			for( var i:int = 0; i < len; i++ ) {
				v.push( views[i].save() );
			}
			
			data["views"] = v;
			
			trace( JSON.stringify(data) );
		}
		
		public static function load():void {
			const d:String = '{"key": "cbdd", "views":[{"type":0,"children":[{"resolutions":[{"y":0.07142857142857142,"screenHeight":700,"h":0.8571428571428571,"w":0.9,"screenWidth":1000,"x":0.05}],"ar":5,"type":1,"children":[{"type":1,"resolutions":[{"y":0.016666666666666666,"screenHeight":700,"h":0.08333333333333333,"w":0.05555555555555555,"screenWidth":1000,"x":0.011111111111111112}],"name":"child1","ar":1,"asset":"avatar_180x180"},{"type":1,"resolutions":[{"y":0.016666666666666666,"screenHeight":700,"h":0.08333333333333333,"w":0.05555555555555555,"screenWidth":1000,"x":0.9333333333333333}],"name":"child2","ar":3,"asset":"avatar_180x180"}],"name":"test","asset":"overlay_big_suiteshop_bg"}],"name":"main"},{"type":0,"children":[{"type":1,"resolutions":[{"y":0.07142857142857142,"screenHeight":700,"h":0.5714285714285714,"w":0.3,"screenWidth":1000,"x":0.05}],"name":"test2","ar":0,"asset":null}],"name":"main2"}],"version":1}';
			
			try {
				const data:Object = JSON.parse( d );
			} catch( e:* ) {
				error( "Unable to parse JSON");
				return;
			}
			
			if( data["key"] == null || data["key"] != "cbdd" ) {
				error("Wrong key in file");
				return;
			}
			
			if( data["version"] == null ) {
				error("No version in file");
				return;
			}
			
			ViewsManager.clearViews();
						
			const version:int = data["version"];
			
			switch( version ) {
				case 1:
					load_version1( data );
				break;
				
				default:
					error("Unknown version: " + version.toString());
				break;
			}
		}
		
		private static function load_version1( data:Object ):void {
			const views:Array = ObjectEx.select(data, "views", null);
			
			if( views == null ) {
				error("No views");
				return;
			}
			
			var view:CDView;
			
			const len:int = views.length;
			for( var i:int = 0; i < len; i++ ) {
				view = new CDView(null);
				view.load( 1, views[i] );
				
				ViewsManager.addView( view );
			}
			
			DataModel.setView( ViewsManager.views[0] );
		}
	}
}
