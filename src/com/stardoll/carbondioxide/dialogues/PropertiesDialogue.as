package com.stardoll.carbondioxide.dialogues {
	import fl.controls.List;
	import fl.events.ListEvent;

	import com.stardoll.carbondioxide.managers.SettingsManager;
	import com.stardoll.carbondioxide.models.DataModel;
	import com.stardoll.carbondioxide.models.ItemModel;
	import com.stardoll.carbondioxide.models.cd.CDAspectRatio;
	import com.stardoll.carbondioxide.models.cd.CDItem;
	import com.stardoll.carbondioxide.models.cd.CDText;
	import com.stardoll.carbondioxide.utils.Drawer;
	import com.stardoll.carbondioxide.utils.Images;

	import flash.geom.Rectangle;

	/**
	 * @author simonrodriguez
	 */
	public class PropertiesDialogue extends BaseDialogue {
		private var _properties:List;

		private var _type:Array;

		public function PropertiesDialogue( fullSize:Boolean=true ) {
			const WIDTH:int = 300;
			const HEIGHT:int = 400;

			super("Properties", true, false, true, true);

			//Properties
			_properties = new List();
			_properties.doubleClickEnabled = true;
			_properties.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, onEditProperties);
			container.addChild(_properties);

			init( WIDTH, HEIGHT, 820, 10, !fullSize );

			DataModel.onSelectedChanged.add( onSetItems );
			DataModel.onItemChanged.add( onSetItems );
		}

		override protected function get dialogueID():String { return SettingsManager.SETTINGS_PROPERTIES; }

		override protected function onResize( width:int, height:int ):void {
			_properties.width = width;
			_properties.height = height;
		}

		private function onSetItems( itm:CDItem=null ):void {
			itm;

			_properties.removeAll();

			if( DataModel.SELECTED.length == 0 ) {
				return;
			}

			if( DataModel.SELECTED.length == 1 ) {
				const holder:ItemModel = DataModel.SELECTED[0];
				const item:CDItem = holder.item;

				var bounds:Rectangle = ( Drawer.isLoaded && item.asset != null ) ? (Drawer.haveFrame(item.asset) ? Drawer.getBounds(item.asset) : new Rectangle()) : new Rectangle();
				if( item.asset != null && Images.haveImage(item.asset) ) {
					bounds.width = Images.getImage(item.asset).width;
					bounds.height = Images.getImage(item.asset).height;
				}

				_properties.addItem({data:[false, "name"], 	label:"name: " + item.name});
				_properties.addItem({data:[false, "path"], 	label:"path: " + item.path});
				_properties.addItem({data:[false, "note"], 	label:"note: " + item.note});
				_properties.addItem({data:[false, "x"], 	label:"x: " + item.xAsInt.toString()});
				_properties.addItem({data:[false, "y"], 	label:"y: " + item.yAsInt.toString()});
				_properties.addItem({data:[false, "w"], 	label:"width: " + item.widthAsInt.toString()});
				_properties.addItem({data:[false, "h"], 	label:"height: " + item.heightAsInt.toString()});
//				_properties.addItem({data:[false, "r"], label:"rotation: " + sprite.rotation.toString()});
				_properties.addItem({data:[false, "visible"], label:"visible: " + ((item.visible) ? "true" : "false")});
				_properties.addItem({data:[false, "enabled"], label:"enabled: " + ((item.enabled) ? "true" : "false")});
				_properties.addItem({data:[false, "ow"], 	label:"original width: " + bounds.width.toString()});
				_properties.addItem({data:[false, "oh"], 	label:"original height: " + bounds.height.toString()});
				_properties.addItem({data:[false, "ar"], 	label:"aspect ratio: " + CDAspectRatio.toString( item.aspectRatio )});
				_properties.addItem({data:[false, "asset"],	label:"asset: " + item.asset});
				_properties.addItem({data:[false, "color"],	label:"color: " + item.color.toString()});

				if( item is CDText ) {
					_properties.addItem({data:[false, "text"],	label:"text: " + (item as CDText).text});
					_properties.addItem({data:[false, "texta"],	label:"text align: " + CDText.getAlignAsString((item as CDText).align)});
				}
			} else {
				_properties.addItem({data:[false, "x"], label:"x: (-)"});
				_properties.addItem({data:[false, "y"], label:"y: (-)"});
				_properties.addItem({data:[false, "w"], label:"width: (-)"});
				_properties.addItem({data:[false, "h"], label:"height: (-)"});
//				_properties.addItem({data:[false, "r"], label:"rotation: (-)"});
				_properties.addItem({data:[false, "visible"], label:"visible: (-)"});
				_properties.addItem({data:[false, "enabled"], label:"enabled: (-)"});
				_properties.addItem({data:[false, "ar"], label:"aspect ratio: (-)"});
				_properties.addItem({data:[false, "color"],	label:"color: (-)"});
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

			var bounds:Rectangle = ( Drawer.isLoaded && item.asset != null ) ? (Drawer.haveFrame(item.asset) ? Drawer.getBounds(item.asset) : new Rectangle()) : new Rectangle();
			if( item.asset != null && Images.haveImage(item.asset) ) {
				bounds.width = Images.getImage(item.asset).width;
				bounds.height = Images.getImage(item.asset).height;
			}

			if( data[0] == true ) {
			} else {
				switch( data[1] ) {
					case "name":
						input = new InputDialogue("Edit parameters", "Enter name:", item.name);
					break;

					case "path":
						input = new InputDialogue("Path", "Items path:", item.path);
					break;

					case "note":
						input = new InputDialogue("Note", "Items note:", item.note);
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
						item.width = Math.round(bounds.width);
					break;

					case "oh":
						item.height = Math.round(bounds.height);
					break;

					case "text":
						input = new InputDialogue("Edit parameters", "Text:", (item as CDText).text);
					break;

					case "texta":
						var textAlignDlg:TextAlignDialogue = new TextAlignDialogue();
						textAlignDlg.onSelect.addOnce( onTextAlignSelected );
					break;

					case "visible":
						for each( holder in DataModel.SELECTED ) {
							holder.item.visible = !holder.item.visible;
						}
					break;

					case "enabled":
						for each( holder in DataModel.SELECTED ) {
							holder.item.enabled = !holder.item.enabled;
						}
					break;

					case "ar":
						var alignDlg:AspectRatioDialogue = new AspectRatioDialogue();
						alignDlg.onSelect.addOnce( onAlignSelected );
					break;

					case "color":
						var colorDlg:ColorDialogue = new ColorDialogue();
						colorDlg.onSelect.addOnce( onColorSelected );
					break;

					case "asset":
						item.asset = null;
					break;

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
			} else {
				switch( _type[1] ) {
					case "name":
						item = DataModel.SELECTED[0];
						if( checkName(input.text, item.item) ) {
							item.item.name = input.text;
						} else {
							new PopupDialogue("ERROR", "ERROR: Name is already in use.");
						}
					break;

					case "x":
						if( !isNaN(Number(input.text)) ) {
							for each( item in DataModel.SELECTED ) {
								item.item.x = Number(input.text);
							}
						}
					break;

					case "y":
						if( !isNaN(Number(input.text)) ) {
							for each( item in DataModel.SELECTED ) {
								item.item.y = Number(input.text);
							}
						}
					break;

					case "w":
						if( !isNaN(Number(input.text)) ) {
							for each( item in DataModel.SELECTED ) {
								item.item.width = Number(input.text);
							}
						}
					break;

					case "h":
						if( !isNaN(Number(input.text)) ) {
							for each( item in DataModel.SELECTED ) {
								item.item.height = Number(input.text);
							}
						}
					break;

					case "text":
						item = DataModel.SELECTED[0];
						(item.item as CDText).text = input.text;
					break;

					case "note":
						item = DataModel.SELECTED[0];
						item.item.note = input.text;
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

		private function onAlignSelected( ar:int ):void {
			var item:ItemModel;

			for each( item in DataModel.SELECTED ) {
				item.item.aspectRatio = ar;
			}
		}

		private function onTextAlignSelected( a:int ):void {
			var item:ItemModel;

			for each( item in DataModel.SELECTED ) {
				(item.item as CDText).align = a;
			}
		}

		private function onColorSelected( color:uint ):void {
			var item:ItemModel;

			for each( item in DataModel.SELECTED ) {
				item.item.color = color;
			}
		}
	}
}
