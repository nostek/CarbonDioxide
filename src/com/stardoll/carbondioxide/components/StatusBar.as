package com.stardoll.carbondioxide.components {
	import fl.controls.Button;
	import fl.controls.ComboBox;

	import com.stardoll.carbondioxide.dialogues.InputDialogue;
	import com.stardoll.carbondioxide.dialogues.ManageViewsDialogue;
	import com.stardoll.carbondioxide.managers.SettingsManager;
	import com.stardoll.carbondioxide.managers.ViewsManager;
	import com.stardoll.carbondioxide.models.DataModel;
	import com.stardoll.carbondioxide.models.cd.CDItem;
	import com.stardoll.carbondioxide.models.cd.CDView;
	import com.stardoll.carbondioxide.models.resolutions.ResolutionsModel;
	import com.stardoll.carbondioxide.utils.ObjectEx;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author simonrodriguez
	 */
	public class StatusBar extends Sprite {
		private static const HEIGHT:int = 40;

		private var _bg:Bitmap;

		private var _pathContainer:Sprite;

		private var _resolutions:ComboBox;

		private var _viewBox:ComboBox;
		private var _addView:Button;
		private var _manageViews:Button;

		public function StatusBar( stage:Stage ) {
			_bg = new Bitmap( DataModel.BG.bitmapData );
			addChild(_bg);

			_pathContainer = new Sprite();
			_pathContainer.x = 10;
			addChild(_pathContainer);

			_resolutions = new ComboBox();
			_resolutions.addEventListener(Event.CHANGE, onResolutionChange);
			_resolutions.width = 400;
			initResolutions();
			addChild(_resolutions);

			_viewBox = new ComboBox();
			_viewBox.width = 150;
			_viewBox.addEventListener(Event.CHANGE, onViewSelectChanged);
			addChild(_viewBox);

			_addView = new Button();
			_addView.label = "Add View";
			_addView.addEventListener(MouseEvent.CLICK, onAddView);
			addChild(_addView);

			_manageViews = new Button();
			_manageViews.label = "Manage Views";
			_manageViews.addEventListener(MouseEvent.CLICK, onManageViews);
			addChild(_manageViews);

			addEventListener(Event.ADDED_TO_STAGE, onResize );
			stage.addEventListener(Event.RESIZE, onResize );

			DataModel.onViewChanged.add( onViewChanged );
			DataModel.onLayerChanged.add( onLayerChanged );
			DataModel.onChangeResolution.add( onChangeResolution );
			ViewsManager.onViewsChanged.add( onViewsChanged );

			onResolutionChange(null);
		}

		private function onResize( e:Event ):void {
			this.y = stage.stageHeight - HEIGHT;
			this.x = 0;

			_bg.scrollRect = new Rectangle(0, 0, stage.stageWidth, HEIGHT);

			_bg.width = Math.max( stage.stageWidth, _bg.bitmapData.width );

			with( this.graphics ) {
				clear();

				beginFill(0x999999, 1);
				drawRect(0, 0, stage.stageWidth, HEIGHT);
				endFill();

				lineStyle(1, 0x000000, 1 );
				drawRect(0, 0, stage.stageWidth, HEIGHT);
			}

			_manageViews.x = stage.stageWidth - (_addView.width + 10);
			_manageViews.y = (HEIGHT/2) - (_manageViews.height/2);

			_addView.x = _manageViews.x - _addView.width;
			_addView.y = _manageViews.y;

			_viewBox.x = _addView.x - _viewBox.width;
			_viewBox.y = (HEIGHT/2) - (_viewBox.height/2);

			_resolutions.y = _viewBox.y;
			_resolutions.x = _viewBox.x - 20 - _resolutions.width;
		}

		private function initResolutions():void {
			var reses:Array = ResolutionsModel.resolutions;

			for each( var o:Object in reses ) {
				_resolutions.addItem({label:String(o["label"])});
			}
		}

		private function onViewChanged():void {
			var name:String = DataModel.currentView.name;

			if( _viewBox.text != name ) {
				for( var i:int = 0; i < _viewBox.length; i++ ) {
					if( _viewBox.getItemAt(i)["label"] == name ) {
						_viewBox.selectedIndex = i;
						return;
					}
				}
			}
		}

		private function onChangeResolution( name:String ):void {
			const len:int = _resolutions.length;

			for( var i:int = 0; i < len; i++ ) {
				var o:Object = _resolutions.getItemAt(i);

				if( o["label"] == name ) {
					_resolutions.selectedIndex = i;

					var reses:Array = ResolutionsModel.resolutions;
					var data:Object = reses[ i ];

					const width:int = data["width"];
					const height:int = data["height"];
					const dpi:int = data["dpi"];

					DataModel.setResolution(width, height, dpi);

					return;
				}
			}
		}

		private function onResolutionChange(e:Event):void {
			var reses:Array = ResolutionsModel.resolutions;

			var index:int = (_resolutions.selectedIndex>=0) ? _resolutions.selectedIndex : 0;

			if( e == null ) {
				index = ObjectEx.select(SettingsManager.getItem(SettingsManager.SETTINGS_RESOLUTION), "i", index);
				_resolutions.selectedIndex = index;
			} else {
				SettingsManager.setItem(SettingsManager.SETTINGS_RESOLUTION, {i: index});
			}

			var data:Object = reses[ index ];

			const width:int = data["width"];
			const height:int = data["height"];
			const dpi:int = data["dpi"];

			DataModel.setResolution(width, height, dpi);
		}

		private function onViewsChanged():void {
			_viewBox.removeAll();

			for each( var view:CDView in ViewsManager.views ) {
				_viewBox.addItem({label:view.name});
			}
		}

		private function onViewSelectChanged(e:Event):void {
			DataModel.setView( ViewsManager.views[ _viewBox.selectedIndex ] );
		}

		private function onLayerChanged():void {
			_pathContainer.removeChildren();

			var res:Vector.<CDItem> = new Vector.<CDItem>();

			var current:CDItem = DataModel.currentLayer;
			while( current != null && current.name != null ) {
				res.push( current );
				current = current.parent;
			}

			var txt:String = "";

			for( var i:int = 0; i < res.length; i++ ) {
				txt += "/" + res[(res.length-1)-i].name;
			}

			var fmt:TextFormat = new TextFormat("Verdana", 10, 0xffffffff, null, true);

			var t:TextField = new TextField();
			t.autoSize = TextFieldAutoSize.LEFT;
			t.wordWrap = t.multiline = t.selectable = false;
			t.defaultTextFormat = fmt;
			t.text = txt;
			_pathContainer.addChild(t);

			_pathContainer.y = (HEIGHT/2) - (_pathContainer.height/2);
		}

		private function onManageViews(e:MouseEvent):void {
			new ManageViewsDialogue();
		}

		private function onAddView(e:MouseEvent):void {
			var dlg:InputDialogue = new InputDialogue("Rename Flow", "Enter name:");
			dlg.onOK.addOnce( onAddFlow );
		}

		private function onAddFlow( dlg:InputDialogue ):void {
			const text:String = dlg.text;

			if( text == null || text == "" ) return;

			var view:CDView = ViewsManager.addView( new CDView(text) );

			DataModel.setView( view );

			onViewsChanged();

			_viewBox.selectedIndex = _viewBox.length-1;
		}
	}
}
