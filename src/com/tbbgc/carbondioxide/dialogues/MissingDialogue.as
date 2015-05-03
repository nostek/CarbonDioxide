package com.tbbgc.carbondioxide.dialogues {
	import fl.controls.List;

	import com.tbbgc.carbondioxide.managers.AssetsManager;
	import com.tbbgc.carbondioxide.managers.SettingsManager;
	import com.tbbgc.carbondioxide.managers.ViewsManager;
	import com.tbbgc.carbondioxide.models.cd.CDItem;
	import com.tbbgc.carbondioxide.models.cd.CDView;

	/**
	 * @author simonrodriguez
	 */
	public class MissingDialogue extends BaseDialogue {
		private var _list:List;

		public function MissingDialogue() {
			const WIDTH:int = 350;
			const HEIGHT:int = 400;

			super("Missing Assets", true, false, true, true);

			_list = new List();
			_list.width = 330;
			_list.height = 380;
			container.addChild(_list);

			init( WIDTH, HEIGHT );

			populate();
		}

		override protected function onResize( width:int, height:int ):void {
			_list.width = width;
			_list.height = height;
		}

		override protected function get dialogueID():String { return SettingsManager.SETTINGS_MISSING; }

		private function populate():void {
			var needed:Array = [];

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

			var names:Vector.<Object> = AssetsManager.names;

			for each( var o:Object in names ) {
				if( needed.indexOf(o["frame"]) >= 0 ) {
					needed.splice( needed.indexOf(o["frame"]), 1 );
				}
			}

			for each( var s:String in needed ) {
				_list.addItem({label:s});
			}
		}
	}
}
