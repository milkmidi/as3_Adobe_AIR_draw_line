package com.milkmidi.line{
	import adobe.utils.CustomActions;
	import anteater.utils.MovieClipUtil;
	import com.bit101.components.HBox;
	import com.bit101.components.PushButton;
	import com.bit101.components.VBox;
	import com.greensock.easing.Cubic;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author milkmidi
	 */
	[SWF(width = "1280", height = "670", frameRate = "41", backgroundColor = "#ecf0f1")]	
	public class Main extends Sprite {
		
		[Embed(systemFont="Futura2-Normal", fontName="Futura2", fontStyle="normal", fontWeight="normal", embedAsCFF="false", advancedAntiAliasing="true", unicodeRange="U+0020-U+007e", mimeType="application/x-font")]
		static public var ClassName : Class;

		public static const FLAT_COLOR:Array = [
			0xb3d01e, 0xf9644e, 0x117ab1, 0x9b6aea, 0xf0da6b, 0xf9c7d2, 0x0199a4,
			0xc2e2f7, 0xa69162, 
			0x1bc6b0, 0xed6464,0x3498db
		];
		public static var DPI_SCALE:Number;
		
		private static var DRAW_LINE_THINKNESS	:int;
		private static var RADIUS				:int;
		private var _container	:Sprite;
		private var _tmpLine	:Shape;
		private var _clickPoint	:Point = new Point;
		private var _lineMap	:Array;
		private var _lineBitmap	:Bitmap;
		private var _clickLine	:Line;
		private var _gap		:int;
		private var _moveMC		:MoveMC;
		private var _positionX	:Vector.<int> = new Vector.<int>();
		//private var _lineColor	:uint;
		
		//private var _resultTF	:TextField;
		private var _currentID	:int;		
		//private var vbox		:VBox;
		private var _flatBTNFocus		:FlatBTNFocus = new FlatBTNFocus;
		private var _moveMCArr			:Vector.<MoveMC> = new Vector.<MoveMC>(4);
		private var _flatBTNContainer	:Sprite;
		private var _startBTN			:FlatBTN;
		private var _startIndex			:int = 0;
		private var _resultEffectMC:swc_IntroBG_mc;
		public function Main():void {
			Font.registerFont(ClassName);
			
			DPI_SCALE = Math.max(1, Capabilities.screenDPI / 160);				
			DRAW_LINE_THINKNESS = DPI_SCALE * 10;
			RADIUS = DPI_SCALE * 50;
			trace( "DPI_SCALE : " + DPI_SCALE );
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			stage.align = "tl";
			stage.scaleMode = 'noScale';
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			
			this.addChild( this._container = new Sprite);
			this._container.addEventListener(MouseEvent.MOUSE_DOWN , onMouseDownHandler);			
			this._tmpLine = new Shape;
			this.addChild( _tmpLine );
			
			
			_lineBitmap = new Bitmap();
			_lineBitmap.bitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0);			
			addChild( _lineBitmap );
			// entry point
			createLine( 4 );
			
		
			stage.frameRate = 100;
		}
		
		private function createLine( pCount:int ):void {
			_gap = stage.stageWidth / (pCount + 1);			
			_lineMap = [];					
			
			//trace( stage.stageHeight );
			
			_flatBTNContainer = new Sprite;
			addChild( _flatBTNContainer );
			
			var margin:int = DPI_SCALE * 5;
			for (var i:int = 0; i < pCount; i++) {				
				var line:Line = new Line;
				line.x = _gap * (i + 1);				
				line.index = i;
				line.name = "line" + i;
				this._container.addChild( line );
				_positionX.push( line.x );				
				_lineMap[i] = [];
				
				var btn:FlatBTN = new FlatBTN( FLAT_COLOR[i] , RADIUS , onBTNClickHandler);
				btn.id = i;
				btn.x = RADIUS + margin;
				btn.y = (RADIUS * 2+margin) * i  + RADIUS + margin;
				_flatBTNContainer.addChild( btn );
				
				_flatBTNFocus.add( btn );
			}
			trace( "gap:" + _gap );
			
			
			
			_startBTN = new FlatBTN( FLAT_COLOR[i] , RADIUS , function ():void {
				if (_startIndex>=4) {
					return;
				}
				_flatBTNContainer.mouseEnabled = false;
				_flatBTNContainer.mouseChildren = false;
				_flatBTNContainer.alpha = 0.5;
				_startBTN.text = "Next";				
				_startBTN.enabled = false;			
				_startBTN.alpha = 0.4;
				startMove( _startIndex );
				_startIndex++;
			} );	
			_startBTN.x = RADIUS + margin;
			_startBTN.y = (RADIUS * 2 + margin) * i  + RADIUS + margin;
			_startBTN.text = "Start";
			_startBTN.scale = .8;
			addChild( _startBTN );
			
			_flatBTNFocus.focusIndex( 0 );
		}
		
		private function onBTNClickHandler(e:MouseEvent):void {
			_flatBTNFocus.focus( e.currentTarget as FlatBTN );
		}
		private static function getFlatColor():uint {
			var index:int = int( Math.random() * FLAT_COLOR.length + 0.5);
			return FLAT_COLOR[index];
		}
		
		private function startMove( pID:int ):void {
			_currentID = pID;
			trace("startMove:", pID );		
			if (_resultEffectMC) {
				_resultEffectMC.visible = false;				
			}
			stage.frameRate = 100;
			_moveMC = _moveMCArr[pID];
			this._container.removeEventListener(MouseEvent.MOUSE_DOWN , onMouseDownHandler);			
			
			
			
			if (_moveMC == null) {
				_moveMC = new MoveMC(  _flatBTNFocus.getBTNByAt( pID ).color2 , RADIUS );
				_moveMC.x = _positionX[ pID ];		
				_moveMC.index = pID;
				_moveMC.id = pID;
				_moveMC.scale = 1.5;
				_moveMC.alpha = 0;
				_moveMC.y = 0;
				addChild( _moveMC );
			}
			_flatBTNFocus.focus( _flatBTNFocus.getBTNByAt(pID) );
			TweenMax.to( _moveMC , .8, {
				alpha		:1,
				scale		:.8,
				ease		:Cubic.easeInOut
			} );			

			for (var i:int = 0; i < 4; i++) {
				var arr:Array = _lineMap[i];
				arr.sortOn("y", Array.NUMERIC);
			}		
			setTimeout( addEventListener , 1000 , Event.ENTER_FRAME, onEnterFrameHandler );			
		}
		
		private function onEnterFrameHandler(e:Event):void {
			var i:int = 6;
			while (i--) {
				
				if (_moveMC.lockMove) {
					return;
				}
				
				_moveMC.y++;
				
				
				var array:Array = _lineMap[ _moveMC.index ];
				if ( _moveMC.checkNextIndex != -1 && _moveMC.checkNextIndex <= array.length - 1  ) {			
					var obj:Object = _lineMap[ _moveMC.index ][ _moveMC.checkNextIndex ];
					var nextPotionY:int = obj.y;
					if (_moveMC.y >= nextPotionY) {
						_moveMC.lockMove = true;
						_moveMC.index = obj.target;
						_moveMC.checkNextIndex = getNextIndex(_moveMC.y , _moveMC.index );
						trace( _moveMC.index, _moveMC.checkNextIndex );				
						TweenMax.to( _moveMC , .5, {
							x			: _positionX[ obj.target ],
							onComplete	:function ():void {
								_moveMC.lockMove = false;
							}
						} );
					}
				}
				if (_moveMC.y > stage.stageHeight - 30) {					
					this.removeEventListener(Event.ENTER_FRAME , onEnterFrameHandler);					
					trace("stop", _moveMC.index);							
					_startBTN.enabled = true;
					_startBTN.alpha = 1;
					TweenMax.to( _startBTN , .5, {
						scale		:1.2,
						yoyo		:true,
						repeat		:1,
						ease		:Cubic.easeInOut
					} );
					trace( "第" + (_currentID + 1) + "的結果是" + (_moveMC.index + 1) + "\n");					
					TweenMax.to( _moveMC , .8, {
						scale		:1,
						ease		:Cubic.easeInOut,
						onComplete	:function ():void {
							stage.frameRate = 30;
							if (_resultEffectMC == null) {
								_resultEffectMC = stage.addChild( new swc_IntroBG_mc) as swc_IntroBG_mc;						
								_resultEffectMC.x = stage.stageWidth >> 1;
								_resultEffectMC.y = stage.stageHeight >> 1;							
							}
							_resultEffectMC.visible = true;
							_resultEffectMC.gotoAndPlay(1);
							_resultEffectMC.result_txt.text = (_moveMC.index + 1) +"";										
							_moveMC = null;
						}
					} );
					
					
					break;
				}	
			}
			
		}
		private function getNextIndex( pY:int , pIndex:int ):int {
			var arr:Array = _lineMap[pIndex];
			for (var i:int = 0 ; i < arr.length; i++ ) {				
				
				if (pY < arr[i].y) {
					return i;
				}
				
				
			}
			return -1;
		}
		
		private function onMouseDownHandler(e:MouseEvent):void {
			_clickLine = e.target as Line;
			_clickPoint.setTo( _clickLine.x , stage.mouseY );
			//_lineColor = getFlatColor();
			stage.addEventListener(MouseEvent.MOUSE_MOVE , onMouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP , onMouseUpHandler);
		}
		
		private function onMouseMoveHandler(e:Event , pLineToX:int = -1 , pLineToY:int = -1):void {			
			_tmpLine.graphics.clear();
			
			//_tmpLine.graphics.lineStyle( DRAW_LINE_THINKNESS*2, _flatBTNFocus.currentBTN.color2, 1, false, "normal", CapsStyle.SQUARE);			
			//_tmpLine.graphics.moveTo( _clickPoint.x , _clickPoint.y );		
			
			_tmpLine.graphics.lineStyle( DRAW_LINE_THINKNESS, _flatBTNFocus.currentBTN.color, 1, false, "normal", CapsStyle.SQUARE);			
			_tmpLine.graphics.moveTo( _clickPoint.x , _clickPoint.y );
				
			if (pLineToX == -1) {
				_tmpLine.graphics.lineTo( stage.mouseX , stage.mouseY );					
			}else {
				_tmpLine.graphics.lineTo( pLineToX, pLineToY );					
			}			
		}
		
		private function onMouseUpHandler(e:MouseEvent):void {
			//trace( e.target );
			stage.removeEventListener(MouseEvent.MOUSE_UP , onMouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE , onMouseMoveHandler);
			validateLine( e.target as Line );
			_tmpLine.graphics.clear();
		}
		
		private function validateLine( pUpLine:Line ):void {
			if (pUpLine == null || _clickLine == pUpLine) {
				return;
			}
			
			
			
			var indexDisc:int = pUpLine.index - _clickLine.index;
			//trace( indexDisc );
			if ( Math.abs( indexDisc ) == 1) {				
				onMouseMoveHandler( null , pUpLine.x , _clickPoint.y );
				_lineBitmap.bitmapData.draw( _tmpLine );
				_tmpLine.graphics.clear();
				
				
				var obj:Object = { 
					y		:_clickPoint.y ,
					//self	:_clickLine.index,
					target	:pUpLine.index
				};
				_lineMap[_clickLine.index].push(  obj );				
				
				obj = {
					y		:_clickPoint.y ,
					//self	:pUpLine.index,
					target	:_clickLine.index
				}
				_lineMap[pUpLine.index].push(  obj );				
				
				trace( _clickLine.index , pUpLine.index ,"Y:"+_clickPoint.y, "AddToArray" );
			}
			
			
		}
		
		
	}
	
}
import adobe.utils.CustomActions;
import anteater.utils.ColorUtil;
import com.greensock.easing.Cubic;
import com.greensock.TweenMax;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFormat;
import com.milkmidi.line.Main;
class Line extends Sprite {
	public static var THINCKNESS:int = 40;
	private var _shape:Shape;
	public var index:int;
	public function Line() {
		super();
		
		THINCKNESS = Main.DPI_SCALE * 40;
		this.buttonMode = true;
		this._shape = new Shape();
		this.addChild( _shape );
		this.addEventListener(Event.ADDED_TO_STAGE , onAddedToStageHandler);
		this.mouseChildren = false;
		this.cacheAsBitmap = true;
		
		try {
			this["cacheAsBitmapMatrix"] = new Matrix			
		}catch (err:Error){
		
		}
	}	
	private function onAddedToStageHandler(e:Event):void {
		
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStageHandler);
		
		var margin	:int = Main.DPI_SCALE * 20;
		var sh		:int = stage.stageHeight - margin;
		
		//trace( stage.stageHeight , stage.fullScreenHeight );
		_shape.graphics.beginFill( 0xa8a2a5 , 0 );
		_shape.graphics.drawRect( THINCKNESS * -1, margin, THINCKNESS * 2, sh );			
		//_shape.graphics.endFill();
		_shape.graphics.beginFill( 0x2bbcb5 , 1 );
		_shape.graphics.drawRect( THINCKNESS / -2, margin, THINCKNESS, sh);		
		_shape.graphics.endFill();
	}

}

class FlatBTNFocus {
	private var _currentBTN:FlatBTN;
	public function get currentBTN():FlatBTN {	return _currentBTN;	}
	private var _array:Vector.<FlatBTN> = new Vector.<FlatBTN>();
	public function FlatBTNFocus() {
		super();
	}
	public function add( pFlatBTN:FlatBTN):void {
		if (_array.indexOf( pFlatBTN ) == -1) {
			_array.push( pFlatBTN );
		}
	}
	public function getBTNByAt( pIndex:int ):FlatBTN {
		return _array[pIndex ];
	}
	public function focusIndex( pIndex:int ):void {
		focus( _array[pIndex] );
	}
	public function focus( pFlatBTN:FlatBTN ):void {
		if (this._currentBTN != null) {
			this._currentBTN.enabled = true;
		}
		this._currentBTN = pFlatBTN;
		this._currentBTN.enabled = false;
		for each (var b:FlatBTN in _array) {
			if (b != this._currentBTN) {
				b.tweenScale( .6 );
			}else {
				b.tweenScale(1 );
			}
		}
	}
	
	
}
class FlatBTN extends Sprite {
	private var _shape	:Shape;
	
	private var _id		:int;
	public function get id():int {	return _id;	}	
	public function set id(value:int):void {
		_id = value;
		this.text = (value + 1) + "";		
	}
	
	private var _tf		:TextField;
	private var _color	:uint;
	public function get color():uint {	return _color;	}
	
	private var _color2 :uint;
	public function get color2():uint {	return this._color2;	}
	
	private var _enabled:Boolean = true;
	public function get enabled():Boolean {	return _enabled;	}	
	public function set enabled(value:Boolean):void {
		_enabled = value;
		this.mouseEnabled = value;
		this.mouseChildren = value;
	}
	
	public function FlatBTN( pColor:uint, pRadius:int , pClickHandler:Function) {		
		super();
		this._color = pColor;
		
		if (pClickHandler == null) {
			this.mouseEnabled = false;
			this.mouseChildren = false;
		}else {
			this.buttonMode = true;
			this.addEventListener(MouseEvent.CLICK, pClickHandler );			
		}
		this.addChild( _shape = new Shape);
		_shape.graphics.beginFill( pColor );
		_shape.graphics.drawCircle( 0, 0, pRadius );		
		_shape.graphics.endFill();
		
		_color2 = ColorUtil.adjustBrightness( pColor , + 30 );		
		_shape.graphics.beginFill( _color2 );
		_shape.graphics.drawCircle( 0, 0, pRadius * 0.8 );		
		_shape.graphics.endFill();
		
		
		this.addChild( _tf = new TextField);
		_tf.mouseEnabled = false;
		_tf.embedFonts = true;
		var tfm:TextFormat = new TextFormat("Futura2", 40, 0x333333 );			
		
		_tf.defaultTextFormat = tfm;
		
		
		this.cacheAsBitmap = true;		
		
	}
	public function tweenScale( pValue:Number ):void {
		TweenMax.to( this , .5, {
			scale		:pValue,
			ease		:Cubic.easeInOut
		} );
	}
	public function set scale( pValue:Number ):void {
		this.scaleX = pValue;
		this.scaleY = pValue;
	}
	public function get scale():Number {
		return this.scaleX;
	}

	
	public function set text( value:String):void {
		_tf.text = value;
		_tf.y = _tf.textHeight / -2;
		_tf.x = _tf.textWidth / -2;
	}
	
	
	
	
	
	
}

class MoveMC extends FlatBTN {
	public var lockMove:Boolean = false;
	public var index:int = 0;
	public var checkNextIndex:int = 0;	
	public function MoveMC( pColor:uint , pRadius:int ) {
		super( pColor , pRadius , null);
	
	}

}