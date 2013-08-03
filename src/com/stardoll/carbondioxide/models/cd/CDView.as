package com.stardoll.carbondioxide.models.cd {
	import com.stardoll.carbondioxide.models.DataModel;

	/**
	 * @author simonrodriguez
	 */
	public class CDView extends CDItem {
		public function CDView( name:String ) {
			super( null, name );
		}

		override public function get type():int {
			return TYPE_VIEW;
		}

		override public function get width():int {
			return DataModel.SCREEN_WIDTH;
		}

		override public function get height():int {
			return DataModel.SCREEN_HEIGHT;
		}

		override public function get worldX():int {
			return 0;
		}

		override public function get worldY():int {
			return 0;
		}

		override public function updateDisplayProperties():void {
			trace( "CDView", name );

			const len:int = children.length;
			for( var i:int = 0; i < len; i++ ) {
				children[i].updateDisplayProperties();
			}
		}

		override public function toString() : String {
			return "CDView( " + width + " " + height + " )";
		}
		
		///////////////////////////////////
		// Save & Load
		
		override public function save():Object {
			var indata:Object = super.save();
			
			if( indata["children"] == null ) {
				return {
					type: this.type,
					name: this.name
				};
			}
			
			return {
				type: this.type,
				name: this.name,
				children: indata["children"]
			};
		}
	}
}
