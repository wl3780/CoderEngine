package com.coder.utils
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class BitmapScale9Grid
	{
		public static var _defaultBitmapData_:BitmapData = new BitmapData(10, 10, false, 0xFFFFFF);

		private var _bitmapdata:BitmapData;
		private var _width:int;
		private var _height:int;
		private var _scale9Grid:Rectangle;
		private var _cutRect:Rectangle;
		private var _scale9GridRect:Array;
		private var _x:int = 0;
		private var _y:int = 0;

		public function BitmapScale9Grid(bitmapData:BitmapData=null, scale9Grid:Rectangle=null)
		{
			_bitmapdata = bitmapData;
			if (_bitmapdata == null) {
				_bitmapdata = _defaultBitmapData_;
			}
			_scale9Grid = scale9Grid;
			if (_scale9Grid == null) {
				_scale9Grid = new Rectangle(80, 30, 121, 340);
			}
			updataCutRectangle();
		}
		
		public function set x(value:int):void
		{
			_x = value;
			this.updataCutRectangle();
		}
		
		public function set y(value:int):void
		{
			_y = value;
			this.updataCutRectangle();
		}
		
		public function setPos(x:int, y:int):void
		{
			_x = x;
			_y = y;
			this.updataCutRectangle();
		}
		
		public function get curRect():Rectangle
		{
			return _cutRect;
		}
		
		public function reander():void
		{
			updataCutRectangle();
		}
		
		private function updataCutRectangle():void
		{
			if (_bitmapdata == null || (_bitmapdata.width == 0 && _bitmapdata.height == 0)) {
				return;
			}
			var bmdRect:Rectangle = _bitmapdata.rect;
			var rHeight:int = (_width - _scale9Grid.x) - (bmdRect.right - _scale9Grid.right);
			var _local13:int = (_height - _scale9Grid.y) - (bmdRect.bottom - _scale9Grid.bottom);
			rHeight < 0 ? rHeight = 0 : "";
			_local13 < 0 ? _local13 = 0 : "";
			_cutRect = new Rectangle(_scale9Grid.x, _scale9Grid.y, rHeight, _local13);
			
			var xx:Vector.<int> = new <int>[0, _scale9Grid.x, _scale9Grid.right];
			
			var yx:Vector.<int> =  new <int>[0, _scale9Grid.y, _scale9Grid.bottom];;
			
			var wx:Vector.<int> =  new <int>[_scale9Grid.x, _scale9Grid.width, bmdRect.right-_scale9Grid.right];;
			
			var hx:Vector.<int> =  new <int>[_scale9Grid.y, _scale9Grid.height, bmdRect.bottom-_scale9Grid.bottom];;
			
			var x:Vector.<int> =  new <int>[0, _cutRect.x, _cutRect.right];;
			
			var y:Vector.<int> =  new <int>[0, _cutRect.y, _cutRect.bottom];;
			
			var w:Vector.<int> =  new <int>[_cutRect.x, _cutRect.width, bmdRect.right-_scale9Grid.right];;
			
			var h:Vector.<int> =  new <int>[_cutRect.y, _cutRect.height, bmdRect.bottom-_scale9Grid.bottom];;
			
			var mat:Matrix = null;
			var sx:Number;
			var sy:Number;
			_scale9GridRect = [];
			for (var i:int = 0; i < 3; i++) {
				for (var j:int = 0; j < 3; j++) {
					mat = new Matrix();
					sx = w[i] / wx[i];
					sy = h[j] / hx[j];
					mat.scale(sx, sy);
					mat.ty = y[j] - yx[j] + _y;
					mat.tx = x[i] - xx[i] + _x;
					if (i == 1) {
						mat.tx = (1 - sx) * x[1] + _x;
					}
					if (j == 1) {
						mat.ty = (1 - sy) * y[1] + _y;
					}
					_scale9GridRect.push({
						rect:new Rectangle(x[i], y[j], w[i], h[j]),
						matrix:mat
					});
				}
			}
		}
		
		public function set width(value:Number):void
		{
			_width = value;
			updataCutRectangle();
		}
		
		public function set height(value:Number):void
		{
			_height = value;
			updataCutRectangle();
		}
		
		public function setup(bitmapData:BitmapData, scale9Grid:Rectangle):void
		{
			this.bitmapData = bitmapData;
			this.scale9Grid = scale9Grid;
		}
		
		public function set scale9Grid(innerRectangle:Rectangle):void
		{
			_scale9Grid = innerRectangle;
			updataCutRectangle();
		}
		public function get scale9Grid():Rectangle
		{
			return _scale9Grid;
		}
		
		public function set rect(value:Rectangle):void
		{
			_x = value.x;
			_y = value.y;
			_width = value.width;
			_height = value.height;
			updataCutRectangle();
		}
		
		public function set bitmapData(value:BitmapData):void
		{
			_bitmapdata = value;
			updataCutRectangle();
		}
		
		public function draw(graphics:Graphics, clear:Boolean=true, drawCutRect:Boolean=true):void
		{
			if (clear) {
				graphics.clear();
			}
			var sRect:Rectangle = null;
			var sMat:Matrix = null;
			for (var i:int = 0; i < 9; i++) {
				sRect = _scale9GridRect[i].rect;
				sMat = _scale9GridRect[i].matrix;
				graphics.beginBitmapFill(_bitmapdata, sMat, false, true);
				if (!(!drawCutRect && i == 4)) {
					graphics.drawRect(sRect.x + _x, sRect.y + _y, sRect.width, sRect.height);
				}
			}
		}
		
		public function setSize(width:int, height:int):void
		{
			_width = width;
			_height = height;
			updataCutRectangle();
		}

	}
}
