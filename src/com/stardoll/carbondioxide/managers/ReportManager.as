package com.stardoll.carbondioxide.managers {
	import com.stardoll.carbondioxide.dialogues.ReportDialogue;
	import com.stardoll.carbondioxide.models.cd.CDItem;
	import com.stardoll.carbondioxide.models.cd.CDView;
	import com.stardoll.carbondioxide.utils.Drawer;
	import com.stardoll.carbondioxide.utils.Legacy;
	/**
	 * @author Simon
	 */
	public class ReportManager {
		private static var TEXT:String;

		public static function clear():void {
			TEXT = "";
		}

		public static function add( ...args ):void {
			var r:String = "";
			for each( var o:Object in args ) {
				r += o.toString() + " ";
			}

			if( TEXT == null ) {
				TEXT = "";
			}

			TEXT = TEXT + r + "\n";

			EventManager.showReport( onShow );
		}

		private static function onShow():void {
			new ReportDialogue(TEXT);

			TEXT = "";
		}

		public static function compile():void {
			clear();
			compileMissing();
			compileNotUsed();
			compileDepth();
		}

		private static function compileMissing():void {
			add("_= Missing Assets =_");

			var needed:Array = Legacy.LEGACY ? Legacy.LEGACY.concat() : [];

			const views:Vector.<CDView> = ViewsManager.views;

			var rec:Function = function( item:CDItem ):void {
				if( item.asset != null ) {
					if( needed.indexOf( item.asset ) < 0 ) {
						needed.push( item.asset );
					}
				}

				for each( var ch:CDItem in item.children ) {
					rec( ch );
				}
			};

			for each( var view:CDView in views ) {
				for each( var ch:CDItem in view.children ) {
					rec( ch );
				}
			}

			var names:Vector.<Object> = Drawer.names;

			for each( var o:Object in names ) {
				if( needed.indexOf(o["frame"]) >= 0 ) {
					needed.splice( needed.indexOf(o["frame"]), 1 );
				}
			}

			for each( var s:String in needed ) {
				add( s );
			}

			add("");
		}

		private static function compileNotUsed():void {
			add("_= Not used =_");

			var needed:Array = [];

			const views:Vector.<CDView> = ViewsManager.views;

			var stile:Function = function( s:String, match:String, ...other ):void {
				if( s.substr( s.length - match.length, match.length) == match ) {
					for each( var x:String in other ) {
						var t:String = s.substr( 0, s.length - match.length) + x;
						if( needed.indexOf( t ) < 0 ) {
							needed.push( t );
						}
					}
				}
			};

			var leg:Array = Legacy.LEGACY;
			if( leg != null ) {
				for each( var l:String in leg ) {
					needed.push( l );

					stile( l, "_DOWN", "_UP", "_ACTIVE", "_INACTIVE" );
					stile( l, "_UP", "_DOWN", "_ACTIVE", "_INACTIVE" );
					stile( l, "_ACTIVE", "_DOWN", "_UP", "_INACTIVE" );
					stile( l, "_INACTIVE", "_DOWN", "_UP", "_ACTIVE" );
				}
			}

			var rec:Function = function( item:CDItem ):void {
				if( item.asset != null ) {
					if( needed.indexOf( item.asset ) < 0 ) {
						needed.push( item.asset );

						stile( item.asset, "_off", "_on" );
						stile( item.asset, "_on", "_off" );
						stile( item.asset, "_inactive", "_active" );
						stile( item.asset, "_active", "_inactive" );

						stile( item.asset, "_DOWN", "_UP", "_ACTIVE", "_INACTIVE" );
						stile( item.asset, "_UP", "_DOWN", "_ACTIVE", "_INACTIVE" );
						stile( item.asset, "_ACTIVE", "_DOWN", "_UP", "_INACTIVE" );
						stile( item.asset, "_INACTIVE", "_DOWN", "_UP", "_ACTIVE" );
					}
				}

				for each( var ch:CDItem in item.children ) {
					rec( ch );
				}
			};

			for each( var view:CDView in views ) {
				for each( var ch:CDItem in view.children ) {
					rec( ch );
				}
			}

			var names:Vector.<Object> = Drawer.names;

			for each( var s:String in needed ) {
				for( var k:Object in names ) {
					if( names[k] != null && names[k]["frame"] == s ) {
						names[k] = null;
					}
				}
			}

			for each( var o:Object in names ) {
				if( o != null ) {
					add( o["frame"] + " (" + o["pack"] + ")" );
				}
			}

			add("");
		}

		private static function compileDepth():void {
			add("_= Draw calls =_");

			add( Drawer.analyze );

			add("");
		}
	}
}
