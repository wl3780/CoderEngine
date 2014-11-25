package com.coder.core.displays.items
{
	import com.coder.core.displays.DisplaySprite;
	import com.coder.utils.Hash;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;

	public class Image extends DisplaySprite
	{
		public static const TOP_LEFT:String = "top_left";
		public static const CENTER:String = "center";

		public static var DEFAULT_IMAGE:String = "";
		public static var hash:Hash = new Hash();
		
		protected static var _limitIndex_:int = 4;
		protected static var wealthQuene:Array = [];

		public var onComplete:Function;
		public var showDefult:Boolean = true;
		
		protected var path:String;
		protected var _bitmapData:BitmapData;
		protected var _alignMode:String = TOP_LEFT;
		protected var _clearAuto_:Boolean = true;
		protected var _smooth:Boolean = false;
		protected var _borderWidth_:Number = 0;
		protected var _borderHeight_:Number = 0;
		protected var _minWidth_:int;
		protected var _minHeight_:int;
		protected var _disposed:Boolean;
		protected var _width_:int;
		protected var _height_:int;

		public function Image()
		{
			_minWidth_ = 1;
			this.width = 1;
			_minHeight_ = 0;
			this.height = 0;
		}
		
		public static function getImageBitmapData(url:String):BitmapData
		{
			return hash.take(url) as BitmapData;
		}

		public function get alignMode():String
		{
			return _alignMode;
		}
		public function set alignMode(value:String):void
		{
			_alignMode = value;
		}
		
		public function get borderHeight():int
		{
			return _borderHeight_;
		}
		public function set borderHeight(value:int):void
		{
			_borderHeight_ = value;
		}
		
		public function get borderWidth():int
		{
			return _borderWidth_;
		}
		public function set borderWidth(value:int):void
		{
			_borderWidth_ = value;
		}
		
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
		public function set bitmapData(value:BitmapData):void
		{
			_bitmapData = value;
			this.onRender();
		}
		
		public function doit():void
		{
			this.addEventListener(Event.ENTER_FRAME, onEnterFrameFunc);
		}
		
		protected function onEnterFrameFunc(event:Event):void
		{
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrameFunc);
			onRender();
		}
		
		public function set source(value:Object):void
		{
			if (!value) {
				this.bitmapData = null;
				this.clear();
				this.display();
			} else {
				if (value is String) {
					this.load(value as String);
				} else {
					if (value is BitmapData) {
						this.bitmapData = value as BitmapData;
						if (this.onComplete != null) {
							this.onComplete();
							this.onComplete = null;
						}
					}
				}
			}
		}
		
		public function display():void
		{
			this.addEventListener(Event.ENTER_FRAME, displayFunc);
		}
		
		protected function displayFunc(e:Event):void
		{
			this.removeEventListener(Event.ENTER_FRAME, displayFunc);
			this.onRender();
		}
		
		public function clear():void
		{
			this.graphics.clear();
		}
		
		protected function fillMidBitmap():void
		{
		}
		
		protected function fillTopBitmap():void
		{
		}
		
		override public function onRender():void
		{
			if (_disposed) {
				return;
			}
			if (_clearAuto_) {
				this.graphics.clear();
			}
			draw2(this.bitmapData, this.alignMode);
		}
		
		protected function draw2(bitmapData:BitmapData, align:String):void
		{
			if (!bitmapData) {
				return;
			}
			
			var matrix:Matrix = null;
			var sX:Number;
			var sY:Number;
			var offsetX:Number = borderWidth;
			var offsetY:Number = borderHeight;
			if (_width_ != 0 && _height_ != 0) {
				sX = 1;
				sY = 1;
				matrix = new Matrix();
				if (bitmapData.width < (_width_ - borderWidth * 2)) {
					offsetX = (_width_ - bitmapData.width) / 2;
				} else {
					sX = (_width_ - borderWidth * 2) / bitmapData.width;
				}
				if (bitmapData.height < (_height_ - borderWidth * 2)) {
					offsetY = (_height_ - bitmapData.height) / 2;
				} else {
					sY = (_height_ - borderWidth * 2) / bitmapData.height;
				}
				matrix.scale(sX, sY);
				if (align == CENTER) {
					matrix.tx = matrix.tx + offsetX;
					matrix.ty = matrix.ty + offsetY;
				}
			} else {
				_width_ = bitmapData.width;
				_height_ = bitmapData.height;
			}
			
			this.graphics.beginBitmapFill(bitmapData, matrix, false, smooth);
			var toW:Number = _width_ - borderWidth * 2;
			var toH:Number = _height_ - borderHeight * 2;
			if (align == CENTER) {
				if (bitmapData.width < (_width_ - borderWidth * 2)) {
					toW = bitmapData.width;
				}
				if (bitmapData.height < (_height_ - borderWidth * 2)) {
					toH = bitmapData.height;
				}
				this.graphics.drawRect(offsetX, offsetY, toW, toH);
			} else {
				if (bitmapData.width < _width_) {
					toW = bitmapData.width;
				}
				if (bitmapData.height < _height_) {
					toH = bitmapData.height;
				}
				this.graphics.drawRect(borderWidth, borderHeight, toW, toH);
			}
		}
		
		private function load(url:String):void
		{
			if (url != DEFAULT_IMAGE){
				this.path = url;
			}
			var tmpData:BitmapData = hash.take(url) as BitmapData;
			if (tmpData) {
				this.bitmapData = tmpData;
				if (this.onComplete != null) {
					this.onComplete();
					this.onComplete = null;
				}
			} else {
				var info:Object = {
					url:url,
					loadedFunc:loadedFunc,
					loadErrorFunc:loadErrorFunc
				}
				wealthQuene.push(info);
				loadImage();
			}
		}
		
		private function loadImage():void
		{
			var info:Object = null;
			var url:String = null;
			var succFunc:Function = null;
			var errFunc:Function = null;
			var loader:ImageLoader = null;
			while (_limitIndex_ && wealthQuene.length) {
				info = wealthQuene.shift();
				url = info.url;
				succFunc = info.loadedFunc;
				errFunc = info.loadErrorFunc;
				loader = new ImageLoader();
				loader.data = info;
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, succFunc);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errFunc);
				loader.load(new URLRequest(url));
				_limitIndex_ = _limitIndex_ - 1;
			}
		}
		
		protected function loadFinish():void
		{
		}
		
		private function loadedFunc(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE, loadedFunc);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorFunc);
			var loader:ImageLoader = e.target.loader as ImageLoader;
			var tmpBitmap:Bitmap = loader.content as Bitmap;
			var tmpData:BitmapData = tmpBitmap.bitmapData;
			hash.put(loader.data.url, tmpData);
			this.bitmapData = tmpData;
			loadFinish();
			if (this.onComplete != null) {
				this.onComplete();
				this.onComplete = null;
			}
			_limitIndex_ = _limitIndex_ + 1;
			loadImage();
		}
		
		private function loadErrorFunc(e:IOErrorEvent):void
		{
			if (DEFAULT_IMAGE) {
				var tmpData:BitmapData = hash.take(DEFAULT_IMAGE) as BitmapData;
				if (tmpData) {
					this.bitmapData = tmpData;
				} else {
					this.load(DEFAULT_IMAGE);
				}
			}
			_limitIndex_ = _limitIndex_ + 1;
			loadImage();
		}
		
		public function getColorBounds():Rectangle
		{
			if (_bitmapData) {
				return _bitmapData.getColorBoundsRect(4278190080, 0, false);
			}
			return new Rectangle();
		}
		
		override public function set width(value:Number):void
		{
			_width_ = value;
			if (this.bitmapData) {
				this.display();
			}
		}
		override public function set height(value:Number):void
		{
			_height_ = value;
			if (this.bitmapData) {
				this.display();
			}
		}
		public function get smooth():Boolean
		{
			return _smooth;
		}
		public function set smooth(value:Boolean):void
		{
			_smooth = value;
			if (this.bitmapData) {
				this.onRender();
			}
		}
		override public function dispose():void
		{
			_bitmapData = null;
			onComplete = null;
			super.dispose();
		}

	}
}
