package com.stardoll.carbondioxide.dialogues {
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

		public static const HEADER:int 	= 20;
		public static const EDGE:int 	= 10;

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

		public function BaseDialogue( width:int, height:int, caption:String, canMinimize:Boolean, disableStage:Boolean, canScale:Boolean, canClose:Boolean ) {
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
			}

			_canScale = canScale;
			_canClose = canClose;

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

		protected function init( width:int, height:int ):void {
			doResize( width, height );

			this.x = stage.stageWidth/2 - width/2;
			this.y = stage.stageHeight/2 - height/2;
		}

		protected function close():void {
			if( _noclick != null ) {
				_noclick.parent.removeChild(_noclick);
			}

			this.parent.removeChild(this);
		}

		protected function get container():Sprite { return _container; }

		protected function onResize( width:int, height:int ):void {
		}

		private function doResize( width:int, height:int ):void {
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
		}

		public function maximize():void {
			this.scrollRect = null;
		}
	}
}
