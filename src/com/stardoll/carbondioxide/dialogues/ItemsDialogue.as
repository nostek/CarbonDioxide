package com.stardoll.carbondioxide.dialogues {
	import com.stardoll.carbondioxide.components.TreeDisplay;
	import fl.controls.Button;
	import fl.controls.List;
	import fl.events.ListEvent;

	import com.stardoll.carbondioxide.models.DataModel;
	import com.stardoll.carbondioxide.models.ItemModel;
	import com.stardoll.carbondioxide.models.cd.CDItem;
	import com.stardoll.carbondioxide.models.cd.CDResolution;
	import com.stardoll.carbondioxide.models.resolutions.ResolutionsModel;

	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * @author simonrodriguez
	 */
	public class ItemsDialogue extends BaseDialogue {
		private var _lastData:Array;
		private var _data:Array;

		private var _list:List;

		private var _addItem:Button;
		private var _delItem:Button;

		private var _upItem:Button;
		private var _downItem:Button;

		private var _expand:Button;
		private var _collapse:Button;

		private var _ignore:Boolean;

		public function ItemsDialogue( fullSize:Boolean=true ) {
			const WIDTH:int = 300;
			const HEIGHT:int = 450;

			super(WIDTH, HEIGHT, "Items", true, false, true, true);

			_ignore = false;

			_list = new List();
			_list.allowMultipleSelection = true;
			_list.addEventListener(Event.CHANGE, onSelectItem);
			_list.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, onOpenCloseNode);
			container.addChild( _list );

			_addItem = new Button();
			_addItem.label = "Add Item";
			_addItem.addEventListener(MouseEvent.CLICK, onAddItemButton);
			container.addChild(_addItem);

			_delItem = new Button();
			_delItem.label = "Delete";
			_delItem.addEventListener(MouseEvent.CLICK, onDelItemButton);
			container.addChild(_delItem);

			_upItem = new Button();
			_upItem.label = "Up";
			_upItem.addEventListener(MouseEvent.CLICK, onUpItemButton);
			container.addChild(_upItem);

			_downItem = new Button();
			_downItem.label = "Down";
			_downItem.addEventListener(MouseEvent.CLICK, onDownItemButton);
			container.addChild(_downItem);

			_expand = new Button();
			_expand.label = "Expand All";
			_expand.addEventListener(MouseEvent.CLICK, onExpandButton);
			container.addChild(_expand);

			_collapse = new Button();
			_collapse.label = "Collapse All";
			_collapse.addEventListener(MouseEvent.CLICK, onCollapseButton);
			container.addChild(_collapse);

			DataModel.onLayerChanged.add( onSetItems );
			DataModel.onSelectedChanged.add( onSelectItems );

			init(WIDTH, HEIGHT);

			this.x = 220;
			this.y = 10;

			if( !fullSize ) {
				minimize();
			}
		}

		override protected function onResize( width:int, height:int ):void {
			const div:int = width/4;
			_upItem.width = _downItem.width = _expand.width = _collapse.width = div;
			_downItem.x = div;
			_expand.x = div+div;
			_collapse.x = div+div+div;

			_addItem.width = _delItem.width = width/2;
			_delItem.x = width/2;
			_addItem.y = _delItem.y = height-_addItem.height;

			_list.y = _upItem.height+10;
			_list.width = width;
			_list.height = (_addItem.y - 10) - _list.y;
		}

		private function onSetItems():void {
			buildLast();

			buildData( DataModel.currentLayer.children );

			buildList( _data );
		}

		private function buildLast():void {
			_lastData = [];

			var item:Object, node:Object;

			const len:int = _list.dataProvider.length;
			for( var i:int = 0; i < len; i++ ) {
				item = _list.getItemAt(i);

				node = item["parentnode"];

				if( node != null && node["expanded"] == true ) {
					_lastData[ node["label"] ] = true;
				}
			}
		}

		private function buildData( list:Vector.<CDItem> ):void {
			var data:Array = [];

			var node:Object;

			var name:String;

			var r:Object;

			var resolutions:Array = ResolutionsModel.resolutions;

			var getRes:Function = function( w:int, h:int ):Object {
				for each( var o:Object in resolutions ) {
					if( o["width"] == w && o["height"] == h ) {
						return o;
					}
				}
				return {label: "unidentified"};
			};

			for each( var item:CDItem in list ) {
				name = item.name + " ";

//				if( item.display.visible ) {
//					name += "[V]";
//				}
//				if( item.display.enabled ) {
//					name += "[E]";
//				}

				node = { label:name, object: item, children:[] };

				for each( var screen:CDResolution in item.resolutions ) {
					r = getRes( screen.screenWidth, screen.screenHeight );
					(node["children"] as Array).push( 	{
															label:"Resolution: " + r["label"] + " (" + screen.screenWidth.toString() + "x" + screen.screenHeight.toString() + ")",
															screen:screen,
															object: item
														} );
				}

				if( _lastData[name] != null ) {
					node["expanded"] = true;
				} else {
					node["expanded"] = false;
				}

				data.push( node );
			}

			_data = data;
		}

		private function buildList( data:Array ):void {
			_list.removeAll();

			for each( var node:Object in data ) {
				recursiveList(0, node);
			}

			onSelectItems();
		}

		private function recursiveList( tab:int, node:Object ):void {
			var tabspace:String = "";
			for( var i:int = 0; i < tab; i++ ) {
				tabspace += "    ";
			}

			if( node["children"] != null ) {
				if( node["expanded"] == null ) {
					tabspace += "[-] ";
				} else {
					tabspace += "[+] ";
				}
			}

			var data:Object = 	{
									label:tabspace + node.label,
									parentnode:(node["children"] != null) ? node : null
								} ;

			if( node["object"] != null ) {
				data["object"] = node["object"];
			}

			if( node["screen"] != null ) {
				data["screen"] = node["screen"];
			}

			_list.addItem( data );

			if( node["expanded"] == null && node["children"] != null ) {
				for each( var subnode:Object in node["children"] ) {
					recursiveList(tab+1, subnode);
				}
			}
		}

		private function onOpenCloseNode(e:ListEvent):void {
			var item:Object = _list.getItemAt(e.index);

			var node:Object = item["parentnode"];

			if( node != null ) {
				if( node["expanded"] != null ) {
					node["expanded"] = null;
				} else {
					node["expanded"] = true;
				}

				buildList(_data);
			}

			var screen:CDResolution = item["screen"];

			if( screen != null ) {
				var model:CDItem = item["object"];

				model.removeResolution( screen );

				DataModel.layerUpdated();
			}
		}

		private function onSelectItem(e:Event):void {
			var selected:Array = _list.selectedItems;

			if( selected.length > 0 ) {
				var selects:Array = [];

				var item:CDItem;

				for each( var obj:Object in selected ) {
					item = obj["object"];

					if( item != null ) {
						if( selects.indexOf( item ) == -1 ) {
							selects.push( item );
						}
					}
				}

				if( selects.length > 0 ) {
					_ignore = true;
					TreeDisplay.doSelectItems.dispatch( selects );
					_ignore = false;
				}

				_list.focusManager.setFocus(null);
			}
		}

		private function onAddItemButton(e:Event):void {
			if( DataModel.currentView == null ) {
				new PopupDialogue("ERROR", "Add a view first.");
			}

			var input:InputDialogue = new InputDialogue("Add Item", "Enter name:");
			input.onOK.addOnce( onAddItemNamed );
		}

		private function onAddItemNamed(input:InputDialogue):void {
			if( input.text == null || input.text == "" )
				return;

			if( checkName(input.text) ) {
				var item:CDItem = DataModel.currentLayer.addChild( new CDItem(DataModel.currentLayer, input.text) );
				item.x = 0;
				item.y = 0;
				item.width = 100;
				item.height = 100;

				DataModel.layerUpdated();
			} else {
				new PopupDialogue("ERROR", "ERROR: Name is already in use.");
			}
		}

		private function checkName( name:String ):Boolean {
			const layer:CDItem =  DataModel.currentLayer;

			const children:Vector.<CDItem> = layer.children;

			const len:int = children.length;

			for( var i:int = 0; i < len; i++ ) {
				if( children[i].name == name ) {
					return false;
				}
			}

			return true;
		}

		private function onDelItemButton(e:Event):void {
			for each( var item:ItemModel in DataModel.SELECTED ) {
				item.item.parent.removeChild( item.item );
			}

			DataModel.layerUpdated();
		}

		private function onSelectItems():void {
			if( _ignore )
				return;

			_list.clearSelection();

			var l:Array = [];

			var data:Object;

			const len:int = _list.length;

			for each( var item:ItemModel in DataModel.SELECTED ) {
				for( var i:int = 0; i < len; i++ ) {
					data = _list.getItemAt(i);
					if( data["object"] != null && data["object"] == item.item ) {
						l.push( i );
					}
				}
			}

			_list.selectedIndices = l;
		}

		private function onUpItemButton(e:Event):void {
			moveUpDown( true );
		}
		private function onDownItemButton(e:Event):void {
			moveUpDown( false );
		}
		private function moveUpDown( up:Boolean ):void {
//			var view:ViewModel = DataModel.currentView;
//			if( !view )
//				return;
//
//			var items:Array = DataModel.transform.selectedTargetObjects;
//
//			if( items != null && items.length != 0 ) {
//				DataModel.currentView.move( items, up );
//
//				onSetItems();
//
//				DataModel.transform.selectItems( items );
//
//				onSelect();
//			}
		}

		private function onExpandButton(e:Event):void {
			doExpandCollapse(true);
		}
		private function onCollapseButton(e:Event):void {
			doExpandCollapse(false);
		}
		private function doExpandCollapse( exp:Boolean ):void {
			var item:Object, node:Object;

			const len:int = _list.dataProvider.length;
			for( var i:int = 0; i < len; i++ ) {
				item = _list.getItemAt(i);

				node = item["parentnode"];

				if( node != null ) {
					if( exp ) {
						node["expanded"] = null;
					} else {
						node["expanded"] = true;
					}
				}
			}

			buildList(_data);
		}
	}
}
