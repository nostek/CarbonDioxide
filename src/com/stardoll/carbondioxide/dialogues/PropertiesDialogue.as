package com.stardoll.carbondioxide.dialogues {
	import fl.controls.Button;
	import fl.controls.List;
	import fl.events.ListEvent;

	import com.stardoll.carbondioxide.models.DataModel;
	import com.stardoll.carbondioxide.models.ItemModel;
	import com.stardoll.carbondioxide.models.cd.CDAspectRatio;
	import com.stardoll.carbondioxide.models.cd.CDItem;
	import com.stardoll.carbondioxide.utils.Drawer;

	import flash.geom.Rectangle;

	/**
	 * @author simonrodriguez
	 */
	public class PropertiesDialogue extends BaseDialogue {
		private var _properties:List;
		private var _add:Button;
		private var _del:Button;

		private var _type:Array;

		public function PropertiesDialogue( fullSize:Boolean=true ) {
			const WIDTH:int = 300;
			const HEIGHT:int = 400;

			super(WIDTH, HEIGHT, "Properties", true, false, true, true);

			//Properties
			_properties = new List();
			_properties.doubleClickEnabled = true;
			_properties.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, onEditProperties);
			container.addChild(_properties);

			_add = new Button();
			_add.label = "Add Property";
//			_addProperty.addEventListener(MouseEvent.CLICK, onAddPropety);
			container.addChild(_add);

			_del = new Button();
			_del.label = "Delete";
//			_delProperty.addEventListener(MouseEvent.CLICK, onDelProperty);
			container.addChild(_del);

			init( WIDTH, HEIGHT );

			this.x = 820;
			this.y = 10;

			if( !fullSize ) {
				minimize();
			}

			DataModel.onSelectedChanged.add( onSetItems );
			DataModel.onItemChanged.add( onSetItems );
		}

		override protected function onResize( width:int, height:int ):void {
			_add.y = _del.y = height - _add.height;
			_add.width = int(width*0.75);
			_del.width = int(width*0.25);
			_del.x = _add.width;

			_properties.width = width;
			_properties.height = _add.y - 10;
		}

		private function onSetItems( itm:ItemModel=null ):void {
			_properties.removeAll();

			if( DataModel.SELECTED.length == 0 ) {
				return;
			}

			if( DataModel.SELECTED.length == 1 ) {
				const holder:ItemModel = DataModel.SELECTED[0];
				const item:CDItem = holder.item;

				const bounds:Rectangle = ( Drawer.isLoaded && item.asset != null ) ? Drawer.getBounds(item.asset) : new Rectangle();

				_properties.addItem({data:[false, "name"], 	label:"name: " + item.name});
				_properties.addItem({data:[false, "x"], 	label:"x: " + item.x.toString()});
				_properties.addItem({data:[false, "y"], 	label:"y: " + item.y.toString()});
				_properties.addItem({data:[false, "w"], 	label:"width: " + item.width.toString()});
				_properties.addItem({data:[false, "h"], 	label:"height: " + item.height.toString()});
//				_properties.addItem({data:[false, "r"], label:"rotation: " + sprite.rotation.toString()});
//				_properties.addItem({data:[false, "visible"], label:"visible: " + ((sprite.visible) ? "true" : "false")});
//				_properties.addItem({data:[false, "enabled"], label:"enabled: " + ((sprite.enabled) ? "true" : "false")});
				_properties.addItem({data:[false, "ow"], 	label:"original width: " + bounds.width.toString()});
				_properties.addItem({data:[false, "oh"], 	label:"original height: " + bounds.height.toString()});
				_properties.addItem({data:[false, "ar"], 	label:"aspect ratio: " + CDAspectRatio.toString( item.aspectRatio )});
				_properties.addItem({data:[false, "asset"],	label:"asset: " + item.asset});

//				_properties.addItem({data:[false, "null"], label:"::-- Object Properties --::"});
//				for( var key:String in model.parameters ) {
//					_properties.addItem({	data: [true, key],
//											label:key + ": " + model.parameters[key] });
//				}
			} else {
				_properties.addItem({data:[false, "x"], label:"x: (-)"});
				_properties.addItem({data:[false, "y"], label:"y: (-)"});
				_properties.addItem({data:[false, "w"], label:"width: (-)"});
				_properties.addItem({data:[false, "h"], label:"height: (-)"});
//				_properties.addItem({data:[false, "r"], label:"rotation: (-)"});
//				_properties.addItem({data:[false, "visible"], label:"visible: (-)"});
//				_properties.addItem({data:[false, "enabled"], label:"enabled: (-)"});
				_properties.addItem({data:[false, "ar"], label:"aspect ratio: (-)"});
			}
		}

		private function onEditProperties(e:ListEvent):void {
			const index:int = e.index;

			var data:Array = _properties.getItemAt(index)["data"];

			_type = data;

			var input:InputDialogue;

			var holder:ItemModel = DataModel.SELECTED[0];
			var item:CDItem = holder.item;

			const multiple:Boolean = (DataModel.SELECTED.length > 1);

			const bounds:Rectangle = ( !multiple && Drawer.isLoaded && item.asset != null ) ? Drawer.getBounds(item.asset) : new Rectangle();

			if( data[0] == true ) {
//				input = new InputDialogue("Edit parameter", "Enter parameter value:", item.parameters[ data[1] as String ]);
			} else {
				switch( data[1] ) {
					case "name":
						input = new InputDialogue("Edit parameters", "Enter name:", item.name);
					break;

					case "x":
						input = new InputDialogue("Edit parameters", "Enter x:", (multiple) ? null : item.x.toString());
					break;

					case "y":
						input = new InputDialogue("Edit parameters", "Enter y:", (multiple) ? null : item.y.toString());
					break;

					case "w":
						input = new InputDialogue("Edit parameters", "Enter width:", (multiple) ? null : item.width.toString());
					break;

					case "h":
						input = new InputDialogue("Edit parameters", "Enter height:", (multiple) ? null : item.height.toString());
					break;

//					case "r":
//						input = new InputDialogue("Edit parameters", "Enter rotation:", item.display.rotation.toString());
//					break;

					case "ow":
						item.width = bounds.width;
						DataModel.onItemChanged.dispatch( holder );
					break;

					case "oh":
						item.height = bounds.height;
						DataModel.onItemChanged.dispatch( holder );
					break;

//					case "visible":
//						item.display.visible = (item.display.visible) ? false : true;
//						onRefreshProperties();
//						DataModel.onItemStateChanged.dispatch();
//					break;

//					case "enabled":
//						item.display.enabled = (item.display.enabled) ? false : true;
//						onRefreshProperties();
//						DataModel.onItemStateChanged.dispatch();
//					break;

//todo
//					case "ar":
//						var alignDlg:AspectRatioDialogue = new AspectRatioDialogue();
//						alignDlg.addEventListener(AspectRatioDialogue.EVENT_OK, onAlignSelected);
//					break;

					default : break;
				}
			}

			if( input ) {
				input.onOK.addOnce( onEditedProperty );
			}
		}

		private function onEditedProperty( input:InputDialogue ):void {
			if( input.text == null || input.text == "" )
				return;

			var item:ItemModel;

			if( _type[0] == true ) {
//				item.parameters[data[1] as String] = input.text;
//				onRefreshProperties();
			} else {
				switch( _type[1] ) {
					case "name":
						if( checkName(input.text, DataModel.SELECTED[0].item) ) {
							item.item.name = input.text;
						} else {
							new PopupDialogue("ERROR", "ERROR: Name is already in use.");
						}
					break;

					case "x":
						if( !isNaN(Number(input.text)) ) {
							for each( item in DataModel.SELECTED ) {
								item.item.x = Number(input.text);
								DataModel.onItemChanged.dispatch( item );
							}
						}
					break;

					case "y":
						if( !isNaN(Number(input.text)) ) {
							for each( item in DataModel.SELECTED ) {
								item.item.y = Number(input.text);
								DataModel.onItemChanged.dispatch( item );
							}
						}
					break;

					case "w":
						if( !isNaN(Number(input.text)) ) {
							for each( item in DataModel.SELECTED ) {
								item.item.width = Number(input.text);
								DataModel.onItemChanged.dispatch( item );
							}
						}
					break;

					case "h":
						if( !isNaN(Number(input.text)) ) {
							for each( item in DataModel.SELECTED ) {
								item.item.height = Number(input.text);
								DataModel.onItemChanged.dispatch( item );
							}
						}
					break;

//					case "r":
//						if( !isNaN(Number(input.text)) ) item.display.rotation = Number(input.text);
//					break;

					default : break;
				}
			}
		}

		private function checkName( name:String, item:CDItem ):Boolean {
			const view:CDItem = DataModel.currentLayer;

			const len:int = view.children.length;
			for( var i:int = 0; i < len; i++ ) {
				if( view.children[i] != item && view.children[i].name == name ) {
					return false;
				}
			}

			return true;
		}
	}
}
