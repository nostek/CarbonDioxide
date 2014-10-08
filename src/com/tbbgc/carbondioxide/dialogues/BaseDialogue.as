package com.tbbgc.carbondioxide.dialogues {
	import com.tbbgc.carbondioxide.managers.SettingsManager;
	import com.tbbgc.carbondioxide.utils.ObjectEx;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author simonrodriguez
	 */
	public class BaseDialogue extends Sprite {
		public static var DIALOGUES:Sprite;

		public static var BLOCK_MENU_COUNT:int=0;

		public static function get BLOCK_MENU():Boolean { return BLOCK_MENU_COUNT > 0; }

		public static const HEADER:int 	= 20;
		public static const EDGE:int 	= 10;

		private var _realWidth:int;
		private var _realHeight:int;

		private var _noclick:Sprite;
		private var _topic:TextField;

		private var _container:Sprite;

		private var _canClose:Boolean;

		private var _canScale:Boolean;
		private var _doScale:Boolean;
		private var _sx:Number;
		private var _sy:Number;
		private var _bw:Number;
		private var _bh:Number;

		public function BaseDialogue( caption:String, canMinimize:Boolean, disableStage:Boolean, canScale:Boolean, canClose:Boolean ) {
			super();

			var stage:Stage = BaseDialogue.DIALOGUES.stage;

			if( disableStage ) {
				_noclick = new Sprite();
				with( _noclick.graphics ) {
					beginFill( 0xffffff, 0.8 );
					drawRect(0, 0, stage.stageWidth, stage.stageHeight);
					endFill();
				}
				BaseDialogue.DIALOGUES.addChild(_noclick);

				BLOCK_MENU_COUNT++;
			}

			_canScale = canScale;
			_canClose = canClose;

			_realWidth = _realHeight = 200;

			var fmt:TextFormat = new TextFormat("Verdana", 10, 0xffffffff, null, true);

			_topic = new TextField();
			_topic.mouseEnabled = false;
			_topic.autoSize = TextFieldAutoSize.LEFT;
			_topic.selectable = false;
			_topic.defaultTextFormat = fmt;
			_topic.text = caption;
			addChild(_topic);

			_container = new Sprite();
			addChild( _container );

			BaseDialogue.DIALOGUES.addChild(this);

			if( canMinimize ) this.doubleClickEnabled = true;

			this.addEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
			this.addEventListener(MouseEvent.MOUSE_UP, onStopDrag);
			this.addEventListener(MouseEvent.DOUBLE_CLICK, onDblClick);
			if( canClose ) this.addEventListener(MouseEvent.CLICK, onClick);
		}

		protected function init( width:int, height:int, x:int=-1000, y:int=-1000, doMinimize:Boolean=false ):void {
			if( x == -1000 ) x = stage.stageWidth/2 - width/2;
			if( y == -1000 ) y = stage.stageHeight/2 - height/2;

			const id:String = dialogueID;
			if( id != null ) {
				var data:Object = SettingsManager.getItem( id );
				x = ObjectEx.select(data, "x", x);
				y = ObjectEx.select(data, "y", y);
				width = ObjectEx.select(data, "w", width);
				height = Math.max( 50, ObjectEx.select(data, "h", height) );
				doMinimize = ObjectEx.select(data, "m", doMinimize) as Boolean;
			}

			doResize( width, height );

			this.x = x;
			this.y = y;

			if( doMinimize ) {
				minimize();
			}
		}

		private function saveDialogue():void {
			const id:String = dialogueID;

			if( id != null ) {
				SettingsManager.setItem( id, {
					"x": this.x,
					"y": this.y,
					"w": _realWidth,
					"h": _realHeight,

					"m": this.isMinimized
				} );
			}
		}

		protected function close():void {
			if( _noclick != null ) {
				_noclick.parent.removeChild(_noclick);
				BLOCK_MENU_COUNT--;
				if( BLOCK_MENU_COUNT == 0 ) {
					stage.focus = null;
				}
			}

			this.parent.removeChild(this);
		}

		protected function get container():Sprite { return _container; }

		protected function get isMinimized():Boolean { return (this.scrollRect!=null); }

		protected function get dialogueID():String { return null; }

		protected function onResize( width:int, height:int ):void {
		}

		private function doResize( width:int, height:int ):void {
			_realWidth = width;
			_realHeight = height;

			with( this.graphics ) {
				clear();

				lineStyle(1,0xffffff,0.5,true,"normal",null,null,15);

				beginFill(0x000000);
					drawRoundRect(0, 0, width, height, 16);
				endFill();

				beginFill(0x000000);
					drawRoundRect(0, 0, width, HEADER, 16);

					if( _canScale ) {
						drawRoundRect(0, height-EDGE, width, EDGE, 16);
					}
				endFill();

				if( _canClose ) {
					lineStyle(1,0xff0000,0.5,true,"normal",null,null,15);
					beginFill(0xff0000, 0.3);
					drawRoundRect((width-HEADER)+1, 1, HEADER-2, HEADER-2, 16);
					endFill();
				}
			}

			_topic.y = 2;
			_topic.x = width/2 - _topic.width/2;

			const w:int = width-EDGE-EDGE;
			const h:int = (height-HEADER) - (_canScale?EDGE:0) - EDGE - EDGE;

			_container.x = EDGE;
			_container.y = HEADER+EDGE;
			_container.scrollRect = new Rectangle(0, 0, w, h);

			onResize(w, h);
		}

		private function onStartDrag(e:MouseEvent):void {
			if( e.target == this ) {
				if( _canScale && this.scrollRect == null && e.localY > this.height-EDGE ) {
					_sx = e.stageX;
					_sy = e.stageY;
					_bw = this.width;
					_bh = this.height;
					_doScale = true;

					stage.addEventListener(MouseEvent.MOUSE_UP, onStopScale);
					stage.addEventListener(MouseEvent.MOUSE_MOVE, onDoScale);
				} else {
					this.startDrag();

					this.parent.setChildIndex(this, this.parent.numChildren-1);
				}
			}
		}

		private function onStopDrag(e:MouseEvent):void {
			if( !_doScale ) {
				this.stopDrag();

				saveDialogue();
			}
		}

		private function onDoScale(e:MouseEvent):void {
			if( _doScale ) {
				doResize(_bw + (e.stageX - _sx), _bh + (e.stageY - _sy));
			}
		}

		private function onStopScale(e:MouseEvent):void {
			if( _doScale ) {
				_doScale = false;

				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDoScale);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onStopScale);

				saveDialogue();
			}
		}

		private function onDblClick(e:MouseEvent):void {
			if( e.target == this && e.localY < HEADER ) {
				if( this.scrollRect == null ) {
					minimize();
				} else {
					maximize();
				}
			}
		}

		private function onClick(e:MouseEvent):void {
			if( e.target == this && e.localX > this.width - HEADER && e.localY < HEADER ) {
				close();
			}
		}

		public function minimize():void {
			this.scrollRect = new Rectangle(0, 0, this.width, HEADER);

			saveDialogue();
		}

		public function maximize():void {
			this.scrollRect = null;

			saveDialogue();
		}
	}
}
